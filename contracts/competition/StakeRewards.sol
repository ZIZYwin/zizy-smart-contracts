// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./../utils/DepositWithdraw.sol";
import "./IZizyCompetitionStaking.sol";

/**
 * @title Stake Rewards Contract
 * @notice This contract manages the distribution of rewards to stakers based on vesting periods. It inherits from the DepositWithdraw contract
 */
contract StakeRewards is DepositWithdraw {
    uint constant MAX_UINT = (2 ** 256) - 1;

    /**
     * @notice This event is emitted when a vesting reward is created for an account.
     * @param rewardId The ID of the reward.
     * @param vestingIndex The index of the vesting period.
     * @param chainId The ID of the chain.
     * @param rewardType The type of the reward (Token, Native, ZizyStakingPercentage).
     * @param contractAddress The address of the contract (only for Token rewards).
     * @param account The account address.
     * @param amount The amount of the reward.
     */
    event AccountVestingRewardCreate(uint rewardId, uint vestingIndex, uint chainId, RewardType rewardType, address contractAddress, address indexed account, uint amount);

    /**
     * @notice This event is emitted when a reward is claimed for a different chain. (Reward distribution service will catch this event & Send the reward)
     * @param rewardId The ID of the reward.
     * @param vestingIndex The index of the vesting period.
     * @param chainId The ID of the chain.
     * @param rewardType The type of the reward (Token, Native, ZizyStakingPercentage).
     * @param contractAddress The address of the contract (only for Token rewards).
     * @param account The account address.
     * @param baseAmount The base amount of the reward.
     * @param boostedAmount The boosted amount of the reward.
     */
    event RewardClaimDiffChain(uint rewardId, uint vestingIndex, uint chainId, RewardType rewardType, address contractAddress, address indexed account, uint baseAmount, uint boostedAmount);

    /**
     * @notice This event is emitted when a reward is claimed on the same chain.
     * @param rewardId The ID of the reward.
     * @param vestingIndex The index of the vesting period.
     * @param chainId The ID of the chain.
     * @param rewardType The type of the reward (Token, Native, ZizyStakingPercentage).
     * @param contractAddress The address of the contract (only for Token rewards).
     * @param account The account address.
     * @param baseAmount The base amount of the reward.
     * @param boostedAmount The boosted amount of the reward.
     */
    event RewardClaimSameChain(uint rewardId, uint vestingIndex, uint chainId, RewardType rewardType, address contractAddress, address indexed account, uint baseAmount, uint boostedAmount);

    /**
     * @notice This event is emitted when a reward is updated with the total distribution amount.
     * @param rewardId The ID of the reward.
     * @param chainId The ID of the chain.
     * @param rewardType The type of the reward (Token, Native, ZizyStakingPercentage).
     * @param contractAddress The address of the contract (only for Token rewards).
     * @param totalDistribution The total amount distributed for the reward.
     */
    event RewardUpdated(uint rewardId, uint chainId, RewardType rewardType, address contractAddress, uint totalDistribution);

    /**
     * @notice This event is emitted when the reward configuration is updated.
     * @param rewardId The ID of the reward.
     * @param vestingEnabled The flag indicating if vesting is enabled for the reward.
     * @param snapshotMin The minimum snapshot ID for reward calculations.
     * @param snapshotMax The maximum snapshot ID for reward calculations.
     * @param vestingDayInterval The interval in days for vesting periods.
     */
    event RewardConfigUpdated(uint rewardId, bool vestingEnabled, uint snapshotMin, uint snapshotMax, uint vestingDayInterval);

    /**
     * @notice This event is emitted when a reward is cleared.
     * @param rewardId The ID of the reward.
     */
    event RewardClear(uint rewardId);

    /// @notice Enum for reward types
    enum RewardType {
        Token,
        Native,
        ZizyStakingPercentage
    }

    /// @notice Enum for reward booster types
    enum BoosterType {
        HoldingNFT,
        ERC20Balance,
        StakingBalance
    }

    /// @notice Struct for reward booster
    struct Booster {
        BoosterType boosterType;
        address contractAddress; // Booster target contract
        uint amount; // Only for ERC20Balance & StakeBalance boosters
        uint boostPercentage; // Boost percentage
        bool _exist;
    }

    /// @notice Struct for reward tier
    struct RewardTier {
        uint stakeMin;
        uint stakeMax;
        uint rewardAmount;
    }

    /// @notice Struct for reward
    struct Reward {
        uint chainId;
        RewardType rewardType;
        address contractAddress; // Only token rewards
        uint amount;
        uint totalDistributed;
        uint percentage;
        bool _exist;
    }

    /// @notice Struct for account reward
    struct AccountReward {
        uint chainId;
        RewardType rewardType;
        address contractAddress; // Only token rewards
        uint amount;
        bool isClaimed;
        bool _exist;
    }

    /// @notice Struct for reward config
    struct RewardConfig {
        bool vestingEnabled;
        uint vestingInterval; // 7 days
        uint vestingPeriodCount; // 10 vesting period [10 * 7 days]
        uint vestingStartDate; // Vesting start date
        uint snapshotMin;
        uint snapshotMax;
        bool _exist;
    }

    /// @notice Struct for cache average
    struct CacheAverage {
        uint average;
        bool _exist;
    }

    /// @notice Struct for account base reward
    struct AccBaseReward {
        uint baseReward;
        bool _exist;
    }

    /// @notice Reward definer account
    address public rewardDefiner;

    /// @dev Booster ids for iteration
    uint16[] private _boosterIds;

    /// @dev Reward boosters [boosterId > Booster]
    mapping(uint16 => Booster) private _boosters;

    /// @notice Reward configs [rewardId > RewardConfig]
    mapping(uint => RewardConfig) public rewardConfig;

    /// @dev Reward tiers [rewardId > RewardTier[]]
    mapping(uint => RewardTier[]) private _rewardTiers;

    /// @dev Rewards [rewardId > Reward]
    mapping(uint => Reward) private _rewards;

    /// @dev Account rewards [rewardId > address > vestingIndex > Reward]
    mapping(uint => mapping(address => mapping(uint => AccountReward))) private _accountRewards;

    /// @dev Account reward vesting periods defined [rewardId > address > bool]
    mapping(uint => mapping(address => bool)) private _accountRewardVestingPrepare;

    /// @dev Account average cache. Gas save for same snapshot range average calculations
    mapping(address => mapping(bytes32 => CacheAverage)) private _accountAverageCache;

    /// @dev Account total base reward (Sum of vestings) [address > rewardId > allocation]
    mapping(address => mapping(uint => AccBaseReward)) private _accountBaseReward;

    /// @dev Reward claim state for rewardId [Using for clear rewards] [rewardId > bool]
    mapping(uint => bool) private _isRewardClaimed;

    /// @dev Staking contract
    IZizyCompetitionStaking private stakingContract;

    /**
     * @dev Modifier that allows only the reward definer to execute a function.
     */
    modifier onlyRewardDefiner() {
        require(_msgSender() == rewardDefiner, "Only call from reward definer address");
        _;
    }

    /**
     * @dev Modifier that ensures the staking contract address is defined.
     */
    modifier stakingContractIsSet() {
        require(address(stakingContract) != address(0), "Staking contract address must be defined");
        _;
    }

    /**
     * @notice Initializes the StakeRewards contract.
     * @param stakingContract_ The address of the staking contract.
     * @param rewardDefiner_ The address of the reward definer.
     *
     * @dev This function is used to initialize the StakeRewards contract. It sets the staking contract address and the reward definer address.
     */
    function initialize(address stakingContract_, address rewardDefiner_) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721Holder_init();

        setStakingContract(stakingContract_);
        setRewardDefiner(rewardDefiner_);
    }

    /**
     * @notice Retrieves the chain ID.
     * @return The chain ID.
     *
     * @dev This function returns the chain ID of the current blockchain.
     */
    function chainId() public view returns (uint) {
        return block.chainid;
    }

    /**
     * @notice Generates a cache key for snapshot range calculation.
     * @param min_ The minimum snapshot value.
     * @param max_ The maximum snapshot value.
     * @return The cache key.
     *
     * @dev This function generates a cache key based on the minimum and maximum snapshot values provided.
     */
    function _cacheKey(uint min_, uint max_) internal pure returns (bytes32) {
        return keccak256(abi.encode(min_, max_));
    }

    /**
     * @notice Sets the average calculation for an account within a specific snapshot range.
     * @param account_ The account address.
     * @param min_ The minimum snapshot value.
     * @param max_ The maximum snapshot value.
     * @param average_ The average value to be set.
     *
     * @dev This function sets the average calculation for an account within a specific snapshot range.
     */
    function _setAverageCalculation(address account_, uint min_, uint max_, uint average_) internal {
        _accountAverageCache[account_][_cacheKey(min_, max_)] = CacheAverage(average_, true);
    }

    /**
     * @notice Retrieves the details of a booster by its ID.
     * @param boosterId_ The ID of the booster.
     * @return The booster details.
     *
     * @dev This function returns the details of a booster by its ID.
     */
    function getBooster(uint16 boosterId_) public view returns (Booster memory) {
        return _boosters[boosterId_];
    }

    /**
     * @notice Retrieves the index of a booster by its ID.
     * @param boosterId_ The ID of the booster.
     * @return The index of the booster.
     *
     * @dev This function returns the index of a booster by its ID. It reverts if the booster does not exist.
     */
    function getBoosterIndex(uint16 boosterId_) public view returns (uint) {
        require(_boosters[boosterId_]._exist == true, "Booster is not exist");
        uint boosterCount = getBoosterCount();
        uint16[] memory ids = _boosterIds;

        for (uint i = 0; i < boosterCount; ++i) {
            if (ids[i] == boosterId_) {
                return i;
            }
        }
        revert("Booster index not found !");
    }

    /**
     * @notice Retrieves the total number of boosters.
     * @return The count of boosters.
     *
     * @dev This function returns the total number of boosters.
     */
    function getBoosterCount() public view returns (uint) {
        return _boosterIds.length;
    }

    /**
     * @notice Sets or updates a booster.
     * @param boosterId_ The ID of the booster.
     * @param type_ The type of the booster (HoldingNFT, ERC20Balance, StakingBalance).
     * @param contractAddress_ The address of the contract (for ERC20Balance and HoldingNFT boosters).
     * @param amount_ The amount required for the booster (for ERC20Balance and StakingBalance boosters).
     * @param boostPercentage_ The boost percentage for the booster.
     *
     * @dev This function sets or updates a booster with the given parameters. It validates the inputs based on the booster type.
     *      If the booster ID doesn't exist, it adds the booster ID to the list of booster IDs.
     */
    function setBooster(uint16 boosterId_, BoosterType type_, address contractAddress_, uint amount_, uint boostPercentage_) public onlyRewardDefiner {
        // Validate
        if (type_ == BoosterType.ERC20Balance || type_ == BoosterType.StakingBalance) {
            require(amount_ > 0, "Amount should be higher than zero");
        }
        if (type_ == BoosterType.ERC20Balance || type_ == BoosterType.HoldingNFT) {
            require(contractAddress_ != address(0), "Contract address cant be zero address");
        }

        // Format
        if (type_ == BoosterType.HoldingNFT) {
            amount_ = 0;
        } else if (type_ == BoosterType.StakingBalance) {
            contractAddress_ = address(0);
        }

        if (_boosters[boosterId_]._exist == false) {
            _boosterIds.push(boosterId_);
        }

        _boosters[boosterId_] = Booster(type_, contractAddress_, amount_, boostPercentage_, true);
    }

    /**
     * @notice Removes a booster.
     * @param boosterId_ The ID of the booster to be removed.
     *
     * @dev This function removes the booster with the given ID. It checks if the booster exists and updates its values to default.
     *      It also removes the booster ID from the list of booster IDs.
     */
    function removeBooster(uint16 boosterId_) public onlyRewardDefiner {
        Booster memory booster = getBooster(boosterId_);
        require(booster._exist == true, "Booster does not exist");

        uint boosterCount = getBoosterCount();

        booster._exist = false;
        booster.boostPercentage = 0;
        booster.amount = 0;
        booster.contractAddress = address(0);

        for (uint i = 0; i < boosterCount; ++i) {
            uint16 indexBoosterId = _boosterIds[i];
            if (indexBoosterId == boosterId_) {
                _boosterIds[i] = _boosterIds[boosterCount - 1];
                _boosterIds.pop();
                _boosters[boosterId_] = booster;
                break;
            }
        }
    }

    /**
     * @notice Get the account's reward booster percentage.
     * @param account_ The address of the account.
     * @return The total boost percentage for the account based on the defined boosters.
     *
     * @dev This function calculates the total boost percentage for the given account by iterating through the boosters.
     *      It checks if each booster exists and applies the corresponding boost percentage based on the booster type.
     *      - For BoosterType.StakingBalance: If the staking balance is higher than the specified amount, the boost percentage is added.
     *      - For BoosterType.ERC20Balance: If the ERC20 balance is higher than the specified amount, the boost percentage is added.
     *      - For BoosterType.HoldingNFT: If the account holds at least one NFT of the specified contract, the boost percentage is added.
     */
    function getAccountBoostPercentage(address account_) public view returns (uint) {
        uint percentage = 0;
        uint boosterCount = getBoosterCount();
        uint16[] memory ids = _boosterIds;

        for (uint i = 0; i < boosterCount; i++) {
            uint16 boosterId = ids[i];
            Booster memory booster = _boosters[boosterId];
            if (booster._exist == false) {
                continue;
            }

            if (booster.boosterType == BoosterType.StakingBalance) {
                // Add additional boost percentage if stake balance is higher than given balance condition
                if (stakingContract.balanceOf(account_) >= booster.amount) {
                    percentage += booster.boostPercentage;
                }
            } else if (booster.boosterType == BoosterType.ERC20Balance) {
                // Add additional boost percentage if erc20 balance is higher than given balance condition
                if (IERC20Upgradeable(booster.contractAddress).balanceOf(account_) >= booster.amount) {
                    percentage += booster.boostPercentage;
                }
            } else if (booster.boosterType == BoosterType.HoldingNFT) {
                // Add additional boost percentage if account is given NFT holder
                if (IERC721Upgradeable(booster.contractAddress).balanceOf(account_) >= 1) {
                    percentage += booster.boostPercentage;
                }
            }
        }

        return percentage;
    }

    /**
     * @notice Get the average calculation for snapshots within the specified range.
     * @param account_ The address of the account.
     * @param min_ The minimum snapshot value.
     * @param max_ The maximum snapshot value.
     * @return The average calculation for the specified snapshots range.
     *
     * @dev This function retrieves the average calculation for the given account and snapshot range from the cache.
     *      It returns the average calculation stored in the cache as a CacheAverage struct.
     */
    function getSnapshotsAverageCalculation(address account_, uint min_, uint max_) public view returns (CacheAverage memory) {
        return _getAccountSnapshotsAverage(account_, min_, max_);
    }

    /**
     * @notice Set the address of the staking contract.
     * @param contract_ The address of the staking contract.
     *
     * @dev This function allows the owner to set the address of the staking contract.
     *      It requires a non-zero contract address to be provided.
     */
    function setStakingContract(address contract_) public onlyOwner {
        require(contract_ != address(0), "Contract address cant be zero address");
        stakingContract = IZizyCompetitionStaking(contract_);
    }

    /**
     * @notice Set the address of the reward definer.
     * @param rewardDefiner_ The address of the reward definer.
     *
     * @dev This function allows the owner to set the address of the reward definer.
     *      It requires a non-zero reward definer address to be provided.
     */
    function setRewardDefiner(address rewardDefiner_) public onlyOwner {
        require(rewardDefiner_ != address(0), "Reward definer address cant be zero address");
        rewardDefiner = rewardDefiner_;
    }

    /**
     * @dev Validate the reward type.
     * @param reward_ The reward object to validate.
     * @return A boolean indicating whether the reward type is valid.
     */
    function _validateReward(Reward memory reward_) internal pure returns (bool) {
        if (reward_.amount == 0) {
            return false;
        }
        if (reward_.rewardType == RewardType.Native && reward_.contractAddress != address(0)) {
            return false;
        }
        if (reward_.rewardType == RewardType.Token && reward_.contractAddress == address(0)) {
            return false;
        }
        if (reward_.rewardType == RewardType.ZizyStakingPercentage && reward_.contractAddress == address(0)) {
            return false;
        }

        return true;
    }

    /**
     * @notice Check if the reward configurations are completed for a given reward ID.
     * @param rewardId_ The ID of the reward to check.
     * @return A boolean indicating whether the reward configurations are completed.
     *
     * @dev This function validates various conditions to ensure that the reward configurations are complete.
     */
    function isRewardConfigsCompleted(uint rewardId_) public view returns (bool) {
        RewardConfig memory config = rewardConfig[rewardId_];
        Reward memory reward = _rewards[rewardId_];

        if (!config._exist) {
            return false;
        }
        if (reward.rewardType != RewardType.ZizyStakingPercentage) {
            // Zizy staking percentage reward doesn't required tier list
            if (_rewardTiers[rewardId_].length <= 0) {
                return false;
            }
        }
        if (config.snapshotMin <= 0 || config.snapshotMax <= 0 || config.snapshotMin > config.snapshotMax) {
            return false;
        }
        if (config.vestingEnabled && config.vestingInterval == 0 && config.vestingStartDate == 0) {
            return false;
        }

        return true;
    }

    /**
     * @notice Set or update the reward configuration for a given reward ID.
     * @param rewardId_ The ID of the reward.
     * @param vestingEnabled_ A boolean indicating whether vesting is enabled for the reward.
     * @param vestingStartDate_ The start date of the vesting period (in UNIX timestamp).
     * @param vestingDayInterval_ The number of days between each vesting period.
     * @param vestingPeriodCount_ The total number of vesting periods.
     * @param snapshotMin_ The minimum snapshot ID for calculating rewards.
     * @param snapshotMax_ The maximum snapshot ID for calculating rewards.
     *
     * @dev This function allows the reward definer to set or update the reward configuration for a specific reward ID.
     * The function performs various validations and checks before updating the configuration.
     * If vesting is enabled, the vesting start date, vesting day interval, and vesting period count must be valid.
     * The snapshot ranges must be within the valid range of snapshot IDs.
     * Once the configuration is updated, the 'RewardConfigUpdated' event is emitted.
     */
    function setRewardConfig(uint rewardId_, bool vestingEnabled_, uint vestingStartDate_, uint vestingDayInterval_, uint vestingPeriodCount_, uint snapshotMin_, uint snapshotMax_) public onlyRewardDefiner stakingContractIsSet {
        RewardConfig memory config = rewardConfig[rewardId_];
        require(_isRewardClaimed[rewardId_] == false, "This rewardId has claimed reward. Cant update");

        uint currentSnapshot = stakingContract.getSnapshotId();

        require(snapshotMin_ < currentSnapshot && snapshotMax_ < currentSnapshot, "Snapshot ranges is not correct");

        // Check vesting day
        if (vestingEnabled_) {
            require(vestingDayInterval_ > 0, "Vesting day cant be zero");
            require(vestingPeriodCount_ > 0, "Vesting period count cant be zero");
            require(vestingStartDate_ > 0, "Vesting start date cant be zero");
        }

        config.vestingEnabled = vestingEnabled_;
        config.vestingInterval = (vestingEnabled_ == true ? (vestingDayInterval_ * (1 days)) : 0);
        config.vestingPeriodCount = (vestingEnabled_ == true ? vestingPeriodCount_ : 1);
        config.vestingStartDate = (vestingEnabled_ == true ? vestingStartDate_ : 0);
        config.snapshotMin = snapshotMin_;
        config.snapshotMax = snapshotMax_;
        config._exist = true;

        rewardConfig[rewardId_] = config;

        emit RewardConfigUpdated(rewardId_, vestingEnabled_, snapshotMin_, snapshotMax_, vestingDayInterval_);
    }

    /**
     * @notice Get the number of reward tiers for a given reward ID.
     *
     * @param rewardId_ The ID of the reward.
     * @return The number of reward tiers.
     *
     * @dev This function returns the count of reward tiers for a specific reward ID.
     * It retrieves the length of the reward tiers array associated with the reward ID.
     */
    function getRewardTierCount(uint rewardId_) public view returns (uint) {
        return _rewardTiers[rewardId_].length;
    }

    /**
     * @notice Get the reward tier at a specific index for a given reward ID.
     *
     * @param rewardId_ The ID of the reward.
     * @param index_ The index of the reward tier.
     * @return The reward tier.
     *
     * @dev This function retrieves the reward tier at the specified index from the reward tiers array
     * associated with the given reward ID.
     */
    function getRewardTier(uint rewardId_, uint index_) public view returns (RewardTier memory) {
        uint tierLength = getRewardTierCount(rewardId_);
        require(index_ < tierLength, "Tier index out of boundaries");

        return _rewardTiers[rewardId_][index_];
    }

    /**
     * @notice Set or update the reward tiers for a given reward ID.
     *
     * @param rewardId_ The ID of the reward.
     * @param tiers_ The array of reward tiers to be set or updated.
     *
     * @dev This function sets or updates the reward tiers for a specific reward ID. It clears the existing
     * reward tiers for the given reward ID and then adds the new reward tiers from the provided array.
     * The tier length must be greater than 1, and each tier's stake minimum must be greater than the maximum
     * of the previous tier to avoid range collisions.
     */
    function setRewardTiers(uint rewardId_, RewardTier[] calldata tiers_) public onlyRewardDefiner {
        require(_isRewardClaimed[rewardId_] == false, "This rewardId has claimed reward. Cant update");

        uint tierLength = tiers_.length;
        require(tierLength > 1, "Tier length should be higher than 1");

        uint prevMax = 0;

        // Clear old tiers
        delete _rewardTiers[rewardId_];

        for (uint i = 0; i < tierLength; ++i) {
            RewardTier memory tier_ = tiers_[i];

            bool isFirst = (i == 0);
            bool isLast = (i == (tierLength - 1));

            tier_.stakeMax = (isLast ? (MAX_UINT) : tier_.stakeMax);

            if (!isFirst) {
                require(tier_.stakeMin > prevMax, "Range collision");
            }
            _rewardTiers[rewardId_].push(tier_);

            prevMax = tier_.stakeMax;
        }
    }

    /**
     * @notice Set or update a reward.
     *
     * @param rewardId_ The ID of the reward.
     * @param chainId_ The ID of the chain.
     * @param rewardType_ The type of the reward.
     * @param contractAddress_ The address of the contract (only for Token rewards).
     * @param amount_ The amount of the reward.
     * @param percentage_ The boost percentage of the reward.
     *
     * @dev This internal function sets or updates a reward with the provided details. It validates the reward data
     * and checks if the reward is already claimed. If the reward is already claimed, the function reverts.
     * After updating the reward, it emits the `RewardUpdated` event.
     */
    function _setReward(uint rewardId_, uint chainId_, RewardType rewardType_, address contractAddress_, uint amount_, uint percentage_) internal {
        require(_isRewardClaimed[rewardId_] == false, "This rewardId has claimed reward. Cant update");
        Reward memory currentReward = _rewards[rewardId_];
        Reward memory reward = Reward(chainId_, rewardType_, contractAddress_, amount_, 0, percentage_, false);
        require(_validateReward(reward) == true, "Reward data is not correct");

        if (currentReward._exist == true && _isRewardClaimed[rewardId_] == true) {
            revert("Cant set/update claimed reward");
        }

        _rewards[rewardId_] = reward;

        emit RewardUpdated(rewardId_, chainId_, rewardType_, contractAddress_, amount_);
    }

    /**
     * @notice Set a native coin reward.
     *
     * @param rewardId_ The ID of the reward.
     * @param chainId_ The ID of the chain.
     * @param amount_ The amount of the reward.
     *
     * @dev This function sets a native reward with the provided details by calling the internal
     * `_setReward` function with the reward type set to `RewardType.Native` and the contract address set to zero address.
     */
    function setNativeReward(uint rewardId_, uint chainId_, uint amount_) public onlyRewardDefiner {
        _setReward(rewardId_, chainId_, RewardType.Native, address(0), amount_, 0);
    }

    /**
     * @notice Set a token reward.
     *
     * @param rewardId_ The ID of the reward.
     * @param chainId_ The ID of the chain.
     * @param contractAddress_ The address of the contract.
     * @param amount_ The amount of the reward.
     *
     * @dev This function sets a token reward with the provided details by calling the internal
     * `_setReward` function with the reward type set to `RewardType.Token`.
     */
    function setTokenReward(uint rewardId_, uint chainId_, address contractAddress_, uint amount_) public onlyRewardDefiner {
        _setReward(rewardId_, chainId_, RewardType.Token, contractAddress_, amount_, 0);
    }

    /**
     * @notice Set a Zizy stake percentage reward.
     *
     * @param rewardId_ The ID of the reward.
     * @param contractAddress_ The address of the contract.
     * @param amount_ The amount of the reward.
     * @param percentage_ The boost percentage of the reward.
     *
     * @dev This function sets a Zizy stake percentage reward with the provided details by calling the internal
     * `_setReward` function with the reward type set to `RewardType.ZizyStakingPercentage`.
     * The chain ID is obtained using the `chainId()` function.
     */
    function setZizyStakePercentageReward(uint rewardId_, address contractAddress_, uint amount_, uint percentage_) public onlyRewardDefiner {
        _setReward(rewardId_, chainId(), RewardType.ZizyStakingPercentage, contractAddress_, amount_, percentage_);
    }

    /**
     * @notice Get a reward by ID.
     *
     * @param rewardId_ The ID of the reward.
     * @return The reward details.
     */
    function getReward(uint rewardId_) public view returns (Reward memory) {
        return _rewards[rewardId_];
    }

    /**
     * @notice Get an account reward by account address, reward ID, and vesting index.
     *
     * @param account_ The account address.
     * @param rewardId_ The ID of the reward.
     * @param index_ The index of the account reward.
     * @return The account reward details.
     */
    function getAccountReward(address account_, uint rewardId_, uint index_) public view returns (AccountReward memory) {
        return _accountRewards[rewardId_][account_][index_];
    }

    /**
     * @notice Claim rewards for an account and a specific reward with a vesting index.
     *
     * @param account_ The account address.
     * @param rewardId_ The ID of the reward.
     * @param vestingIndex_ The index of the vesting period.
     *
     * @dev This function allows an account to claim their rewards for a specific reward and vesting index.
     * It performs various checks and calculations to determine the claimability and distribution of the rewards.
     */
    function _claimReward(address account_, uint rewardId_, uint vestingIndex_) internal {
        AccountReward memory reward = _accountRewards[rewardId_][account_][vestingIndex_];
        require(isRewardClaimable(account_, rewardId_, vestingIndex_) == true, "Reward isnt claimable");

        // Set claim state first [Reentrancy ? :)]
        _accountRewards[rewardId_][account_][vestingIndex_].isClaimed = true;

        // Disable reward & reward config update
        _isRewardClaimed[rewardId_] = true;

        uint boosterPercentage = getAccountBoostPercentage(account_);
        uint boostedAmount = (reward.amount * (100 + boosterPercentage)) / 100;

        Reward memory baseReward = getReward(rewardId_);
        require(baseReward.amount >= (baseReward.totalDistributed + boostedAmount), "Not enough balance in the pool allocated for the reward");

        // Update total distributed amount of base reward
        _rewards[rewardId_].totalDistributed += boostedAmount;

        if (reward.chainId == chainId()) {
            if (reward.rewardType == RewardType.Native) {
                _sendNativeCoin(payable(account_), boostedAmount);
            } else if (reward.rewardType == RewardType.Token || reward.rewardType == RewardType.ZizyStakingPercentage) {
                _sendToken(account_, reward.contractAddress, boostedAmount);
            }
            emit RewardClaimSameChain(rewardId_, vestingIndex_, reward.chainId, reward.rewardType, reward.contractAddress, account_, reward.amount, boostedAmount);
        } else {
            // Emit event for message relay
            emit RewardClaimDiffChain(rewardId_, vestingIndex_, reward.chainId, reward.rewardType, reward.contractAddress, account_, reward.amount, boostedAmount);
        }
    }

    /**
     * @notice Check if a reward is claimable for an account, reward ID, and vesting index.
     *
     * @param account_ The account address.
     * @param rewardId_ The ID of the reward.
     * @param vestingIndex_ The index of the vesting period.
     * @return A boolean indicating if the reward is claimable.
     */
    function isRewardClaimable(address account_, uint rewardId_, uint vestingIndex_) public view returns (bool) {
        // Check reward configs
        if (isRewardConfigsCompleted(rewardId_) == false) {
            return false;
        }

        RewardConfig memory config = rewardConfig[rewardId_];
        AccountReward memory reward = _accountRewards[rewardId_][account_][vestingIndex_];

        (AccBaseReward memory baseReward, ,) = getAccountRewardDetails(account_, rewardId_, config.snapshotMin, config.snapshotMax);
        uint ts = block.timestamp;

        if (_isVestingPeriodsPrepared(account_, rewardId_) == true) {
            if (reward._exist == false || reward.isClaimed == true) {
                return false;
            }
        } else {
            // No allocation for this reward
            if (baseReward.baseReward <= 0) {
                return false;
            }
        }

        // Check vesting dates
        if (config.vestingEnabled) {
            if (ts < ((vestingIndex_ * config.vestingInterval) + config.vestingStartDate)) {
                return false;
            }
        }

        return true;
    }

    /**
     * @notice Claim a single reward with a specific vesting index.
     *
     * @param rewardId_ The ID of the reward.
     * @param vestingIndex_ The index of the vesting period.
     *
     * @dev This function allows an account to claim a specific reward with a vesting index.
     * It prepares the vesting periods and performs the necessary checks and calculations for reward claiming.
     */
    function claimReward(uint rewardId_, uint vestingIndex_) external nonReentrant {
        // Prepare vesting periods
        _prepareRewardVestingPeriods(_msgSender(), rewardId_);
        _claimReward(_msgSender(), rewardId_, vestingIndex_);
    }

    /**
     * @notice Check if the vesting periods are prepared for an account and a specific reward.
     *
     * @param account_ The account address.
     * @param rewardId_ The ID of the reward.
     * @return A boolean indicating if the vesting periods are prepared.
     */
    function _isVestingPeriodsPrepared(address account_, uint rewardId_) internal view returns (bool) {
        return _accountRewardVestingPrepare[rewardId_][account_];
    }

    /**
     * @notice Get the average of account snapshots within a given range.
     *
     * @param account_ The account address.
     * @param snapshotMin_ The minimum snapshot ID.
     * @param snapshotMax_ The maximum snapshot ID.
     * @return The average of account snapshots within the range.
     */
    function _getAccountSnapshotsAverage(address account_, uint snapshotMin_, uint snapshotMax_) internal view returns (CacheAverage memory) {
        CacheAverage memory accAverage = _accountAverageCache[account_][_cacheKey(snapshotMin_, snapshotMax_)];
        if (accAverage._exist == false) {
            accAverage.average = stakingContract.getSnapshotAverage(account_, snapshotMin_, snapshotMax_);
        }
        return accAverage;
    }

    /**
     * @notice Get the details of an account's reward for a specific reward, snapshot range, and reward tier.
     *
     * @param account_ The account address.
     * @param rewardId_ The ID of the reward.
     * @param snapshotMin_ The minimum snapshot ID.
     * @param snapshotMax_ The maximum snapshot ID.
     * @return The account's base reward, the cache average, and the length of reward tiers.
     */
    function getAccountRewardDetails(address account_, uint rewardId_, uint snapshotMin_, uint snapshotMax_) public view returns (AccBaseReward memory, CacheAverage memory, uint) {
        AccBaseReward memory baseReward = _accountBaseReward[account_][rewardId_];
        CacheAverage memory accAverage = _getAccountSnapshotsAverage(account_, snapshotMin_, snapshotMax_);
        RewardTier[] memory tiers = _rewardTiers[rewardId_];
        Reward memory reward = _rewards[rewardId_];
        uint tierLength = tiers.length;

        // Return if calculations already exist
        if (baseReward._exist) {
            return (baseReward, accAverage, tierLength);
        }

        if (reward.rewardType == RewardType.ZizyStakingPercentage) {
            // Staking percentage rewards doesn't required tier list
            baseReward.baseReward = (accAverage.average) * reward.percentage / 100;
        } else {
            // Find account tier range
            for (uint i = 0; i < tierLength; ++i) {
                RewardTier memory tier = tiers[i];

                if (i == 0 && accAverage.average < tier.stakeMin) {
                    break;
                }

                if (accAverage.average >= tier.stakeMin && accAverage.average <= tier.stakeMax) {
                    baseReward.baseReward = tier.rewardAmount;
                    break;
                }
            }
        }

        return (baseReward, accAverage, tierLength);
    }

    /**
     * @notice Prepare the vesting periods for an account and a specific reward.
     *
     * @param account_ The account address.
     * @param rewardId_ The ID of the reward.
     *
     * @dev This function prepares the vesting periods for an account and a specific reward.
     * It calculates the base reward, stores it in the state variable, and creates the vesting periods.
     */
    function _prepareRewardVestingPeriods(address account_, uint rewardId_) internal {
        // Check prepared before for gas cost
        if (_isVestingPeriodsPrepared(account_, rewardId_) == true) {
            return;
        }

        RewardConfig memory config = rewardConfig[rewardId_];
        Reward memory reward = _rewards[rewardId_];

        (AccBaseReward memory baseReward, CacheAverage memory accAverage,) = getAccountRewardDetails(account_, rewardId_, config.snapshotMin, config.snapshotMax);

        // Write account average in cache if not exist
        if (accAverage._exist == false) {
            _setAverageCalculation(account_, config.snapshotMin, config.snapshotMax, accAverage.average);
        }

        // Write account base reward in state variable if not exist
        if (baseReward._exist == false) {
            baseReward._exist = true;
            _accountBaseReward[account_][rewardId_] = baseReward;
        }

        uint rewardPerVestingPeriod = (baseReward.baseReward / config.vestingPeriodCount);

        // Create vesting periods
        for (uint i = 0; i < config.vestingPeriodCount; ++i) {
            _accountRewards[rewardId_][account_][i] = AccountReward(reward.chainId, reward.rewardType, reward.contractAddress, rewardPerVestingPeriod, false, true);
            emit AccountVestingRewardCreate(rewardId_, i, reward.chainId, reward.rewardType, reward.contractAddress, account_, rewardPerVestingPeriod);
        }

        // Set vesting periods prepare state
        _accountRewardVestingPrepare[rewardId_][account_] = true;
    }
}
