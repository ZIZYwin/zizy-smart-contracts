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

    event NewPeriod(uint256 periodId);
    event NewCompetition(uint256 periodId, uint256 competitionId, address ticketAddress);
    event TicketBuy(address indexed account, uint256 periodId, uint256 competitionId, uint32 indexed ticketCount);
    event TicketSend(address indexed account, uint256 periodId, uint256 competitionId, uint256 ticketId);
    event AllocationUpdate(address indexed account, uint256 periodId, uint256 competitionId, uint32 bought, uint32 max);

    // Add competition allocation limit
    struct Competition {
        IZizyCompetitionTicket ticket;
        address sellToken;
        uint ticketPrice;
        uint snapshotMin;
        uint snapshotMax;
        uint32 ticketSold;
        bool pairDefined;
        bool _exist;
    }

    struct Period {
        uint startTime;
        uint endTime;
        uint ticketBuyStartTime;
        uint ticketBuyEndTime;
        uint256 competitionCount;
        bool isOver;
        bool _exist;
    }

    struct Tier {
        uint min;
        uint max;
        uint32 allocation;
    }

    struct Allocation {
        uint32 bought;
        uint32 max;
        bool hasAllocation;
    }

    // Max ticket count per competition = 1M
    uint32 constant MAX_TICKET_PER_COMPETITION = 1_000_000;

    uint256 public activePeriod;
    uint256 public totalPeriodCount;
    uint256 public totalCompetitionCount;
    IZizyCompetitionStaking public stakingContract;
    ITicketDeployer public ticketDeployer;

    address public paymentReceiver;
    address public ticketMinter;

    // Competition periods [periodId > Period]
    mapping(uint256 => Period) private _periods;

    // Competition in periods [periodId > competitionId > Competition]
    mapping(uint256 => mapping(uint256 => Competition)) private _periodCompetitions;

    // Competition tiers [keccak(periodId,competitionId) > Tier]
    mapping(bytes32 => Tier[]) private _compTiers;

    // Competition allocations [address > periodId > competitionId > Allocation]
    mapping(address => mapping(uint256 => mapping(uint256 => Allocation))) private _allocations;

    // Period participations [Account > PeriodId > Status]
    mapping(address => mapping(uint256 => bool)) private _periodParticipation;

    // Period competition ids collection
    mapping(uint256 => uint256[]) private _periodCompetitionIds;

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

    // Throw if caller isn't minter
    modifier onlyMinter() {
        require(_msgSender() == ticketMinter, "Only call from minter");
        _;
    }

    function initialize(address receiver_, address minter_) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        activePeriod = 0;
        totalCompetitionCount = 0;
        totalPeriodCount = 0;

        paymentReceiver = receiver_;
        ticketMinter = minter_;
    }

    // Get competition id with index number of period
    function getCompetitionIdWithIndex(uint256 periodId, uint index) external view returns (uint) {
        require(index < _periodCompetitionIds[periodId].length, "Out of boundaries");
        return _periodCompetitionIds[periodId][index];
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

    // Check competition ticket buy settings is defined
    function isCompetitionSettingsDefined(uint256 periodId, uint256 competitionId) public view returns(bool) {
        Competition memory comp = _periodCompetitions[periodId][competitionId];

        // Check competition
        if (comp._exist == false) {
            return false;
        }
        // Check competition tiers
        if (_isCompetitionTiersDefined(periodId, competitionId) == false) {
            return false;
        }
        // Check sellToken & price
        if (comp.pairDefined == false) {
            return false;
        }

        return true;
    }

    // Check ticket buy conditions for given competition & period
    function canTicketBuy(uint256 periodId, uint256 competitionId) external view returns (bool) {
        if (isCompetitionSettingsDefined(periodId, competitionId) == false) {
            return false;
        }

        uint ts = block.timestamp;
        Period memory period = _periods[periodId];

        // Ticket buy date's check
        if (ts < period.ticketBuyStartTime || ts > period.ticketBuyEndTime) {
            return false;
        }

        return true;
    }

    // Get competition allocation for account
    function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (Allocation memory) {
        return _getAllocation(account, periodId, competitionId);
    }

    // Get competition allocation for account
    function _getAllocation(address account, uint256 periodId, uint256 competitionId) internal stakeContractIsSet view returns (Allocation memory) {
        Allocation memory alloc = _allocations[account][periodId][competitionId];
        if (alloc.hasAllocation) {
            return alloc;
        }

        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp.snapshotMin > 0 && comp.snapshotMax > 0 && comp.snapshotMin <= comp.snapshotMax, "Competition snapshot ranges is not defined");
        (uint256 average, bool _calculated) = stakingContract.getPeriodSnapshotsAverage(account, periodId, comp.snapshotMin, comp.snapshotMax);

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

        return alloc;
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

    // Set active period
    function setActivePeriod(uint periodId) external stakeContractIsSet onlyOwner {
        uint256 oldPeriod = activePeriod;
        require(oldPeriod != periodId, "This period already active");
        Period memory period = _periods[periodId];
        require(period._exist == true, "Period does not exist");
        require(period.isOver == false, "This period is over");

        (uint256 response) = stakingContract.setPeriodId(periodId);
        require(response == periodId, "ZizyComp: Staking contract period can't updated");

        // Set previous period is over !
        if (oldPeriod != 0) {
            _periods[oldPeriod].isOver = true;
        }

        activePeriod = periodId;

        // Set is over previous period
        if (oldPeriod != 0) {
            _periods[oldPeriod].isOver = true;
        }
    }

    // Create competition period
    function createPeriod(uint newPeriodId, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external stakeContractIsSet onlyOwner returns (uint256) {
        require(newPeriodId > 0, "New period id should be higher than zero");
        require(_periods[newPeriodId]._exist == false, "Period id already exist");

        _periods[newPeriodId] = Period(startTime_, endTime_, ticketBuyStart_, ticketBuyEnd_, 0, false, true);

        totalPeriodCount++;

        emit NewPeriod(newPeriodId);

        return newPeriodId;
    }

    // Update period date ranges
    function updatePeriod(uint periodId_, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external onlyOwner returns (bool) {
        Period storage period = _periods[periodId_];
        require(period._exist == true, "There is no period exist");

        period.startTime = startTime_;
        period.endTime = endTime_;
        period.ticketBuyStartTime = ticketBuyStart_;
        period.ticketBuyEndTime = ticketBuyEnd_;

        return true;
    }

    // Create competition for current period
    function createCompetition(uint periodId, uint256 competitionId, string memory name_, string memory symbol_) external ticketDeployerIsSet onlyOwner returns (address, uint256, uint256) {
        Period memory period = _periods[periodId];
        require(period._exist == true, "Period does not exist");
        require(period.isOver == false, "This period is over");

        require(_periodCompetitions[periodId][competitionId]._exist == false, "Competition already exist");

        // Deploy competition ticket contract
        (, address ticketContract) = ticketDeployer.deploy(name_, symbol_);
        IZizyCompetitionTicket competition = IZizyCompetitionTicket(ticketContract);

        // Pause transfers on init
        competition.pause();

        // Add competition into the list
        _periodCompetitions[periodId][competitionId] = Competition(competition, address(0), 0, 0, 0, 0, false, true);

        // Increase competition counters
        _periods[periodId].competitionCount++;
        totalCompetitionCount++;
        _periodCompetitionIds[periodId].push(competitionId);

        // Emit new competition event
        emit NewCompetition(periodId, competitionId, address(competition));

        return (address(competition), periodId, competitionId);
    }

    // Set ticket sale settings for competition
    function setCompetitionPayment(uint256 periodId, uint256 competitionId, address token, uint ticketPrice) external onlyOwner {
        require(token != address(0), "Payment token can not be zero address");
        require(ticketPrice > 0, "Ticket price can not be zero");

        Competition storage comp = _periodCompetitions[periodId][competitionId];
        comp.pairDefined = true;
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

    // Is competition tiers defined
    function _isCompetitionTiersDefined(uint256 periodId, uint256 competitionId) internal view returns (bool) {
        bytes32 compHash = _competitionKey(periodId, competitionId);
        return (_compTiers[compHash].length > 0);
    }

    // Set competition tiers
    function setCompetitionTiers(uint256 periodId, uint256 competitionId, uint[] calldata mins, uint[] calldata maxs, uint32[] calldata allocs) external onlyOwner {
        uint length = mins.length;
        require(length > 1, "Tiers should be higher than 1");
        require(length == maxs.length && length == allocs.length, "Should be same length");

        bytes32 compHash = _competitionKey(periodId, competitionId);
        uint prevMax = 0;

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

            prevMax = max;
        }
    }

    // Buy ticket for a competition
    function buyTicket(uint256 periodId, uint256 competitionId, uint32 ticketCount) external paymentReceiverIsSet nonReentrant {
        require(ticketCount > 0, "Requested ticket count should be higher than zero");
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp.pairDefined == true, "Ticket sell pair is not defined");
        require((comp.ticketSold + ticketCount) <= MAX_TICKET_PER_COMPETITION, "Tickets are out of stock for this competition");

        Allocation memory alloc = _getAllocation(_msgSender(), periodId, competitionId);

        // Store calculated competition allocation
        if (alloc.hasAllocation == true && _allocations[_msgSender()][periodId][competitionId].hasAllocation == false) {
            // Write calculated competition allocation into storage
            _allocations[_msgSender()][periodId][competitionId] = alloc;

            // Emit allocation update event for statistic
            emit AllocationUpdate(_msgSender(), periodId, competitionId, alloc.bought, alloc.max);
        }

        require(alloc.bought < alloc.max, "There is no allocation limit left");

        uint32 buyMax = (alloc.max - alloc.bought);
        require(ticketCount <= buyMax, "Max allocation limit exceeded");

        uint ts = block.timestamp;

        Period memory period = _periods[periodId];
        require(ts >= period.ticketBuyStartTime && ts <= period.ticketBuyEndTime, "Period is not in buy stage");

        uint256 paymentAmount = comp.ticketPrice * ticketCount;
        IERC20Upgradeable token_ = IERC20Upgradeable(comp.sellToken);
        uint256 allowance_ = token_.allowance(_msgSender(), address(this));
        require(allowance_ >= paymentAmount, "Insufficient allowance");

        token_.safeTransferFrom(_msgSender(), paymentReceiver, paymentAmount);

        // Set participation state
        _periodParticipation[_msgSender()][periodId] = true;
        _allocations[_msgSender()][periodId][competitionId].bought = (ticketCount + alloc.bought);
        _periodCompetitions[periodId][competitionId].ticketSold += ticketCount;

        // Emit new allocation
        emit AllocationUpdate(_msgSender(), periodId, competitionId, (ticketCount + alloc.bought), alloc.max);

        // Emit ticket buy event
        emit TicketBuy(_msgSender(), periodId, competitionId, ticketCount);
    }

    // Check maximum allocation for competition
    function _isAllocationExceeds(address account_, uint256 periodId_, uint256 competitionId_, uint mintCount_) internal view returns (bool) {
        // Max allocation limit check
        Allocation memory alloc = _getAllocation(account_, periodId_, competitionId_);

        return (mintCount_ > (alloc.max - alloc.bought));
    }

    // Mint & Send ticket
    function mintTicket(uint256 periodId, uint256 competitionId, address to_, uint256 ticketId_) external onlyMinter {
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist == true, "Competition does not exist");

        Allocation memory alloc = _getAllocation(to_, periodId, competitionId);
        uint accountTicketBalance = comp.ticket.balanceOf(to_);
        require((accountTicketBalance + 1) <= alloc.bought, "Maximum ticket allocation bought");

        comp.ticket.mint(to_, ticketId_);
        emit TicketSend(to_, periodId, competitionId, ticketId_);
    }

    // Mint & Send ticket batch
    function mintBatchTicket(uint256 periodId, uint256 competitionId, address to_, uint256[] calldata ticketIds) external onlyMinter {
        uint length = ticketIds.length;
        require(length > 0, "Ticket ids length should be higher than zero");

        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist == true, "Competition does not exist");

        Allocation memory alloc = _getAllocation(to_, periodId, competitionId);
        uint accountTicketBalance = comp.ticket.balanceOf(to_);
        require((accountTicketBalance + length) <= alloc.bought, "Maximum ticket allocation bought");

        for (uint i = 0; i < length; ++i) {
            uint256 mintTicketId = ticketIds[i];
            comp.ticket.mint(to_, mintTicketId);
            emit TicketSend(to_, periodId, competitionId, mintTicketId);
        }
    }

    // Get period details
    function getPeriod(uint256 periodId) external view returns (Period memory) {
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

    // Get total supply of competition
    function totalSupplyOfCompetition(uint256 periodId, uint256 competitionId) external view returns (uint256) {
        address ticketAddr = _compTicket(periodId, competitionId);
        return IZizyCompetitionTicket(ticketAddr).totalSupply();
    }
}
