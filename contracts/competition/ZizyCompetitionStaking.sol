// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./ICompetitionFactory.sol";

// @dev We building sth big. Stay tuned!
contract ZizyCompetitionStaking is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @notice Struct for stake snapshots
    struct Snapshot {
        uint256 balance;
        uint256 prevSnapshotBalance;
        bool _exist;
    }

    /// @notice Struct for period & snapshot range
    struct Period {
        uint256 firstSnapshotId;
        uint256 lastSnapshotId;
        bool isOver;
        bool _exist;
    }

    /// @notice Struct for account activity details
    struct ActivityDetails {
        uint256 lastSnapshotId;
        uint256 lastActivityBalance;
        bool _exist;
    }

    /// @notice Struct for period stake average
    struct PeriodStakeAverage {
        uint256 average;
        bool _calculated;
    }

    /// @notice The address of the stake token used for staking (ZIZY)
    IERC20Upgradeable public stakeToken;

    /// @notice The address of the competition factory contract
    address public competitionFactory;

    /// @notice The percentage of stake fee deducted from staked tokens
    uint8 public stakeFeePercentage;

    /// @notice The address that receives the stake/unstake fees
    address public feeAddress;

    /// @notice The current period number
    uint256 public currentPeriod;

    /// @notice The current snapshot ID
    uint256 private snapshotId;

    /// @notice The total balance of staked tokens
    uint256 public totalStaked;

    /// @notice The delay time for the cooling off period after staking
    uint256 public coolingDelay;

    /// @notice The coolest delay time after staking
    uint256 public coolestDelay;

    /// @notice The percentage of tokens that enter the cooling off period after staking
    uint8 public coolingPercentage;

    /// @notice Stake/Unstake lock mechanism moderator
    address public lockModerator;

    // @notice Un-stake time locks for accounts
    mapping(address => uint) private timeLocks;

    // @notice Stake balances for each address
    mapping(address => uint256) private balances;

    // @dev Account snapshot details for each snapshot ID: [Account => SnapshotID => Snapshot]
    mapping(address => mapping(uint256 => Snapshot)) private snapshots;

    // @dev Account activity details for each address
    mapping(address => ActivityDetails) private activityDetails;

    // @dev Details of each period
    mapping(uint256 => Period) private periods;

    // @dev Stake averages for each address and period
    mapping(address => mapping(uint256 => PeriodStakeAverage)) private averages;

    // @notice Snapshot of total staked amount for each snapshot ID: [SnapshotID => StakeTotal]
    mapping(uint256 => uint256) public totalStakedSnapshot;

    /**
     * @notice Event emitted when the stake fee percentage is updated
     * @param newPercentage The new stake fee percentage
     */
    event StakeFeePercentageUpdated(uint8 newPercentage);

    /**
     * @notice Event emitted when stake fee is received
     * @param amount The amount of stake fee received
     * @param snapshotId The ID of the snapshot
     * @param periodId The ID of the period
     */
    event StakeFeeReceived(uint256 amount, uint256 snapshotId, uint256 periodId);

    /**
     * @notice Event emitted when unstake fee is received
     * @param amount The amount of unstake fee received
     * @param snapshotId The ID of the snapshot
     * @param periodId The ID of the period
     */
    event UnStakeFeeReceived(uint256 amount, uint256 snapshotId, uint256 periodId);

    /**
     * @notice Event emitted when a snapshot is created
     * @param id The ID of the snapshot
     * @param periodId The ID of the period
     */
    event SnapshotCreated(uint256 id, uint256 periodId);

    /**
     * @notice Event emitted when a stake is made
     * @param account The account that made the stake
     * @param amount The amount of tokens staked
     * @param fee The stake fee amount
     * @param snapshotId The ID of the snapshot
     * @param periodId The ID of the period
     */
    event Stake(address account, uint256 amount, uint256 fee, uint256 snapshotId, uint256 periodId);

    /**
     * @notice Event emitted when an unstake is made
     * @param account The account that made the unstake
     * @param amount The amount of tokens unstaked
     * @param snapshotId The ID of the snapshot
     * @param periodId The ID of the period
     */
    event UnStake(address account, uint256 amount, uint256 snapshotId, uint256 periodId);

    /**
     * @notice Event emitted when the cooling off settings are updated
     * @param percentage The new cooling off percentage
     * @param coolingDay The cooling off day value
     * @param coolestDay The coolest day value
     */
    event CoolingOffSettingsUpdated(uint8 percentage, uint8 coolingDay, uint8 coolestDay);

    /**
    * @notice Event emitted when the lock moderator updated
    * @param moderator Lock moderator address
    */
    event LockModeratorUpdated(address moderator);

    /**
    * @notice Event emitted when any account unstake time locked
    * @param account Locked account
    * @param lockTime Lock time
    */
    event UnstakeTimeLock(address account, uint lockTime);

    /**
     * @dev Emitted when the competition factory address updated
     * @param factoryAddress The address of competition factory
     */
    event CompFactoryUpdated(address factoryAddress);

    /**
     * @dev Emitted when the fee receiver address updated
     * @param receiver Fee receiver address
     */
    event FeeReceiverUpdated(address receiver);

    /**
     * @dev Emitted when any account period stake average calculated
     * @param account Account
     * @param periodId Period ID
     * @param average Average of period snapshots
     */
    event PeriodStakeAverageCalculated(address account, uint periodId, uint average);

    /**
     * @dev Modifier that allows the function to be called only from the competition factory contract
     */
    modifier onlyCallFromFactory() {
        require(_msgSender() == competitionFactory, "Only call from factory");
        _;
    }

    /**
     * @dev Modifier that checks if the fee address is defined
     */
    modifier whenFeeAddressExist() {
        require(feeAddress != address(0), "Fee address should be defined");
        _;
    }

    /**
     * @dev Modifier that checks if the current period exists
     */
    modifier whenPeriodExist() {
        uint256 periodId = currentPeriod;
        require(periodId > 0 && periods[periodId]._exist, "There is no period exist");
        _;
    }

    /**
     * @dev Modifier that checks caller is lock moderator
     */
    modifier onlyModerator() {
        require(_msgSender() == lockModerator, "Only moderators can call this function");
        _;
    }

    /**
     * @dev Modifier that checks if the current period is in the buy stage
     */
    modifier whenCurrentPeriodInBuyStage() {
        uint ts = block.timestamp;
        (uint start, uint end, uint ticketBuyStart, uint ticketBuyEnd, , , bool exist) = _getPeriod(currentPeriod);
        require(exist, "Period does not exist");
        require(_isInRange(ts, start, end) && _isInRange(ts, ticketBuyStart, ticketBuyEnd), "Currently not in the range that can be calculated");
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
     * @notice Initializes the contract with the specified parameters
     * @param stakeToken_ The address of the stake token
     * @param feeReceiver_ The address of the fee receiver
     *
     * @dev This function should be called only once during contract initialization.
     * It sets the stake token, fee receiver, and initializes other state variables.
     */
    function initialize(address stakeToken_, address feeReceiver_) external initializer {
        require(stakeToken_ != address(0) && feeReceiver_ != address(0), "Params cant be zero address");

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

    /**
     * @notice Sets the address of the lock moderator.
     * @param moderator The address of the new lock moderator.
     */
    function setLockModerator(address moderator) external onlyOwner {
        require(moderator != address(0), "Lock moderator cant be zero address");
        if (lockModerator != moderator) {
            lockModerator = moderator;
            emit LockModeratorUpdated(moderator);
        }
    }

    /**
     * @notice Set time lock for un-stake
     * @param account Lock account
     * @param lockTime Lock timer as second
     */
    function setTimeLock(address account, uint lockTime) external onlyModerator {
        require(account != address(0), "Account cant be zero address");
        require(lockTime > 0 && lockTime <= 300, "Lock time should between 0-5 minute");
        timeLocks[account] = (block.timestamp + lockTime);
        emit UnstakeTimeLock(account, lockTime);
    }

    /**
     * @notice Get time lock status of any account
     * @param account Account for check status
     */
    function isTimeLocked(address account) public view returns (bool) {
        uint unlockTime = timeLocks[account];
        return (unlockTime > block.timestamp);
    }

    /**
     * @notice Gets the current snapshot ID
     * @return The current snapshot ID
     *
     * @dev This function returns the ID of the current snapshot.
     */
    function getSnapshotId() external view returns (uint) {
        return snapshotId;
    }

    /**
     * @notice Updates the cooling off settings for un-staking
     * @param percentage_ The new percentage for cooling off
     * @param coolingDay_ The number of days for the cooling off period
     * @param coolestDay_ The number of days for the coolest off period
     *
     * @dev This function allows the contract owner to update the cooling off settings for un-staking.
     * The percentage should be in the range of 0 to 100.
     * The cooling off period is specified in number of days, which is converted to seconds.
     * The coolest off period is also specified in number of days, which is converted to seconds.
     * Emits a CoolingOffSettingsUpdated event with the new settings.
     */
    function updateCoolingOffSettings(uint8 percentage_, uint8 coolingDay_, uint8 coolestDay_) external onlyOwner {
        require(percentage_ <= 15, "Percentage should be in 0-20 range");
        coolingPercentage = percentage_;
        coolingDelay = (uint256(coolingDay_) * 24 * 60 * 60);
        coolestDelay = (uint256(coolestDay_) * 24 * 60 * 60);
        emit CoolingOffSettingsUpdated(percentage_, coolingDay_, coolestDay_);
    }

    /**
     * @notice Retrieves the activity details for an account
     * @param account The address of the account
     * @return The activity details for the specified account
     *
     * @dev This function allows to retrieve the activity details for a specific account.
     * Returns an ActivityDetails struct containing the details of the account's activity.
     */
    function getActivityDetails(address account) external view returns (ActivityDetails memory) {
        return activityDetails[account];
    }

    /**
     * @notice Retrieves a specific snapshot for an account
     * @param account The address of the account
     * @param snapshotId_ The ID of the snapshot
     * @return The snapshot for the specified account and snapshot ID
     *
     * @dev This function allows to retrieve a specific snapshot for a given account and snapshot ID.
     * Returns a Snapshot struct containing the details of the snapshot.
     */
    function getSnapshot(address account, uint256 snapshotId_) external view returns (Snapshot memory) {
        return snapshots[account][snapshotId_];
    }

    /**
     * @notice Retrieves the details of a specific period
     * @param periodId_ The ID of the period
     * @return The details of the specified period
     *
     * @dev This function allows to retrieve the details of a specific period.
     * Returns a Period struct containing the details of the period.
     */
    function getPeriod(uint256 periodId_) external view returns (Period memory) {
        return periods[periodId_];
    }

    /**
     * @notice Retrieves the snapshot range for a specific period
     * @param periodId The ID of the period
     * @return The minimum and maximum snapshot IDs for the specified period
     *
     * @dev This function allows to retrieve the snapshot range for a specific period.
     * It returns the minimum and maximum snapshot IDs for the specified period.
     */
    function getPeriodSnapshotRange(uint256 periodId) external view returns (uint, uint) {
        Period memory period = periods[periodId];
        require(period._exist, "Period does not exist");

        uint min = period.firstSnapshotId;
        uint max = (period.lastSnapshotId == 0 ? snapshotId : period.lastSnapshotId);

        return (min, max);
    }

    /**
     * @notice Retrieves the balance of staked tokens for a specific account
     * @param account The address of the account
     * @return The balance of tokens for the specified account
     *
     * @dev This function allows to retrieve the staked balance of tokens for a specific account.
     * It returns the number of tokens held by the specified account.
     */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Increases the snapshot counter
     *
     * @dev This internal function is used to increase the snapshot counter.
     * It increments the snapshotId and records the total staked balance for the current snapshot.
     * Emits a SnapshotCreated event with the current snapshot ID and the current period.
     */
    function _snapshot() internal {
        uint256 currentSnapshot = snapshotId;
        snapshotId++;
        totalStakedSnapshot[currentSnapshot] = totalStaked;
        emit SnapshotCreated(currentSnapshot, currentPeriod);
    }

    /**
     * @notice Checks if a number is within the specified range
     * @param number The number to check
     * @param min The minimum value of the range
     * @param max The maximum value of the range
     * @return A boolean indicating whether the number is within the range
     *
     * @dev This internal function is used to check if a given number is within the specified range.
     * It throws an error if the minimum value is higher than the maximum value.
     * Returns true if the number is greater than or equal to the minimum value and less than or equal to the maximum value.
     */
    function _isInRange(uint number, uint min, uint max) internal pure returns (bool) {
        require(min <= max, "Min can not be higher than max");
        return (number >= min && number <= max);
    }

    /**
     * @notice Takes a snapshot of the current state
     *
     * @dev This function is used to take a snapshot of the current state by increasing the snapshot counter.
     * It can only be called by the contract owner.
     * It checks if there is an active period and then calls the internal `_snapshot` function to increase the snapshot counter.
     */
    function snapshot() external onlyOwner {
        uint256 periodId = currentPeriod;
        (, , , , , , bool exist) = _getPeriod(periodId);

        require(exist, "No active period exist");

        _snapshot();
    }

    /**
     * @notice Sets the period number
     * @param period The period number to set
     * @return The period number that was set
     *
     * @dev This function is used to set the period number.
     * It can only be called by the competition factory contract.
     * It updates the current period, creates a new snapshot, and updates the period information.
     * If there was a previous active period, it sets the last snapshot of the previous period and marks it as over.
     */
    function setPeriodId(uint256 period) external onlyCallFromFactory returns (uint256) {
        uint256 prevPeriod = currentPeriod;
        uint256 currentSnapshot = snapshotId;
        currentPeriod = period;

        if (periods[prevPeriod]._exist) {
            // Set last snapshot of previous period
            periods[prevPeriod].lastSnapshotId = currentSnapshot;
            periods[prevPeriod].isOver = true;
        }

        _snapshot();

        periods[period] = Period(snapshotId, 0, false, true);

        return period;
    }

    /**
     * @notice Sets the competition factory contract address
     * @param competitionFactory_ The address of the competition factory contract
     *
     * @dev This function is used to set the competition factory contract address.
     * It can only be called by the contract owner.
     * It updates the competition factory contract address to the specified address.
     */
    function setCompetitionFactory(address competitionFactory_) external onlyOwner {
        require(address(competitionFactory_) != address(0), "Competition factory address can not be zero");
        competitionFactory = competitionFactory_;
        emit CompFactoryUpdated(competitionFactory_);
    }

    /**
     * @notice Sets the stake fee percentage
     * @param stakeFeePercentage_ The stake fee percentage to be set (between 0 and 100)
     *
     * @dev This function is used to set the stake fee percentage. It can only be called by the contract owner.
     * The stake fee percentage should be within the range of 0 to 100 (exclusive).
     * It updates the stake fee percentage to the specified value and emits the StakeFeePercentageUpdated event.
     */
    function setStakeFeePercentage(uint8 stakeFeePercentage_) external onlyOwner {
        require(stakeFeePercentage_ <= 5, "Fee percentage is not within limits");
        stakeFeePercentage = stakeFeePercentage_;
        emit StakeFeePercentageUpdated(stakeFeePercentage_);
    }

    /**
     * @notice Sets the stake fee address
     * @param feeAddress_ The address to be set as the stake fee address
     *
     * @dev This function is used to set the stake fee address. It can only be called by the contract owner.
     * The fee address should not be the zero address.
     * It updates the fee address to the specified value.
     */
    function setFeeAddress(address feeAddress_) external onlyOwner {
        require(feeAddress_ != address(0), "Fee address can not be zero");
        feeAddress = feeAddress_;
        emit FeeReceiverUpdated(feeAddress_);
    }

    /**
     * @notice Updates the account details
     * @param account The address of the account
     * @param previousBalance The previous balance of the account
     * @param currentBalance The current balance of the account
     *
     * @dev This internal function is used to update the account details based on the provided balances.
     * It updates the current snapshot balance and the previous snapshot balance if it doesn't exist.
     * It also updates the account details with the latest snapshot and activity balance.
     */
    function updateDetails(address account, uint256 previousBalance, uint256 currentBalance) internal {
        uint256 currentSnapshotId = snapshotId;
        ActivityDetails storage details = activityDetails[account];
        Snapshot storage currentSnapshot = snapshots[account][currentSnapshotId];

        // Update current snapshot balance
        currentSnapshot.balance = currentBalance;
        if (!currentSnapshot._exist) {
            currentSnapshot.prevSnapshotBalance = previousBalance;
            currentSnapshot._exist = true;
        }

        // Update account details
        details.lastSnapshotId = currentSnapshotId;
        details.lastActivityBalance = currentBalance;
        if (!details._exist) {
            details._exist = true;
        }
    }

    /**
     * @notice Stakes tokens
     * @param amount_ The amount of tokens to stake
     *
     * @dev This function allows an account to stake tokens into the contract.
     * The tokens are transferred from the caller to the contract.
     * The stake amount is calculated by subtracting the stake fee from the total amount.
     * The stake fee is calculated based on the stake fee percentage.
     * The caller's balance is increased by the stake amount.
     * If a stake fee is applicable, it is transferred to the fee address.
     * The total staked amount is increased by the stake amount.
     * Account details are updated, and a Stake event is emitted.
     */
    function stake(uint256 amount_) external whenPeriodExist whenFeeAddressExist {
        require(amount_ > 0, "Incorrect stake amount");
        IERC20Upgradeable token = stakeToken;
        uint256 currentBalance = balanceOf(_msgSender());
        uint256 currentSnapshot = snapshotId;
        uint256 periodId = currentPeriod;

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

    /**
     * @notice Get period details from the competition factory
     * @param periodId_ The ID of the period
     * @return The start time, end time, ticket buy start time, ticket buy end time, total allocation, existence status, and completion status of the period
     *
     * @dev This internal function retrieves the period details from the competition factory contract.
     * It returns the (start time, end time, ticket buy start time, ticket buy end time, competition count on period, completion status of the period, existence status).
     */
    function _getPeriod(uint256 periodId_) internal view returns (uint, uint, uint, uint, uint16, bool, bool) {
        return ICompetitionFactory(competitionFactory).getPeriod(periodId_);
    }

    /**
     * @notice Calculate the un-stake fee amount and remaining amount after cooling off period
     * @param requestAmount_ The amount requested for un-stake
     * @return The un-stake fee amount and the remaining amount after deducting the fee
     *
     * @dev This function calculates the un-stake fee amount and the remaining amount after deducting the fee,
     * based on the cooling off settings and the current period.
     * It takes the requested un-stake amount as input and returns the un-stake fee amount and the remaining amount.
     * If the period does not exist or the cooling off delays are not defined, the function returns the requested amount as is.
     * If the current time is within the coolest period, the function deducts the cooling off fee percentage from the requested amount.
     * If the current time is within the cooling off period, the function calculates the remaining amount after deducting the cooling off fee gradually.
     * Otherwise, if the cooling off period has passed, the function returns the requested amount as is, without any fee deduction.
     */
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

    /**
     * @notice Un-stake tokens
     * @param amount_ The amount of tokens to un-stake
     *
     * @dev This function allows the user to un-stake a specific amount of tokens.
     * It checks if the user has sufficient balance for un-staking and if the amount is greater than zero.
     * It calculates the un-stake fee amount and the remaining amount after deducting the fee using the calculateUnStakeAmounts function.
     * It updates the user's balance, total staked amount, and account details.
     * It transfers the un-stake fee to the fee receiver address and transfers the remaining amount of tokens to the user.
     * It emits the UnStake event.
     */
    function unStake(uint256 amount_) external whenFeeAddressExist {
        require(!isTimeLocked(_msgSender()), "Time lock active");
        uint256 currentBalance = balanceOf(_msgSender());
        uint256 currentSnapshot = snapshotId;
        uint256 periodId = currentPeriod;
        require(amount_ <= currentBalance, "Insufficient balance for unstake");
        require(amount_ > 0, "Amount should higher than zero");

        IERC20Upgradeable token = stakeToken;

        balances[_msgSender()] = balances[_msgSender()] - amount_;
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

    /**
     * @notice Transfer un-stake fees
     * @param amount The amount of un-stake fees to transfer
     * @param snapshotId_ The snapshot ID
     * @param periodId The period ID
     *
     * @dev This internal function transfers the un-stake fees to the fee receiver address.
     * It checks if the amount is greater than zero before transferring the fees.
     * It uses the safeTransfer function of the stakeToken to transfer the fees.
     * It emits the UnStakeFeeReceived event.
     */
    function _unStakeFeeTransfer(uint256 amount, uint256 snapshotId_, uint256 periodId) internal {
        if (amount <= 0) {
            return;
        }
        IERC20Upgradeable tokenSafe = stakeToken;

        tokenSafe.safeTransfer(address(feeAddress), amount);
        emit UnStakeFeeReceived(amount, snapshotId_, periodId);
    }

    /**
     * @notice Get period stake average information
     * @param account The account address
     * @param periodId The period ID
     * @return average The stake average for the given account and period
     * @return calculated Whether the stake average has been calculated for the given account and period
     *
     * @dev This internal function returns the stake average and its calculation status for the given account and period.
     * It retrieves the PeriodStakeAverage struct from the averages mapping and returns the average and _calculated values.
     */
    function _getPeriodStakeAverage(address account, uint256 periodId) internal view returns (uint256, bool) {
        PeriodStakeAverage memory avg = averages[account][periodId];
        return (avg.average, avg._calculated);
    }

    /**
     * @notice Get period stake average information
     * @param account The account address
     * @param periodId The period ID
     * @return average The stake average for the given account and period
     * @return calculated Whether the stake average has been calculated for the given account and period
     *
     * @dev This function returns the stake average and its calculation status for the given account and period.
     * It calls the internal function _getPeriodStakeAverage to retrieve the information.
     */
    function getPeriodStakeAverage(address account, uint256 periodId) external view returns (uint256, bool) {
        return _getPeriodStakeAverage(account, periodId);
    }

    /**
     * @notice Get snapshot average for stake rewards
     * @param account The account address
     * @param min The minimum snapshot ID
     * @param max The maximum snapshot ID
     * @return average The average balance of the account for the given snapshot range
     *
     * @dev This function calculates the average balance of the account for the specified snapshot range.
     * It is used for stake rewards calculation. The function requires the min and max snapshot IDs to be within
     * the range of existing snapshots. If the account has no stake activity after the min snapshot, the function
     * returns the last activity balance. It then calculates the sum of snapshot balances within the range, considering
     * any missing snapshot data. If there are missing snapshots, it scans for any stake activity beyond the max snapshot
     * to fill in the missing data. If no stake activity is found, the average is calculated based on the current balance.
     */
    function getSnapshotAverage(address account, uint256 min, uint256 max) external view returns (uint) {
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

            if (!shot._exist) {
                // Snapshot data does not exist
                if (!shift) {
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
                if (shot._exist) {
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

    /**
     * @notice Get period snapshot average with min/max range
     * @param account The account address
     * @param periodId The period ID
     * @param min The minimum snapshot ID
     * @param max The maximum snapshot ID
     * @return average The average balance of the account for the given period and snapshot range
     * @return calculated Whether the average has been calculated for the given period
     *
     * @dev This function calculates the average balance of the account for the specified period and snapshot range.
     * It requires the min and max snapshot IDs to be within the range of existing snapshots for the given period.
     * The function returns the average balance and a boolean indicating whether the average has been calculated for
     * the given period. If the average hasn't been calculated, the average value will be 0 and calculated will be false.
     * If the average has been calculated, the function iterates through the snapshot range and calculates the sum of balances.
     * It then divides the sum by the number of snapshots to get the average balance. The calculated value will be true.
     */
    function getPeriodSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool) {
        require(min <= max, "Min should be higher");
        uint256 currentSnapshotId = snapshotId;
        Period memory period = periods[periodId];
        PeriodStakeAverage memory avg = averages[account][periodId];

        // Return if current period average isn't calculated
        if (!avg._calculated) {
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

    /**
     * @notice Calculate the period stake average for the caller's account
     *
     * @dev This function calculates the period stake average for the caller's account.
     * It can only be called during a valid period and within the buy stage of the current period.
     * The function checks if the average has already been calculated for the current period.
     * If it has, the function reverts with an error message.
     * If the average has not been calculated, the function iterates through the snapshots of the account in reverse order.
     * It updates the balances and existence flags of the snapshots, and calculates the total stake amount.
     * Finally, it calculates the average stake amount and stores it in the averages mapping for the caller's account and period.
     */
    function calculatePeriodStakeAverage() external whenPeriodExist whenCurrentPeriodInBuyStage {
        uint256 periodId = currentPeriod;
        (, bool calculated) = _getPeriodStakeAverage(_msgSender(), periodId);

        require(!calculated, "Already calculated");

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
            } else if (shot._exist) {
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

        uint average = (total / (lastSnapshot - firstSnapshot + 1));
        averages[_msgSender()][periodId] = PeriodStakeAverage(average, true);
        emit PeriodStakeAverageCalculated(_msgSender(), periodId, average);
    }
}
