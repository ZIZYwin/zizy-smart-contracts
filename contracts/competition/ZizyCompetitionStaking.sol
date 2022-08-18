// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../utils/IERC20.sol";
import "./ICompetitionFactory.sol";

// @dev We building sth big. Stay tuned!
contract ZizyCompetitionStaking is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    // Structs
    struct Snapshot {
        uint256 balance;
        uint256 prevSnapshotBalance;
        bool _exist;
    }

    struct Period {
        uint256 firstSnapshotId;
        uint256 lastSnapshotId;
        bool isOver;
        bool _exist;
    }

    struct ActivityDetails {
        uint256 lastSnapshotId;
        uint256 lastActivityBalance;
        bool _exist;
    }

    struct PeriodStakeAverage {
        uint256 average;
        bool _calculated;
    }

    // Smart burn supply limit
    uint256 constant SMART_BURN_SUPPLY_LIMIT = 250_000_000_000_000_00;

    // Stake token address [Zizy]
    IERC20Upgradeable public stakeToken;

    // Competition factory contract
    address public competitionFactory;

    // Stake fee percentage
    uint8 public stakeFeePercentage;

    // Fee receiver address
    address public feeAddress;

    // Current period number
    uint256 public currentPeriod;

    // Current snapshot id
    uint256 public snapshotId;

    // Total staked token balance
    uint256 public totalStaked;

    // Cooling off delay time
    uint256 public coolingOffDelay;

    // Cooling off percentage
    uint8 public coolingOffPercentage;

    uint256 public smartBurned;

    // Stake balances for address
    mapping(address => uint256) private balances;
    // Account => SnapshotID => Snapshot
    mapping(address => mapping(uint256 => Snapshot)) private snapshots;
    // Account activity details
    mapping(address => ActivityDetails) private activityDetails;
    // Periods
    mapping(uint256 => Period) private periods;
    // Period staking averages
    mapping(address => mapping(uint256 => PeriodStakeAverage)) private averages;

    // Events
    event StakeFeePercentageUpdated(uint8 newPercentage);
    event StakeFeeReceived(uint256 amount);
    event UnStakeFeeReceived(uint256 amount);
    event SnapshotCreated(uint256 id, uint256 periodId);
    event Stake(address account, uint256 amount, uint256 fee);
    event UnStake(address account, uint256 amount);
    event CoolingOffSettingsUpdated(uint8 percentage, uint8 day);
    event SmartBurn(uint256 totalSupply, uint256 burnAmount);

    // Modifiers
    modifier onlyCallFromFactory() {
        require(msg.sender == competitionFactory, "Only call from factory");
        _;
    }

    modifier whenFeeAddressExist() {
        require(feeAddress != address(0), "Fee address should be defined");
        _;
    }

    modifier whenPeriodExist() {
        uint256 periodId = currentPeriod;
        require(periodId > 0 && periods[periodId]._exist == true, "There is no period exist");
        _;
    }

    modifier whenCurrentPeriodInBuyStage() {
        uint ts = block.timestamp;
        (uint start, uint end, uint ticketBuyStart, uint ticketBuyEnd, , , bool exist) = _getPeriod(currentPeriod);
        require(exist == true, "Period does not exist");
        require(_isInRange(ts, start, end) && _isInRange(ts, ticketBuyStart, ticketBuyEnd), "Currently not in the range that can be calculated");
        _;
    }

    // Initializer
    function initialize(address stakeToken_, address feeReceiver_) external initializer {
        require(stakeToken_ != address(0), "Contract address can not be zero");

        __Ownable_init();

        stakeFeePercentage = 2;
        currentPeriod = 0;
        snapshotId = 0;
        coolingOffDelay = 15 * 24 * 60 * 60;
        coolingOffPercentage = 15;
        smartBurned = 0;

        stakeToken = IERC20Upgradeable(stakeToken_);
        feeAddress = feeReceiver_;
    }

    // Get current snapshot id
    function getSnapshotId() external view returns (uint256) {
        return snapshotId;
    }

    // Update un-stake cooling off settings
    function updateCoolingOffSettings(uint8 percentage_, uint8 day_) external onlyOwner {
        require(percentage_ >= 0 && percentage_ <= 100, "Percentage should be in 0-100 range");
        coolingOffPercentage = percentage_;
        coolingOffDelay = (uint256(day_) * 24 * 60 * 60);
        emit CoolingOffSettingsUpdated(percentage_, day_);
    }

    // Get activity details for account
    function getActivityDetails(address account) external view returns (ActivityDetails memory) {
        return activityDetails[account];
    }

    // Get snapshot
    function getSnapshot(address account, uint256 snapshotId_) external view returns (Snapshot memory) {
        return snapshots[account][snapshotId_];
    }

    // Get period
    function getPeriod(uint256 periodId_) external view returns (Period memory) {
        return periods[periodId_];
    }

    // Get period snapshot range
    function getPeriodSnapshotRange(uint256 periodId) external view returns (uint, uint) {
        Period memory period = periods[periodId];
        require(period._exist == true, "Period does not exist");

        uint min = period.firstSnapshotId;
        uint max = (period.lastSnapshotId == 0 ? snapshotId : period.lastSnapshotId);

        return (min, max);
    }

    // BalanceOf - Account
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    // Increase snapshot counter
    function _snapshot() internal {
        uint256 currentSnapshot = snapshotId;
        snapshotId++;
        emit SnapshotCreated(currentSnapshot, currentPeriod);
    }

    // Check number is in range
    function _isInRange(uint number, uint min, uint max) internal pure returns (bool) {
        require(min <= max, "Min can not be higher than max");
        return (number >= min && number <= max);
    }

    // Take snapshot
    function snapshot() external onlyOwner {
        uint256 periodId = currentPeriod;
        uint ts = block.timestamp;
        (uint start, uint end, uint ticketBuyStart, uint ticketBuyEnd, , , bool exist) = _getPeriod(periodId);

        require(exist == true, "No active period exist");
        require(_isInRange(ts, start, end) && ts < ticketBuyStart && ts < ticketBuyEnd, "Snapshot can't taken for now");

        _snapshot();
    }

    // Set period number
    function setPeriodId(uint256 period) external onlyCallFromFactory returns (uint256) {
        uint256 prevPeriod = currentPeriod;
        uint256 currentSnapshot = snapshotId;
        currentPeriod = period;

        if (periods[prevPeriod]._exist == true) {
            // Set last snapshot of previous period
            periods[prevPeriod].lastSnapshotId = currentSnapshot;
            periods[prevPeriod].isOver = true;
        }

        _snapshot();

        periods[period] = Period(snapshotId, 0, false, true);

        return period;
    }

    // Set competition factory contract address
    function setCompetitionFactory(address competitionFactory_) external onlyOwner {
        require(address(competitionFactory_) != address(0), "Competition factory address can not be zero");
        competitionFactory = competitionFactory_;
    }

    // Set stake fee percentage ratio between 0 and 100
    function setStakeFeePercentage(uint8 stakeFeePercentage_) external onlyOwner {
        require(stakeFeePercentage_ >= 0 && stakeFeePercentage_ < 100, "Fee percentage is not within limits");
        stakeFeePercentage = stakeFeePercentage_;
        emit StakeFeePercentageUpdated(stakeFeePercentage_);
    }

    // Set stake fee address
    function setFeeAddress(address feeAddress_) external onlyOwner {
        require(feeAddress_ != address(0), "Fee address can not be zero");
        feeAddress = feeAddress_;
    }

    // Update account details
    function updateDetails(address account, uint256 previousBalance, uint256 currentBalance) internal {
        uint256 currentSnapshotId = snapshotId;
        ActivityDetails storage details = activityDetails[account];
        Snapshot storage currentSnapshot = snapshots[account][currentSnapshotId];

        // Update current snapshot balance
        currentSnapshot.balance = currentBalance;
        if (currentSnapshot._exist == false) {
            currentSnapshot.prevSnapshotBalance = previousBalance;
            currentSnapshot._exist = true;
        }

        // Update account details
        details.lastSnapshotId = currentSnapshotId;
        details.lastActivityBalance = currentBalance;
        if (details._exist == false) {
            details._exist = true;
        }
    }

    // Stake tokens
    function stake(uint256 amount_) external whenPeriodExist whenFeeAddressExist {
        IERC20Upgradeable token = stakeToken;
        uint256 currentBalance = balanceOf(msg.sender);
        require(amount_ <= token.balanceOf(msg.sender), "Insufficient balance");
        require(amount_ <= token.allowance(msg.sender, address(this)), "Insufficient allowance amount for stake");

        // Transfer tokens from callee to contract
        token.safeTransferFrom(msg.sender, address(this), amount_);

        // Calculate fee [(A * P) / 100]
        uint256 stakeFee = (amount_ * stakeFeePercentage) / 100;
        // Stake amount [A - C]
        uint256 stakeAmount = amount_ - stakeFee;

        // Increase caller balance
        balances[msg.sender] += stakeAmount;

        // Send stake fee to receiver address if exist
        if (stakeFee > 0) {
            token.safeTransfer(address(feeAddress), stakeFee);
            emit StakeFeeReceived(stakeFee);
        }

        totalStaked += stakeAmount;

        // Update account details
        updateDetails(msg.sender, currentBalance, balanceOf(msg.sender));
        // Emit Stake Event
        emit Stake(msg.sender, stakeAmount, stakeFee);
    }

    // Get period from factory
    function _getPeriod(uint256 periodId_) internal view returns (uint, uint, uint, uint, uint16, bool, bool) {
        return ICompetitionFactory(competitionFactory).getPeriod(periodId_);
    }

    // Calculate un-stake free amount / cooling off fee amount
    function calculateUnStakeAmounts(uint requestAmount_) public view returns (uint, uint) {
        (uint startTime, , , , , , bool exist) = _getPeriod(currentPeriod);
        uint timestamp = block.timestamp;
        uint ET = coolingOffDelay;
        bool inCoolingOffPeriod = (block.timestamp < (startTime + ET));

        uint fee_ = 0;
        uint amount_ = requestAmount_;

        if (!exist || !inCoolingOffPeriod || startTime >= timestamp || ET == 0) {
            fee_ = 0;
            amount_ = requestAmount_;
        } else {
            uint NT = timestamp - startTime;
            uint CB = (requestAmount_ * coolingOffPercentage) / 100;

            amount_ = (requestAmount_ - CB) + (NT * CB / ET);
            fee_ = requestAmount_ - amount_;
        }

        return (fee_, amount_);
    }

    // Un-stake tokens
    function unStake(uint256 amount_) external whenFeeAddressExist {
        uint256 currentBalance = balanceOf(msg.sender);
        require(amount_ <= currentBalance, "Insufficient balance for unstake");
        require(amount_ > 0, "Amount should higher than zero");

        IERC20Upgradeable token = stakeToken;

        balances[msg.sender] = balances[msg.sender].sub(amount_);
        (uint fee, uint free) = calculateUnStakeAmounts(amount_);

        // Update account details
        updateDetails(msg.sender, currentBalance, balanceOf(msg.sender));

        totalStaked -= amount_;

        // Distribute fee receiver & smart burn
        if (fee > 0) {
            _distributeFee(fee);
        }

        // Transfer free tokens to user
        token.safeTransfer(msg.sender, free);

        // Emit UnStake Event
        emit UnStake(msg.sender, amount_);
    }

    // Burn half of tokens, send remainings
    function _distributeFee(uint256 amount) internal {
        IERC20Upgradeable tokenSafe = stakeToken;
        IERC20 token = IERC20(address(stakeToken));
        uint256 supply = token.totalSupply();

        uint256 burnAmount = amount / 2;
        uint256 leftAmount = amount - burnAmount;

        if ((supply - burnAmount) < SMART_BURN_SUPPLY_LIMIT) {
            burnAmount = (supply % SMART_BURN_SUPPLY_LIMIT);
            leftAmount = amount - burnAmount;
        }

        _smartBurn(token, supply, burnAmount);
        _feeTransfer(tokenSafe, leftAmount);
    }

    // Transfer token to receiver with given amount
    function _feeTransfer(IERC20Upgradeable token, uint256 amount) internal {
        if (amount <= 0) {
            return;
        }

        token.safeTransfer(address(feeAddress), amount);
        emit UnStakeFeeReceived(amount);
    }

    // Burn given token with given amount
    function _smartBurn(IERC20 token, uint256 supply, uint256 burnAmount) internal {
        if (burnAmount <= 0) {
            return;
        }

        token.burn(burnAmount);
        smartBurned += burnAmount;

        emit SmartBurn((supply - burnAmount), burnAmount);
    }

    // Get period stake average information
    function _getPeriodStakeAverage(address account, uint256 periodId) internal view returns (uint256, bool) {
        PeriodStakeAverage memory avg = averages[account][periodId];
        return (avg.average, avg._calculated);
    }

    // Get period stake average information
    function getPeriodStakeAverage(address account, uint256 periodId) external view returns (uint256, bool) {
        return _getPeriodStakeAverage(account, periodId);
    }

    // Get snapshot average with min/max range
    function getSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool) {
        require(min <= max, "Min should be higher");
        uint256 currentSnapshotId = snapshotId;
        Period memory period = periods[periodId];
        PeriodStakeAverage memory avg = averages[account][periodId];

        // Return if current period average isn't calculated
        if (avg._calculated == false) {
            return (0, false);
        }

        uint maxSnapshot = (period.lastSnapshotId == 0 ? currentSnapshotId : period.lastSnapshotId);

        require(max <= maxSnapshot, "Range max should be lower than current snapshot or period last snapshot");
        require(min >= period.firstSnapshotId && min <= maxSnapshot, "Range min should be higher period first snapshot id");

        uint total = 0;
        uint sCount = (max - min + 1);

        // If the period average is calculated, all storage variables will be filled.
        for (uint i = min; i <= max; ++i) {
            total += snapshots[account][i].balance;
        }

        return ((total / sCount), true);
    }

    // Calculate period stake average for account
    function calculatePeriodStakeAverage() public whenPeriodExist whenCurrentPeriodInBuyStage {
        uint256 periodId = currentPeriod;
        (, bool calculated) = _getPeriodStakeAverage(msg.sender, periodId);

        require(calculated == false, "Already calculated");

        uint256 total = 0;

        Period memory _period = periods[periodId];

        uint256 shotBalance = 0;
        uint256 nextIB = 0;
        bool shift = false;
        uint256 firstSnapshot = _period.firstSnapshotId;
        uint256 lastSnapshot = snapshotId;

        for (uint i = lastSnapshot; i >= firstSnapshot; --i) {
            Snapshot memory shot = snapshots[msg.sender][i];

            // Update snapshot balance
            if (i == lastSnapshot) {
                shotBalance = balances[msg.sender];
            } else if (shot._exist == true) {
                shotBalance = shot.balance;
                nextIB = shot.prevSnapshotBalance;
                shift = true;
            } else {
                if (shift) {
                    shotBalance = nextIB;
                    nextIB = 0;
                    shift = false;
                }
            }

            total += shotBalance;
            shot.balance = shotBalance;
            shot._exist = true;

            snapshots[msg.sender][i] = shot;
        }

        averages[msg.sender][periodId] = PeriodStakeAverage((total / (lastSnapshot - firstSnapshot + 1)), true);
    }
}
