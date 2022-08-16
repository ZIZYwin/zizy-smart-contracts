// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IZizyCompetitionTicket.sol";
import "./IZizyCompetitionStaking.sol";
import "./ITicketDeployer.sol";

// @dev We building sth big. Stay tuned!
contract CompetitionFactory is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event NewCompetitionPeriod(uint startTime, uint endTime, uint256 periodId);
    event NewCompetition(uint256 periodId, address ticketAddress);
    event TicketBuy(address indexed account, uint256 periodId, uint256 competitionId, uint32 indexed ticketCount);
    event TicketSend(address indexed account, uint256 periodId, uint256 competitionId, uint256 ticketId);

    // Add competition allocation limit
    struct Competition {
        IZizyCompetitionTicket ticket;
        address sellToken;
        uint ticketPrice;
        uint snapshotMin;
        uint snapshotMax;
        uint32 ticketSold;
        bool buyActive;
        bool _exist;
    }

    struct TicketBuyOptions {
        uint buyStartDate;
        uint buyEndDate;
        bool isActive;
    }

    struct CompetitionPeriod {
        uint startTime;
        uint endTime;
        uint ticketBuyStartTime;
        uint ticketBuyEndTime;
        uint256 competitionCount;
        bool _exist;
    }

    struct Tier {
        uint min;
        uint max;
        uint32 allocation;
    }

    struct Allocation {
        uint32 max;
        uint32 bought;
        bool hasAllocation;
    }

    uint256 private _currentPeriodNumber;
    uint256 private _totalCompetitionCount;
    IZizyCompetitionStaking public stakingContract;
    ITicketDeployer public ticketDeployer;

    address public paymentReceiver;
    address public ticketMinter;

    // Competition periods [periodId > CompetitionPeriod]
    mapping(uint256 => CompetitionPeriod) private _periods;

    // Competition in periods [periodId > competitionId > Competition]
    mapping(uint256 => mapping(uint256 => Competition)) private _periodCompetitions;

    // Competition tiers [keccak(periodId,competitionId) > Tier]
    mapping(bytes32 => Tier[]) private _compTiers;

    // Period ticket buy options
    mapping(uint256 => TicketBuyOptions) private _ticketBuyOptions;

    // Competition allocations [address > periodId > competitionId > Allocation]
    mapping(address => mapping(uint256 => mapping(uint256 => Allocation))) private _allocations;

    // Period participations [Account > PeriodId > Status]
    mapping(address => mapping(uint256 => bool)) private _periodParticipation;

    // Throw if any active period exist on now
    modifier whenNotActivePeriod() {
        uint256 cPeriod = _currentPeriodNumber;

        if (cPeriod == 0) {
            // Check current isn't exist
            require(_periods[cPeriod]._exist == false, "ZizyComp: Period exist");
        }
        require(_periods[cPeriod].endTime < block.timestamp, "ZizyComp: Current period isn't completed");
        _;
    }

    // Throw if staking contract isn't defined
    modifier stakeContractIsSet {
        require(address(stakingContract) != address(0), "ZizyComp: Staking contract should be defined");
        _;
    }

    // Throw if ticket deployer contract isn't defined
    modifier ticketDeployerIsSet {
        require(address(ticketDeployer) != address(0), "ZizyComp: Ticket deployer contract should be defined");
        _;
    }

    // Throw if payment receiver address isn't defined
    modifier paymentReceiverIsSet {
        require(paymentReceiver != address(0), "Payment receiver address is not defined");
        _;
    }

    // Throw if current period isn't exist
    modifier whenCurrentPeriodExist() {
        uint256 cPeriod = _currentPeriodNumber;

        require(cPeriod > 0, "ZizyComp: There is no period exist");
        // Period index check
        require(_periods[cPeriod]._exist, "ZizyComp: There is no period exist");
        _;
    }

    // Throw if caller isn't minter
    modifier onlyMinter() {
        require(msg.sender == ticketMinter, "Only call from minter");
        _;
    }

    function initialize(address receiver_, address minter_) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        _currentPeriodNumber = 0;
        _totalCompetitionCount = 0;

        paymentReceiver = receiver_;
        ticketMinter = minter_;
    }

    // Hash of period competition
    function _competitionKey(uint256 periodId, uint256 competitionId) internal pure returns (bytes32) {
        return keccak256(abi.encode(periodId, competitionId));
    }

    // Check any account has participation on specified period
    function hasParticipation(address account_, uint256 periodId_) external view returns (bool) {
        return _periodParticipation[account_][periodId_];
    }

    // Set payment receiver address
    function setPaymentReceiver(address receiver_) external onlyOwner {
        require(receiver_ != address(0), "Payment receiver can not be zero address");
        paymentReceiver = receiver_;
    }

    // Set ticket minter address
    function setTicketMinter(address minter_) external onlyOwner {
        require(minter_ != address(0), "Minter address can not be zero");
        ticketMinter = minter_;
    }

    // Get competition allocation for account
    function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (uint32, uint32, bool) {
        Allocation memory alloc = _allocations[account][periodId][competitionId];
        return (alloc.bought, alloc.max, alloc.hasAllocation);
    }

    // Set staking contract address
    function setStakingContract(address stakingContract_) external onlyOwner {
        require(address(stakingContract_) != address(0), "ZizyComp: Staking contract address can not be zero");
        stakingContract = IZizyCompetitionStaking(stakingContract_);
    }

    // Set ticket deployer contract address
    function setTicketDeployer(address ticketDeployer_) external onlyOwner {
        require(address(ticketDeployer_) != address(0), "ZizyComp: Ticket deployer contract address can not be zero");
        ticketDeployer = ITicketDeployer(ticketDeployer_);
    }

    // Create competition period
    function createCompetitionPeriod(uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external whenNotActivePeriod stakeContractIsSet onlyOwner returns (uint256) {
        uint256 newPeriodNumber = (_currentPeriodNumber + 1);

        (uint256 response) = stakingContract.setPeriodId(newPeriodNumber);
        require(response == newPeriodNumber, "ZizyComp: Staking contract period can't updated");

        _periods[newPeriodNumber] = CompetitionPeriod(startTime_, endTime_, ticketBuyStart_, ticketBuyEnd_, 0, true);

        _currentPeriodNumber = newPeriodNumber;

        emit NewCompetitionPeriod(startTime_, endTime_, newPeriodNumber);

        return newPeriodNumber;
    }

    // Update period date ranges
    function updateCompetitionPeriod(uint periodId_, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external onlyOwner returns (bool) {
        CompetitionPeriod storage period = _periods[periodId_];
        require(period._exist == true, "There is no period exist");

        period.startTime = startTime_;
        period.endTime = endTime_;
        period.ticketBuyStartTime = ticketBuyStart_;
        period.ticketBuyEndTime = ticketBuyEnd_;

        return true;
    }

    // Create competition for current period
    function createCompetition(string memory name_, string memory symbol_) external whenCurrentPeriodExist ticketDeployerIsSet onlyOwner returns (address, uint256, uint256) {
        uint256 periodIndex = _currentPeriodNumber;
        CompetitionPeriod memory currentPeriod = _periods[periodIndex];

        // Deploy competition ticket contract
        (, address ticketContract) = ticketDeployer.deploy(name_, symbol_);
        IZizyCompetitionTicket competition = IZizyCompetitionTicket(ticketContract);

        // Pause transfers on init
        competition.pause();

        // Add ticket NFT into the list
        _periodCompetitions[periodIndex][(currentPeriod.competitionCount + 1)] = Competition(competition, address(0), 0, 0, 0, 0, false, true);

        // Increase competition counters
        _periods[periodIndex].competitionCount++;
        _totalCompetitionCount++;

        // Emit new competition event
        emit NewCompetition(periodIndex, address(competition));

        return (address(competition), periodIndex, ((currentPeriod.competitionCount + 1)));
    }

    // Set ticket sale settings for competition
    function setCompetitionPayment(uint256 periodId, uint256 competitionId, address token, uint ticketPrice) external onlyOwner {
        require(token != address(0), "Payment token can not be zero address");
        require(ticketPrice > 0, "Ticket price can not be zero");

        Competition storage comp = _periodCompetitions[periodId][competitionId];
        comp.buyActive = true;
        comp.sellToken = token;
        comp.ticketPrice = ticketPrice;
    }

    // Set competition snapshot range
    function setCompetitionSnapshotRange(uint256 periodId, uint256 competitionId, uint min, uint max) external stakeContractIsSet onlyOwner {
        require(min <= max, "Min should be higher");
        (uint periodMin, uint periodMax) = stakingContract.getPeriodSnapshotRange(periodId);
        require(min >= periodMin && max <= periodMax, "Range should between period snapshot ranges");
        Competition storage comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist == true, "There is no competition");

        comp.snapshotMin = min;
        comp.snapshotMax = max;
    }

    // Set competition tiers
    function setCompetitionTiers(uint256 periodId, uint256 competitionId, uint[] calldata mins, uint[] calldata maxs, uint32[] calldata allocs) external onlyOwner {
        uint length = mins.length;
        require(length > 1, "Tiers should be higher than 1");
        require(length == maxs.length && length == allocs.length, "Should be same length");

        bytes32 compHash = _competitionKey(periodId, competitionId);
        uint prevMax = 0;
        uint prevMin = 0;

        delete _compTiers[compHash];


        for (uint i = 0; i < length; ++i) {
            bool isFirst = (i == 0);
            bool isLast = (i == (length - 1));
            uint32 alloc = allocs[i];
            uint min = mins[i];
            uint max = (isLast ? (2 ** 256 - 1) : maxs[i]);

            if (!isFirst) {
                require(min > prevMax, "Range collision");
            }
            _compTiers[compHash].push(Tier(min, max, alloc));

            prevMin = min;
            prevMax = max;
        }
    }

    // Calculate account allocation for competition
    function calculateAllocationForCompetition(uint256 periodId, uint256 competitionId) external {
        _calculateAllocationForCompetition(msg.sender, periodId, competitionId);
    }

    // Calculate account allocation for competition internal
    function _calculateAllocationForCompetition(address account, uint256 periodId, uint256 competitionId) internal stakeContractIsSet returns (uint32, uint32) {
        Allocation memory alloc = _allocations[msg.sender][periodId][competitionId];
        require(alloc.hasAllocation == false, "Competition allocation already calculated");

        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp.snapshotMin > 0 && comp.snapshotMax > 0 && comp.snapshotMin <= comp.snapshotMax, "Competition snapshot ranges is not defined");
        (uint256 average, bool _calculated) = stakingContract.getSnapshotsAverage(account, periodId, comp.snapshotMin, comp.snapshotMax);

        require(_calculated == true, "Period snapshot averages does not calculated !");

        bytes32 compHash = _competitionKey(periodId, competitionId);
        Tier[] memory tiers = _compTiers[compHash];
        Tier memory tier = Tier(0, 0, 0);
        uint tierLength = tiers.length;
        require(tierLength >= 1, "Competition tiers is not defined");

        for (uint i = 0; i < tierLength; ++i) {
            tier = tiers[i];
            alloc.hasAllocation = true;

            // Break if user has lower average for lowest tier
            if (i == 0 && (average < tier.min)) {
                alloc.bought = 0;
                alloc.max = 0;

                break;
            }

            // Find user tier range
            if (average >= tier.min && average <= tier.max) {
                alloc.bought = 0;
                alloc.max = tier.allocation;
                break;
            }
        }

        _allocations[account][periodId][competitionId] = alloc;

        return (alloc.bought, alloc.max);
    }

    // Buy ticket for a competition
    function buyTicket(uint256 periodId, uint256 competitionId, uint32 ticketCount) external paymentReceiverIsSet nonReentrant {
        require(ticketCount > 0, "Requested ticket count should be higher than zero");
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp.buyActive == true, "Buy ticket is not active yet");

        if (_allocations[msg.sender][periodId][competitionId].hasAllocation == false) {
            _calculateAllocationForCompetition(msg.sender, periodId, competitionId);
        }

        Allocation memory alloc = _allocations[msg.sender][periodId][competitionId];
        require(alloc.bought < alloc.max, "There is no allocation limit left");

        uint32 buyMax = (alloc.max - alloc.bought);
        require(ticketCount <= buyMax, "Max allocation limit exceeded");

        uint ts = block.timestamp;

        CompetitionPeriod memory compPeriod = _periods[periodId];
        require(ts >= compPeriod.ticketBuyStartTime && ts <= compPeriod.ticketBuyEndTime, "Period is not in buy stage");

        uint256 paymentAmount = comp.ticketPrice * ticketCount;
        IERC20Upgradeable token_ = IERC20Upgradeable(comp.sellToken);
        uint256 allowance_ = token_.allowance(msg.sender, address(this));
        require(allowance_ >= paymentAmount, "Insufficient allowance");

        token_.safeTransferFrom(msg.sender, paymentReceiver, paymentAmount);

        // Set participation state
        _periodParticipation[msg.sender][periodId] = true;
        _allocations[msg.sender][periodId][competitionId].bought += ticketCount;
        _periodCompetitions[periodId][competitionId].ticketSold += ticketCount;

        emit TicketBuy(msg.sender, periodId, competitionId, ticketCount);
    }

    // Mint & Send ticket
    function mintTicket(uint256 periodId, uint256 competitionId, address to_, uint256 ticketId_) external onlyMinter {
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist == true, "Competition does not exist");
        comp.ticket.mint(to_, ticketId_);
        emit TicketSend(to_, periodId, competitionId, ticketId_);
    }

    // Mint & Send ticket batch
    function mintBatchTicket(uint256 periodId, uint256 competitionId, address to_, uint256[] calldata ticketIds) external onlyMinter {
        uint length = ticketIds.length;
        require(length > 0, "Ticket ids length should be higher than zero");

        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist == true, "Competition does not exist");

        for (uint i = 0; i < length; ++i) {
            uint256 mintTicketId = ticketIds[i];
            comp.ticket.mint(to_, mintTicketId);
            emit TicketSend(to_, periodId, competitionId, mintTicketId);
        }
    }

    // Get total period count
    function totalPeriodCount() external view returns (uint) {
        return _currentPeriodNumber;
    }

    // Get total competition count of all periods
    function totalCompetitionCount() external view returns (uint) {
        return _totalCompetitionCount;
    }

    // Get period details
    function getPeriod(uint256 periodId) external view returns (CompetitionPeriod memory) {
        return _periods[periodId];
    }

    // Get period competition details
    function getPeriodCompetition(uint256 periodId, uint256 competitionId) external view returns (Competition memory) {
        return _periodCompetitions[periodId][competitionId];
    }

    // Get period competition count
    function getPeriodCompetitionCount(uint256 periodId) external view returns (uint) {
        return _periods[periodId].competitionCount;
    }

    // Get competition ticket contract address
    function _compTicket(uint256 periodId, uint256 competitionId) internal view returns (address) {
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist, "ZizyComp: Competition does not exist");
        return address(comp.ticket);
    }

    // Pause competition ticket transfers
    function pauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).pause();
    }

    // Un-pause competition ticket transfers
    function unpauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).unpause();
    }

    // Set competition ticket baseUri
    function setCompetitionBaseURI(uint256 periodId, uint256 competitionId, string memory baseUri_) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).setBaseURI(baseUri_);
    }

    // Set competition description
    function setCompetitionDescription(uint256 periodId, uint256 competitionId, string memory description_) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).setDescription(description_);
    }

    // Get total supply of competition
    function totalSupplyOfCompetition(uint256 periodId, uint256 competitionId) external view returns (uint256) {
        address ticketAddr = _compTicket(periodId, competitionId);
        return IZizyCompetitionTicket(ticketAddr).totalSupply();
    }
}
