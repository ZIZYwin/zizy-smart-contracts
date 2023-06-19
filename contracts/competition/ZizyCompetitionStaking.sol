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
    uint256 private snapshotId;

    // Total staked token balance
    uint256 public totalStaked;

    // Cooling off delay time
    uint256 public coolingDelay;

    // Coolest delay for unstake
    uint256 public coolestDelay;

    // Cooling off percentage
    uint8 public coolingPercentage;

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
    // Total staked snapshot
    mapping(uint256 => uint256) public totalStakedSnapshot;

    // Events
    event StakeFeePercentageUpdated(uint8 newPercentage);
    event StakeFeeReceived(uint256 amount, uint256 snapshotId, uint256 periodId);
    event UnStakeFeeReceived(uint256 amount, uint256 snapshotId, uint256 periodId);
    event SnapshotCreated(uint256 id, uint256 periodId);
    event Stake(address account, uint256 amount, uint256 fee, uint256 snapshotId, uint256 periodId);
    event UnStake(address account, uint256 amount, uint256 snapshotId, uint256 periodId);
    event CoolingOffSettingsUpdated(uint8 percentage, uint8 coolingDay, uint8 coolestDay);

    // Modifiers
    modifier onlyCallFromFactory() {
        require(_msgSender() == competitionFactory, "Only call from factory");
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

        stakeFeePercentage = 3;
        currentPeriod = 0;
        snapshotId = 0;
        coolingDelay = 10 * 24 * 60 * 60;
        coolestDelay = 20 * 24 * 60 * 60;
        coolingPercentage = 10;

        stakeToken = IERC20Upgradeable(stakeToken_);
        feeAddress = feeReceiver_;
    }

    // Get snapshot ID
    function getSnapshotId() public view returns (uint) {
        return snapshotId;
    }

    // Update un-stake cooling off settings
    function updateCoolingOffSettings(uint8 percentage_, uint8 coolingDay_, uint8 coolestDay_) external onlyOwner {
        require(percentage_ >= 0 && percentage_ <= 100, "Percentage should be in 0-100 range");
        coolingPercentage = percentage_;
        coolingDelay = (uint256(coolingDay_) * 24 * 60 * 60);
        coolestDelay = (uint256(coolestDay_) * 24 * 60 * 60);
        emit CoolingOffSettingsUpdated(percentage_, coolingDay_, coolestDay_);
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
        totalStakedSnapshot[currentSnapshot] = totalStaked;
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
        (, , , , , , bool exist) = _getPeriod(periodId);

        require(exist == true, "No active period exist");

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
        uint256 currentBalance = balanceOf(_msgSender());
        uint256 currentSnapshot = snapshotId;
        uint256 periodId = currentPeriod;
        require(amount_ <= token.balanceOf(_msgSender()), "Insufficient balance");
        require(amount_ <= token.allowance(_msgSender(), address(this)), "Insufficient allowance amount for stake");

        // Transfer tokens from callee to contract
        token.safeTransferFrom(_msgSender(), address(this), amount_);

        // Calculate fee [(A * P) / 100]
        uint256 stakeFee = (amount_ * stakeFeePercentage) / 100;
        // Stake amount [A - C]
        uint256 stakeAmount = amount_ - stakeFee;

        // Increase caller balance
        balances[_msgSender()] += stakeAmount;

        // Send stake fee to receiver address if exist
        if (stakeFee > 0) {
            token.safeTransfer(address(feeAddress), stakeFee);
            emit StakeFeeReceived(stakeFee, currentSnapshot, periodId);
        }

        totalStaked += stakeAmount;

        // Update account details
        updateDetails(_msgSender(), currentBalance, balanceOf(_msgSender()));
        // Emit Stake Event
        emit Stake(_msgSender(), stakeAmount, stakeFee, currentSnapshot, periodId);
    }

    // Get period from factory
    function _getPeriod(uint256 periodId_) internal view returns (uint, uint, uint, uint, uint16, bool, bool) {
        return ICompetitionFactory(competitionFactory).getPeriod(periodId_);
    }

    // Calculate un-stake free amount / cooling off fee amount
    function calculateUnStakeAmounts(uint requestAmount_) public view returns (uint, uint) {
        (uint startTime, , , , , , bool exist) = _getPeriod(currentPeriod);
        uint timestamp = block.timestamp;
        uint CD = coolingDelay;
        uint CSD = coolestDelay;
        uint percentage = coolingPercentage;

        uint fee_ = 0;
        uint amount_ = requestAmount_;

        // Unstake all if period does not exist or cooling delays isn't defined
        if (!exist || (CD == 0 && CSD == 0)) {
            return (fee_, amount_);
        }

        if (timestamp < (startTime + CSD) || startTime >= timestamp) {
            // In coolest period
            fee_ = (requestAmount_ * percentage) / 100;
            amount_ = requestAmount_ - fee_;
        } else if (timestamp >= (startTime + CSD) && timestamp <= (startTime + CSD + CD)) {
            // In cooling period
            uint LCB = (requestAmount_ * percentage) / 100;
            uint RF = ((timestamp - (startTime + CSD)) * LCB / CD);

            amount_ = (requestAmount_ - (LCB - RF));
            fee_ = requestAmount_ - amount_;
        } else {
            // Account can unstake his all balance
            fee_ = 0;
            amount_ = requestAmount_;
        }

        return (fee_, amount_);
    }

    // Un-stake tokens
    function unStake(uint256 amount_) external whenFeeAddressExist {
        uint256 currentBalance = balanceOf(_msgSender());
        uint256 currentSnapshot = snapshotId;
        uint256 periodId = currentPeriod;
        require(amount_ <= currentBalance, "Insufficient balance for unstake");
        require(amount_ > 0, "Amount should higher than zero");

        IERC20Upgradeable token = stakeToken;

        balances[_msgSender()] = balances[_msgSender()].sub(amount_);
        (uint fee, uint free) = calculateUnStakeAmounts(amount_);

        // Update account details
        updateDetails(_msgSender(), currentBalance, balanceOf(_msgSender()));

        totalStaked -= amount_;

        // Distribute fee receiver & smart burn
        _unStakeFeeTransfer(fee, currentSnapshot, periodId);

        // Transfer free tokens to user
        token.safeTransfer(_msgSender(), free);

        // Emit UnStake Event
        emit UnStake(_msgSender(), amount_, currentSnapshot, periodId);
    }

    // Transfer unstake fees
    function _unStakeFeeTransfer(uint256 amount, uint256 snapshotId_, uint256 periodId) internal {
        if (amount <= 0) {
            return;
        }
        IERC20Upgradeable tokenSafe = stakeToken;

        tokenSafe.safeTransfer(address(feeAddress), amount);
        emit UnStakeFeeReceived(amount, snapshotId_, periodId);
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

    // Get snapshot average (Using on stake rewards)
    function getSnapshotAverage(address account, uint256 min, uint256 max) public view returns (uint) {
        uint currentSnapshot = snapshotId;

        require(min <= max, "Max should be equal or higher than max");
        require(max <= currentSnapshot, "Max should be equal or lower than current snapshot");

        ActivityDetails memory details = activityDetails[account];

        // If account hasn't stake activity after `min` snapshot, return last activity balance
        if (details.lastSnapshotId <= min) {
            return details.lastActivityBalance;
        }

        uint stakeSum = 0;
        uint unknownCounter = 0;
        uint lastBalance = 0;
        bool shift = false;

        // Get sum of snapshot stakes
        for (uint i = min; i <= max; ++i) {
            Snapshot memory shot = snapshots[account][i];

            if (shot._exist == false) {
                // Snapshot data does not exist
                if (shift == false) {
                    unknownCounter++;
                } else {
                    stakeSum += (unknownCounter + 1) * lastBalance;
                    unknownCounter = 0;
                }
            } else {
                // Snapshot data is exist
                lastBalance = shot.balance;
                stakeSum += lastBalance;
            }
        }

        if (unknownCounter > 0) {
            // Scan any stake activity from max to currentSnapshotId
            for (uint i = (max + 1); i <= currentSnapshot; ++i) {
                Snapshot memory shot = snapshots[account][i];
                if (shot._exist == true) {
                    stakeSum += (unknownCounter * shot.prevSnapshotBalance);
                    unknownCounter = 0;
                    break;
                }
            }

            // If never activity found until `scanMax`, then average = balanceOf()
            stakeSum += (unknownCounter * balanceOf(account));
            unknownCounter = 0;
        }

        return (stakeSum / (max - min + 1));
    }

    // Get period snapshot average with min/max range
    function getPeriodSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool) {
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
        (, bool calculated) = _getPeriodStakeAverage(_msgSender(), periodId);

        require(calculated == false, "Already calculated");

        uint256 total = 0;

        Period memory _period = periods[periodId];

        uint256 shotBalance = 0;
        uint256 nextIB = 0;
        bool shift = false;
        uint256 firstSnapshot = _period.firstSnapshotId;
        uint256 lastSnapshot = snapshotId;

        for (uint i = lastSnapshot; i >= firstSnapshot; --i) {
            Snapshot memory shot = snapshots[_msgSender()][i];

            // Update snapshot balance
            if (i == lastSnapshot) {
                shotBalance = balances[_msgSender()];
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

            snapshots[_msgSender()][i] = shot;
        }

        averages[_msgSender()][periodId] = PeriodStakeAverage((total / (lastSnapshot - firstSnapshot + 1)), true);
    }
}
