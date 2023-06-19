// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./../utils/DepositWithdraw.sol";
import "./IZizyCompetitionStaking.sol";

// Stake Rewards Contract
contract StakeRewards is DepositWithdraw {
    uint constant MAX_UINT = (2 ** 256) - 1;

    event AccountVestingRewardCreate(uint rewardId, uint vestingIndex, uint chainId, RewardType rewardType, address contractAddress, address indexed account, uint amount);
    event RewardClaimDiffChain(uint rewardId, uint vestingIndex, uint chainId, RewardType rewardType, address contractAddress, address indexed account, uint baseAmount, uint boostedAmount);
    event RewardClaimSameChain(uint rewardId, uint vestingIndex, uint chainId, RewardType rewardType, address contractAddress, address indexed account, uint baseAmount, uint boostedAmount);
    event RewardUpdated(uint rewardId, uint chainId, RewardType rewardType, address contractAddress, uint totalDistribution);
    event RewardConfigUpdated(uint rewardId, bool vestingEnabled, uint snapshotMin, uint snapshotMax, uint vestingDayInterval);
    event RewardClear(uint rewardId);

    // Reward Type
    enum RewardType {
        Token,
        Native,
        ZizyStakingPercentage
    }

    // Reward Booster Type
    enum BoosterType {
        HoldingNFT,
        ERC20Balance,
        StakingBalance
    }

    // Reward Booster
    struct Booster {
        BoosterType boosterType;
        address contractAddress; // Booster target contract
        uint amount; // Only for ERC20Balance & StakeBalance boosters
        uint boostPercentage; // Boost percentage
        bool _exist;
    }

    // Reward Tier
    struct RewardTier {
        uint stakeMin;
        uint stakeMax;
        uint rewardAmount;
    }

    // Reward Struct
    struct Reward {
        uint chainId;
        RewardType rewardType;
        address contractAddress; // Only token rewards
        uint amount;
        uint totalDistributed;
        uint percentage;
        bool _exist;
    }

    // Account Reward Struct
    struct AccountReward {
        uint chainId;
        RewardType rewardType;
        address contractAddress; // Only token rewards
        uint amount;
        bool isClaimed;
        bool _exist;
    }

    // Reward Config
    struct RewardConfig {
        bool vestingEnabled;
        uint vestingInterval; // 7 days
        uint vestingPeriodCount; // 10 vesting period [10 * 7 days]
        uint vestingStartDate; // Vesting start date
        uint snapshotMin;
        uint snapshotMax;
        bool _exist;
    }

    // Cache average
    struct CacheAverage {
        uint average;
        bool _exist;
    }

    // Account base reward
    struct AccBaseReward {
        uint baseReward;
        bool _exist;
    }

    // Reward definer account
    address public rewardDefiner;

    // Booster ids for iteration
    uint16[] private _boosterIds;

    // Reward boosters [boosterId > Booster]
    mapping(uint16 => Booster) private _boosters;

    // Reward configs [rewardId > RewardConfig]
    mapping(uint => RewardConfig) public rewardConfig;

    // Reward tiers [rewardId > RewardTier[]]
    mapping(uint => RewardTier[]) private _rewardTiers;

    // Rewards [rewardId > Reward]
    mapping(uint => Reward) private _rewards;

    // Account rewards [rewardId > address > vestingIndex > Reward]
    mapping(uint => mapping(address => mapping(uint => AccountReward))) private _accountRewards;

    // Account reward vesting periods defined [rewardId > address > bool]
    mapping(uint => mapping(address => bool)) private _accountRewardVestingPrepare;

    // Account average cache. Gas save for same snapshot range average calculations
    mapping(address => mapping(bytes32 => CacheAverage)) private _accountAverageCache;

    // Account total base reward (Sum of vestings) [address > rewardId > allocation]
    mapping(address => mapping(uint => AccBaseReward)) private _accountBaseReward;

    // Reward claim state for rewardId [Using for clear rewards] [rewardId > bool]
    mapping(uint => bool) private _isRewardClaimed;

    // Staking contract
    IZizyCompetitionStaking private stakingContract;



    // Only reward definer modifier
    modifier onlyRewardDefiner() {
        require(_msgSender() == rewardDefiner, "Only call from reward definer address");
        _;
    }

    // Only accept staking contract is defined
    modifier stakingContractIsSet() {
        require(address(stakingContract) != address(0), "Staking contract address must be defined");
        _;
    }

    // Initializer
    function initialize(address stakingContract_, address rewardDefiner_) external initializer {
        __Ownable_init();

        setStakingContract(stakingContract_);
        setRewardDefiner(rewardDefiner_);
    }

    // Get chainId
    function chainId() public view returns (uint) {
        return block.chainid;
    }

    // Get cache key for snapshot range calculation
    function _cacheKey(uint min_, uint max_) internal pure returns (bytes32) {
        return keccak256(abi.encode(min_, max_));
    }

    // Set average calculation
    function _setAverageCalculation(address account_, uint min_, uint max_, uint average_) internal {
        _accountAverageCache[account_][_cacheKey(min_, max_)] = CacheAverage(average_, true);
    }

    // Get booster
    function getBooster(uint16 boosterId_) public view returns (Booster memory) {
        return _boosters[boosterId_];
    }

    // Get booster index
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

    // Get boosters count
    function getBoosterCount() public view returns (uint) {
        return _boosterIds.length;
    }

    // Set & Update booster
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

    // Remove booster
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

    // Get account reward booster percentage
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

    // Get average calculation
    function getSnapshotsAverageCalculation(address account_, uint min_, uint max_) public view returns (CacheAverage memory) {
        return _getAccountSnapshotsAverage(account_, min_, max_);
    }

    // Set staking contract address
    function setStakingContract(address contract_) public onlyOwner {
        require(contract_ != address(0), "Contract address cant be zero address");
        stakingContract = IZizyCompetitionStaking(contract_);
    }

    // Set reward definer address
    function setRewardDefiner(address rewardDefiner_) public onlyOwner {
        require(rewardDefiner_ != address(0), "Reward definer address cant be zero address");
        rewardDefiner = rewardDefiner_;
    }

    /**
     * @dev Validate reward type
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

    // Check reward configs
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

    // Set & Update reward config
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

    // Get reward tiers count
    function getRewardTierCount(uint rewardId_) public view returns (uint) {
        return _rewardTiers[rewardId_].length;
    }

    // Get reward tier
    function getRewardTier(uint rewardId_, uint index_) public view returns (RewardTier memory) {
        uint tierLength = getRewardTierCount(rewardId_);
        require(index_ < tierLength, "Tier index out of boundaries");

        return _rewardTiers[rewardId_][index_];
    }

    // Set & Update reward tiers
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

    // Set & Update reward
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

    // Set native reward
    function setNativeReward(uint rewardId_, uint chainId_, uint amount_) public onlyRewardDefiner {
        _setReward(rewardId_, chainId_, RewardType.Native, address(0), amount_, 0);
    }

    // Set token reward
    function setTokenReward(uint rewardId_, uint chainId_, address contractAddress_, uint amount_) public onlyRewardDefiner {
        _setReward(rewardId_, chainId_, RewardType.Token, contractAddress_, amount_, 0);
    }

    // Set zizy stake percentage reward
    function setZizyStakePercentageReward(uint rewardId_, address contractAddress_, uint amount_, uint percentage_) public onlyRewardDefiner {
        _setReward(rewardId_, chainId(), RewardType.ZizyStakingPercentage, contractAddress_, amount_, percentage_);
    }

    // Get reward
    function getReward(uint rewardId_) public view returns (Reward memory) {
        return _rewards[rewardId_];
    }

    // Get account reward
    function getAccountReward(address account_, uint rewardId_, uint index_) public view returns (AccountReward memory) {
        return _accountRewards[rewardId_][account_][index_];
    }

    // Claim rewards
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

    // Check reward is claimable for public view
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

    // Claim single reward with vesting index
    function claimReward(uint rewardId_, uint vestingIndex_) external nonReentrant {
        // Prepare vesting periods
        _prepareRewardVestingPeriods(_msgSender(), rewardId_);
        _claimReward(_msgSender(), rewardId_, vestingIndex_);
    }

    // Check is vesting periods prepared before
    function _isVestingPeriodsPrepared(address account_, uint rewardId_) internal view returns (bool) {
        return _accountRewardVestingPrepare[rewardId_][account_];
    }

    // Get account snapshots average
    function _getAccountSnapshotsAverage(address account_, uint snapshotMin_, uint snapshotMax_) internal view returns (CacheAverage memory) {
        CacheAverage memory accAverage = _accountAverageCache[account_][_cacheKey(snapshotMin_, snapshotMax_)];
        if (accAverage._exist == false) {
            accAverage.average = stakingContract.getSnapshotAverage(account_, snapshotMin_, snapshotMax_);
        }
        return accAverage;
    }

    // Get account reward details
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

    // Prepare account reward vesting periods
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
