// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IZizyCompetitionTicket.sol";
import "./IZizyCompetitionStaking.sol";
import "./ITicketDeployer.sol";

/**
 * @title CompetitionFactory
 * @notice This contract manages competitions and ticket sales for different periods.
 */
contract CompetitionFactory is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @notice Struct for competition
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

    /// @notice Struct for period
    struct Period {
        uint startTime;
        uint endTime;
        uint ticketBuyStartTime;
        uint ticketBuyEndTime;
        uint256 competitionCount;
        bool isOver;
        bool _exist;
    }

    /// @notice Struct for allocation tier
    struct Tier {
        uint min;
        uint max;
        uint32 allocation;
    }

    /// @notice Struct for allocation of period
    struct Allocation {
        uint32 bought;
        uint32 max;
        bool hasAllocation;
    }

    // Max ticket count per competition = 1M
    uint32 constant MAX_TICKET_PER_COMPETITION = 1_000_000;

    /// @notice The ID of the active period
    uint256 public activePeriod;

    /// @notice The total number of periods
    uint256 public totalPeriodCount;

    /// @notice The total number of competitions
    uint256 public totalCompetitionCount;

    /// @notice The staking contract
    IZizyCompetitionStaking public stakingContract;

    /// @notice The ticket deployer contract
    ITicketDeployer public ticketDeployer;

    /// @notice The address to receive payment
    address public paymentReceiver;

    /// @notice The address authorized to mint tickets
    address public ticketMinter;

    /// @dev Competition periods [periodId > Period]
    mapping(uint256 => Period) private _periods;

    /// @dev Competition in periods [periodId > competitionId > Competition]
    mapping(uint256 => mapping(uint256 => Competition)) private _periodCompetitions;

    /// @dev Competition tiers [keccak(periodId,competitionId) > Tier]
    mapping(bytes32 => Tier[]) private _compTiers;

    /// @dev Competition allocations [address > periodId > competitionId > Allocation]
    mapping(address => mapping(uint256 => mapping(uint256 => Allocation))) private _allocations;

    /// @dev Period participations [Account > PeriodId > Status]
    mapping(address => mapping(uint256 => bool)) private _periodParticipation;

    /// @dev Period competition ids collection
    mapping(uint256 => uint256[]) private _periodCompetitionIds;

    /**
     * @notice Event emitted when a new period is created.
     * @param periodId The ID of the new period.
     */
    event NewPeriod(uint256 periodId);

    /**
     * @notice Event emitted when a new competition is created.
     * @param periodId The ID of the period in which the competition is created.
     * @param competitionId The ID of the new competition.
     * @param ticketAddress The address of the competition ticket contract.
     */
    event NewCompetition(uint256 periodId, uint256 competitionId, address ticketAddress);

    /**
     * @notice Event emitted when a ticket is bought.
     * @param account The account that bought the ticket.
     * @param periodId The ID of the period in which the ticket is bought.
     * @param competitionId The ID of the competition for which the ticket is bought.
     * @param ticketCount The number of tickets bought.
     */
    event TicketBuy(address indexed account, uint256 periodId, uint256 competitionId, uint32 indexed ticketCount);

    /**
     * @notice Event emitted when a ticket is sent.
     * @param account The account that sent the ticket.
     * @param periodId The ID of the period in which the ticket is sent.
     * @param competitionId The ID of the competition for which the ticket is sent.
     * @param ticketId The ID of the sent ticket.
     */
    event TicketSend(address indexed account, uint256 periodId, uint256 competitionId, uint256 ticketId);

    /**
     * @notice Event emitted when the allocation for an account is updated.
     * @param account The account for which the allocation is updated.
     * @param periodId The ID of the period in which the allocation is updated.
     * @param competitionId The ID of the competition for which the allocation is updated.
     * @param bought The number of tickets bought by the account.
     * @param max The maximum allocation limit for the account.
     */
    event AllocationUpdate(address indexed account, uint256 periodId, uint256 competitionId, uint32 bought, uint32 max);

    /**
     * @notice This event is emitted when the payment receiver address is updated.
     * @param receiver The new address of the payment receiver.
     */
    event PaymentReceiverUpdate(address receiver);

    /**
     * @notice This event is emitted when the ticket minter address is updated.
     * @param ticketMinter The new address of the ticket minter.
     */
    event TicketMinterUpdate(address ticketMinter);

    /**
     * @notice This event is emitted when the staking contract address is updated.
     * @param stakingContract The new address of the staking contract.
     */
    event StakingContractUpdate(address stakingContract);

    /**
     * @notice This event is emitted when the ticket deployer address is updated.
     * @param ticketDeployer The new address of the ticket deployer.
     */
    event TicketDeployerUpdate(address ticketDeployer);

    /**
     * @notice This event is emitted when the active period ID is updated.
     * @param newActivePeriodId The new active period ID.
     */
    event ActivePeriodUpdate(uint newActivePeriodId);

    /**
     * @notice This event is emitted when a period is updated.
     * @param periodId The ID of the updated period.
     */
    event PeriodUpdate(uint periodId);

    /**
     * @notice This event is emitted when the payment configuration is updated for a specific period and competition.
     * @param periodId The ID of the period for which the payment configuration is updated.
     * @param competitionId The ID of the competition for which the payment configuration is updated.
     * @param token The address of the token used for payments.
     * @param ticketPrice The updated ticket price for the competition.
     */
    event PaymentConfigUpdate(uint periodId, uint competitionId, address token, uint ticketPrice);

    /**
     * @notice This event is emitted when the snapshot ranges are updated for a specific period and competition.
     * @param periodId The ID of the period for which the snapshot ranges are updated.
     * @param competitionId The ID of the competition for which the snapshot ranges are updated.
     * @param min The updated minimum snapshot ID.
     * @param max The updated maximum snapshot ID.
     */
    event SnapshotRangesUpdate(uint256 periodId, uint256 competitionId, uint min, uint max);

    /**
     * @notice This event is emitted when the tiers are updated for a specific period and competition.
     * @param periodId The ID of the period for which the tiers are updated.
     * @param competitionId The ID of the competition for which the tiers are updated.
     */
    event TiersUpdate(uint periodId, uint competitionId);

    /**
     * @notice Modifier to check if the staking contract is set.
     */
    modifier stakeContractIsSet {
        require(address(stakingContract) != address(0), "ZizyComp: Staking contract should be defined");
        _;
    }

    /**
     * @notice Modifier to check if the ticket deployer contract is set.
     */
    modifier ticketDeployerIsSet {
        require(address(ticketDeployer) != address(0), "ZizyComp: Ticket deployer contract should be defined");
        _;
    }

    /**
     * @notice Modifier to check if the payment receiver address is set.
     */
    modifier paymentReceiverIsSet {
        require(paymentReceiver != address(0), "Payment receiver address is not defined");
        _;
    }

    /**
     * @notice Modifier to caller is minter account
     */
    modifier onlyMinter() {
        require(_msgSender() == ticketMinter, "Only call from minter");
        _;
    }

    /**
     * @dev Constructor function
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract.
     * @param receiver_ The address to receive payments.
     * @param minter_ The address authorized to mint tickets.
     */
    function initialize(address receiver_, address minter_) external initializer {
        require(receiver_ != address(0) && minter_ != address(0), "Params cant be zero address");

        __Ownable_init();
        __ReentrancyGuard_init();

        activePeriod = 0;
        totalCompetitionCount = 0;
        totalPeriodCount = 0;

        paymentReceiver = receiver_;
        ticketMinter = minter_;
    }

    /**
     * @notice Gets the competition ID with the index number of the period.
     * @param periodId The ID of the period.
     * @param index The index number.
     * @return The competition ID.
     */
    function getCompetitionIdWithIndex(uint256 periodId, uint index) external view returns (uint) {
        require(index < _periodCompetitionIds[periodId].length, "Out of boundaries");
        return _periodCompetitionIds[periodId][index];
    }

    /**
     * @notice Checks if any account has participation in the specified period.
     * @param account_ The account to check.
     * @param periodId_ The ID of the period.
     * @return A boolean indicating if the account has participation.
     */
    function hasParticipation(address account_, uint256 periodId_) external view returns (bool) {
        return _periodParticipation[account_][periodId_];
    }

    /**
     * @notice Sets the payment receiver address.
     * @param receiver_ The address to receive payments.
     */
    function setPaymentReceiver(address receiver_) external onlyOwner {
        require(receiver_ != address(0), "Payment receiver can not be zero address");
        paymentReceiver = receiver_;
        emit PaymentReceiverUpdate(receiver_);
    }

    /**
     * @notice Sets the ticket minter address.
     * @param minter_ The address authorized to mint tickets.
     */
    function setTicketMinter(address minter_) external onlyOwner {
        require(minter_ != address(0), "Minter address can not be zero");
        ticketMinter = minter_;
        emit TicketMinterUpdate(minter_);
    }

    /**
     * @notice Checks if tickets can be bought for the specified competition and period.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return A boolean indicating if tickets can be bought.
     */
    function canTicketBuy(uint256 periodId, uint256 competitionId) external view returns (bool) {
        if (!isCompetitionSettingsDefined(periodId, competitionId)) {
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

    /**
     * @notice Gets the competition allocation for an account.
     * @param account The account for which to get the allocation.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The allocation details.
     */
    function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (Allocation memory) {
        return _getAllocation(account, periodId, competitionId);
    }

    /**
     * @notice Sets the staking contract address.
     * @param stakingContract_ The address of the staking contract.
     */
    function setStakingContract(address stakingContract_) external onlyOwner {
        require(address(stakingContract_) != address(0), "ZizyComp: Staking contract address can not be zero");
        stakingContract = IZizyCompetitionStaking(stakingContract_);
        emit StakingContractUpdate(stakingContract_);
    }

    /**
     * @notice Sets the ticket deployer contract address.
     * @param ticketDeployer_ The address of the ticket deployer contract.
     */
    function setTicketDeployer(address ticketDeployer_) external onlyOwner {
        require(address(ticketDeployer_) != address(0), "ZizyComp: Ticket deployer contract address can not be zero");
        ticketDeployer = ITicketDeployer(ticketDeployer_);
        emit TicketDeployerUpdate(ticketDeployer_);
    }

    /**
     * @notice Sets the active period.
     * @param periodId The ID of the period to set as active.
     */
    function setActivePeriod(uint periodId) external stakeContractIsSet onlyOwner {
        uint256 oldPeriod = activePeriod;
        require(oldPeriod != periodId, "This period already active");
        Period memory period = _periods[periodId];
        require(period._exist, "Period does not exist");
        require(!period.isOver, "This period is over");

        (uint256 response) = stakingContract.setPeriodId(periodId);
        require(response == periodId, "ZizyComp: Staking contract period can't updated");

        // Set previous period is over !
        if (oldPeriod != 0) {
            _periods[oldPeriod].isOver = true;
        }

        activePeriod = periodId;

        emit ActivePeriodUpdate(periodId);
    }

    /**
     * @notice Creates a competition period.
     * @param newPeriodId The ID of the new period.
     * @param startTime_ The start time of the period.
     * @param endTime_ The end time of the period.
     * @param ticketBuyStart_ The start time for ticket buying.
     * @param ticketBuyEnd_ The end time for ticket buying.
     * @return The ID of the new period.
     */
    function createPeriod(uint newPeriodId, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external stakeContractIsSet onlyOwner returns (uint256) {
        require(newPeriodId > 0, "New period id should be higher than zero");
        require(!_periods[newPeriodId]._exist, "Period id already exist");

        _periods[newPeriodId] = Period(startTime_, endTime_, ticketBuyStart_, ticketBuyEnd_, 0, false, true);

        totalPeriodCount++;

        emit NewPeriod(newPeriodId);

        return newPeriodId;
    }

    /**
     * @notice Updates the date ranges of a period.
     * @param periodId_ The ID of the period to update.
     * @param startTime_ The new start time of the period.
     * @param endTime_ The new end time of the period.
     * @param ticketBuyStart_ The new start time for ticket buying.
     * @param ticketBuyEnd_ The new end time for ticket buying.
     * @return A boolean indicating if the update was successful.
     */
    function updatePeriod(uint periodId_, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external onlyOwner returns (bool) {
        Period storage period = _periods[periodId_];
        require(period._exist, "There is no period exist");

        period.startTime = startTime_;
        period.endTime = endTime_;
        period.ticketBuyStartTime = ticketBuyStart_;
        period.ticketBuyEndTime = ticketBuyEnd_;

        emit PeriodUpdate(periodId_);

        return true;
    }

    /**
     * @notice Creates a competition for the current period.
     * @param periodId The ID of the current period.
     * @param competitionId The ID of the competition to create.
     * @param name_ The name of the competition ticket.
     * @param symbol_ The symbol of the competition ticket.
     * @return The address and IDs of the created competition.
     */
    function createCompetition(uint periodId, uint256 competitionId, string memory name_, string memory symbol_) external ticketDeployerIsSet onlyOwner returns (address, uint256, uint256) {
        Period memory period = _periods[periodId];
        require(period._exist, "Period does not exist");
        require(!period.isOver, "This period is over");

        require(!_periodCompetitions[periodId][competitionId]._exist, "Competition already exist");

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

    /**
     * @notice Sets the payment settings for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param token The address of the token to be used for payment.
     * @param ticketPrice The price of each ticket.
     */
    function setCompetitionPayment(uint256 periodId, uint256 competitionId, address token, uint ticketPrice) external onlyOwner {
        require(token != address(0), "Payment token can not be zero address");
        require(ticketPrice > 0, "Ticket price can not be zero");

        Competition storage comp = _periodCompetitions[periodId][competitionId];
        comp.pairDefined = true;
        comp.sellToken = token;
        comp.ticketPrice = ticketPrice;

        emit PaymentConfigUpdate(periodId, competitionId, token, ticketPrice);
    }

    /**
     * @notice Sets the snapshot range for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param min The minimum snapshot value.
     * @param max The maximum snapshot value.
     */
    function setCompetitionSnapshotRange(uint256 periodId, uint256 competitionId, uint min, uint max) external stakeContractIsSet onlyOwner {
        require(min <= max, "Min should be higher");
        (uint periodMin, uint periodMax) = stakingContract.getPeriodSnapshotRange(periodId);
        require(min >= periodMin && max <= periodMax, "Range should between period snapshot ranges");
        Competition storage comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist, "There is no competition");

        comp.snapshotMin = min;
        comp.snapshotMax = max;

        emit SnapshotRangesUpdate(periodId, competitionId, min, max);
    }

    /**
     * @notice Sets the tiers for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param mins The array of minimum values for each tier.
     * @param maxs The array of maximum values for each tier.
     * @param allocs The array of allocations for each tier.
     */
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

        emit TiersUpdate(periodId, competitionId);
    }

    /**
     * @notice Buys tickets for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param ticketCount The number of tickets to buy.
     */
    function buyTicket(uint256 periodId, uint256 competitionId, uint32 ticketCount) external paymentReceiverIsSet nonReentrant {
        require(ticketCount > 0, "Requested ticket count should be higher than zero");
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp.pairDefined, "Ticket sell pair is not defined");
        require((comp.ticketSold + ticketCount) <= MAX_TICKET_PER_COMPETITION, "Tickets are out of stock for this competition");

        Allocation memory alloc = _getAllocation(_msgSender(), periodId, competitionId);

        // Store calculated competition allocation
        if (alloc.hasAllocation && !_allocations[_msgSender()][periodId][competitionId].hasAllocation) {
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

    /**
     * @notice Mints and sends a ticket to an address.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param to_ The address to receive the ticket.
     * @param ticketId_ The ID of the ticket to mint.
     */
    function mintTicket(uint256 periodId, uint256 competitionId, address to_, uint256 ticketId_) external onlyMinter {
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist, "Competition does not exist");
        bool ticketPaused = comp.ticket.paused();

        Allocation memory alloc = _getAllocation(to_, periodId, competitionId);
        uint accountTicketBalance = comp.ticket.balanceOf(to_);
        require((accountTicketBalance + 1) <= alloc.bought, "Maximum ticket allocation bought");

        // Un-pause if ticket is paused
        if (ticketPaused) {
            comp.ticket.unpause();
        }

        comp.ticket.mint(to_, ticketId_);

        // Pause if ticket is paused
        if (ticketPaused) {
            comp.ticket.pause();
        }

        emit TicketSend(to_, periodId, competitionId, ticketId_);
    }

    /**
     * @notice Mints and sends a batch of tickets to an address.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param to_ The address to receive the tickets.
     * @param ticketIds The array of ticket IDs to mint.
     */
    function mintBatchTicket(uint256 periodId, uint256 competitionId, address to_, uint256[] calldata ticketIds) external onlyMinter {
        uint length = ticketIds.length;
        require(length > 0, "Ticket ids length should be higher than zero");

        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist, "Competition does not exist");
        bool ticketPaused = comp.ticket.paused();

        Allocation memory alloc = _getAllocation(to_, periodId, competitionId);
        uint accountTicketBalance = comp.ticket.balanceOf(to_);
        require((accountTicketBalance + length) <= alloc.bought, "Maximum ticket allocation bought");

        // Un-pause if ticket is paused
        if (ticketPaused) {
            comp.ticket.unpause();
        }

        for (uint i = 0; i < length; ++i) {
            uint256 mintTicketId = ticketIds[i];
            comp.ticket.mint(to_, mintTicketId);
            emit TicketSend(to_, periodId, competitionId, mintTicketId);
        }

        // Pause if ticket is paused
        if (ticketPaused) {
            comp.ticket.pause();
        }
    }

    /**
     * @notice Gets the details of a period.
     * @param periodId The ID of the period.
     * @return The details of the period.
     */
    function getPeriod(uint256 periodId) external view returns (Period memory) {
        return _periods[periodId];
    }

    /**
     * @notice Gets the details of a competition within a period.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The details of the competition.
     */
    function getPeriodCompetition(uint256 periodId, uint256 competitionId) external view returns (Competition memory) {
        return _periodCompetitions[periodId][competitionId];
    }

    /**
     * @notice Gets the count of competitions within a period.
     * @param periodId The ID of the period.
     * @return The count of competitions.
     */
    function getPeriodCompetitionCount(uint256 periodId) external view returns (uint) {
        return _periods[periodId].competitionCount;
    }

    /**
     * @notice Pauses the transfers of tickets for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     */
    function pauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).pause();
    }

    /**
     * @notice Unpauses the transfers of tickets for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     */
    function unpauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).unpause();
    }

    /**
     * @notice Sets the base URI for a competition ticket contract.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param baseUri_ The new base URI.
     */
    function setCompetitionBaseURI(uint256 periodId, uint256 competitionId, string memory baseUri_) external onlyOwner {
        address ticketAddr = _compTicket(periodId, competitionId);
        IZizyCompetitionTicket(ticketAddr).setBaseURI(baseUri_);
    }

    /**
     * @notice Gets the total supply of tickets for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The total supply of tickets.
     */
    function totalSupplyOfCompetition(uint256 periodId, uint256 competitionId) external view returns (uint256) {
        address ticketAddr = _compTicket(periodId, competitionId);
        return IZizyCompetitionTicket(ticketAddr).totalSupply();
    }

    /**
     * @notice Checks if the competition ticket buy settings are defined.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return A boolean indicating if the competition settings are defined.
     */
    function isCompetitionSettingsDefined(uint256 periodId, uint256 competitionId) public view returns (bool) {
        Competition memory comp = _periodCompetitions[periodId][competitionId];

        // Check competition
        if (!comp._exist) {
            return false;
        }
        // Check competition tiers
        if (!_isCompetitionTiersDefined(periodId, competitionId)) {
            return false;
        }
        // Check sellToken & price
        if (!comp.pairDefined) {
            return false;
        }

        return true;
    }

    /**
     * @notice Generates the hash of the period competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The hash of the period competition.
     */
    function _competitionKey(uint256 periodId, uint256 competitionId) internal pure returns (bytes32) {
        return keccak256(abi.encode(periodId, competitionId));
    }

    /**
     * @notice Gets the competition allocation for an account.
     * @param account The account for which to get the allocation.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The allocation details.
     */
    function _getAllocation(address account, uint256 periodId, uint256 competitionId) internal stakeContractIsSet view returns (Allocation memory) {
        Allocation memory alloc = _allocations[account][periodId][competitionId];
        if (alloc.hasAllocation) {
            return alloc;
        }

        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp.snapshotMin > 0 && comp.snapshotMax > 0 && comp.snapshotMin <= comp.snapshotMax, "Competition snapshot ranges is not defined");
        (uint256 average, bool _calculated) = stakingContract.getPeriodSnapshotsAverage(account, periodId, comp.snapshotMin, comp.snapshotMax);

        require(_calculated, "Period snapshot averages does not calculated !");

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

    /**
     * @notice Checks if the competition tiers are defined.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return A boolean indicating if the competition tiers are defined.
     */
    function _isCompetitionTiersDefined(uint256 periodId, uint256 competitionId) internal view returns (bool) {
        bytes32 compHash = _competitionKey(periodId, competitionId);
        return (_compTiers[compHash].length > 0);
    }

    /**
     * @notice Gets the ticket contract address for a competition within a period.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The address of the ticket contract.
     */
    function _compTicket(uint256 periodId, uint256 competitionId) internal view returns (address) {
        Competition memory comp = _periodCompetitions[periodId][competitionId];
        require(comp._exist, "ZizyComp: Competition does not exist");
        return address(comp.ticket);
    }
}
