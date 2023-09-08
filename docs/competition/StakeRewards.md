# Solidity API

## StakeRewards

This contract manages the distribution of rewards to stakers based on vesting periods. It inherits from the DepositWithdraw contract

### RewardType

```solidity
enum RewardType {
  Token,
  Native,
  ZizyStakingPercentage
}
```

### BoosterType

```solidity
enum BoosterType {
  HoldingPOPA
}
```

### Booster

```solidity
struct Booster {
  enum StakeRewards.BoosterType boosterType;
  address contractAddress;
  uint256 amount;
  uint256 boostPercentage;
  bool _exist;
}
```

### RewardTier

```solidity
struct RewardTier {
  uint256 stakeMin;
  uint256 stakeMax;
  uint256 rewardAmount;
}
```

### Reward

```solidity
struct Reward {
  uint256 chainId;
  enum StakeRewards.RewardType rewardType;
  address contractAddress;
  uint256 amount;
  uint256 totalDistributed;
  uint256 percentage;
  bool _exist;
}
```

### AccountReward

```solidity
struct AccountReward {
  uint256 chainId;
  enum StakeRewards.RewardType rewardType;
  address contractAddress;
  uint256 amount;
  bool isClaimed;
  bool _exist;
}
```

### RewardConfig

```solidity
struct RewardConfig {
  bool vestingEnabled;
  uint256 vestingInterval;
  uint256 vestingPeriodCount;
  uint256 vestingStartDate;
  uint256 snapshotMin;
  uint256 snapshotMax;
  bool _exist;
}
```

### CacheAverage

```solidity
struct CacheAverage {
  uint256 average;
  bool _exist;
}
```

### AccBaseReward

```solidity
struct AccBaseReward {
  uint256 baseReward;
  bool _exist;
}
```

### MAX_UINT

```solidity
uint256 MAX_UINT
```

### rewardDefiner

```solidity
address rewardDefiner
```

Reward definer account

### rewardConfig

```solidity
mapping(uint256 => struct StakeRewards.RewardConfig) rewardConfig
```

Reward configs [rewardId > RewardConfig]

### stakingContract

```solidity
contract IZizyCompetitionStaking stakingContract
```

_Staking contract_

### AccountVestingRewardCreate

```solidity
event AccountVestingRewardCreate(uint256 rewardId, uint256 vestingIndex, uint256 chainId, enum StakeRewards.RewardType rewardType, address contractAddress, address account, uint256 amount)
```

This event is emitted when a vesting reward is created for an account.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId | uint256 | The ID of the reward. |
| vestingIndex | uint256 | The index of the vesting period. |
| chainId | uint256 | The ID of the chain. |
| rewardType | enum StakeRewards.RewardType | The type of the reward (Token, Native, ZizyStakingPercentage). |
| contractAddress | address | The address of the contract (only for Token rewards). |
| account | address | The account address. |
| amount | uint256 | The amount of the reward. |

### RewardClaimDiffChain

```solidity
event RewardClaimDiffChain(uint256 rewardId, uint256 vestingIndex, uint256 chainId, enum StakeRewards.RewardType rewardType, address contractAddress, address account, uint256 baseAmount, uint256 boostedAmount)
```

This event is emitted when a reward is claimed for a different chain. (Reward distribution service will catch this event & Send the reward)

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId | uint256 | The ID of the reward. |
| vestingIndex | uint256 | The index of the vesting period. |
| chainId | uint256 | The ID of the chain. |
| rewardType | enum StakeRewards.RewardType | The type of the reward (Token, Native, ZizyStakingPercentage). |
| contractAddress | address | The address of the contract (only for Token rewards). |
| account | address | The account address. |
| baseAmount | uint256 | The base amount of the reward. |
| boostedAmount | uint256 | The boosted amount of the reward. |

### RewardClaimSameChain

```solidity
event RewardClaimSameChain(uint256 rewardId, uint256 vestingIndex, uint256 chainId, enum StakeRewards.RewardType rewardType, address contractAddress, address account, uint256 baseAmount, uint256 boostedAmount)
```

This event is emitted when a reward is claimed on the same chain.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId | uint256 | The ID of the reward. |
| vestingIndex | uint256 | The index of the vesting period. |
| chainId | uint256 | The ID of the chain. |
| rewardType | enum StakeRewards.RewardType | The type of the reward (Token, Native, ZizyStakingPercentage). |
| contractAddress | address | The address of the contract (only for Token rewards). |
| account | address | The account address. |
| baseAmount | uint256 | The base amount of the reward. |
| boostedAmount | uint256 | The boosted amount of the reward. |

### RewardUpdated

```solidity
event RewardUpdated(uint256 rewardId, uint256 chainId, enum StakeRewards.RewardType rewardType, address contractAddress, uint256 totalDistribution)
```

This event is emitted when a reward is updated with the total distribution amount.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId | uint256 | The ID of the reward. |
| chainId | uint256 | The ID of the chain. |
| rewardType | enum StakeRewards.RewardType | The type of the reward (Token, Native, ZizyStakingPercentage). |
| contractAddress | address | The address of the contract (only for Token rewards). |
| totalDistribution | uint256 | The total amount distributed for the reward. |

### RewardConfigUpdated

```solidity
event RewardConfigUpdated(uint256 rewardId, bool vestingEnabled, uint256 snapshotMin, uint256 snapshotMax, uint256 vestingDayInterval)
```

This event is emitted when the reward configuration is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId | uint256 | The ID of the reward. |
| vestingEnabled | bool | The flag indicating if vesting is enabled for the reward. |
| snapshotMin | uint256 | The minimum snapshot ID for reward calculations. |
| snapshotMax | uint256 | The maximum snapshot ID for reward calculations. |
| vestingDayInterval | uint256 | The interval in days for vesting periods. |

### SetBooster

```solidity
event SetBooster(uint16 boosterId, enum StakeRewards.BoosterType boosterType, address contractAddress, uint256 amount, uint256 boostPercentage, bool isNew)
```

This event is emitted when a booster is set or updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| boosterId | uint16 | The ID of the booster. |
| boosterType | enum StakeRewards.BoosterType | The type of the booster (HoldingPOPA). |
| contractAddress | address | The address of the contract associated with the booster. |
| amount | uint256 | The amount or condition associated with the booster (e.g., stake balance amount). |
| boostPercentage | uint256 | The boost percentage offered by the booster. |
| isNew | bool | A flag indicating whether the booster is a new addition or updated. |

### StakingContractUpdate

```solidity
event StakingContractUpdate(address stakingContract)
```

This event is emitted when the staking contract address is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| stakingContract | address | The new address of the staking contract. |

### RewardDefinerUpdate

```solidity
event RewardDefinerUpdate(address rewardDefiner)
```

This event is emitted when the reward definer contract address is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardDefiner | address | The new address of the reward definer contract. |

### RewardTiersUpdate

```solidity
event RewardTiersUpdate(uint256 rewardId)
```

This event is emitted when the reward tiers are updated for a specific reward.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId | uint256 | The ID of the reward for which the tiers are updated. |

### BoosterRemoved

```solidity
event BoosterRemoved(uint16 boosterId)
```

This event is emitted when a booster is removed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| boosterId | uint16 | The ID of the removed booster. |

### onlyRewardDefiner

```solidity
modifier onlyRewardDefiner()
```

_Modifier that allows only the reward definer to execute a function._

### stakingContractIsSet

```solidity
modifier stakingContractIsSet()
```

_Modifier that ensures the staking contract address is defined._

### constructor

```solidity
constructor() public
```

_Constructor function_

### initialize

```solidity
function initialize(address stakingContract_, address rewardDefiner_) external
```

Initializes the StakeRewards contract.

_This function is used to initialize the StakeRewards contract. It sets the staking contract address and the reward definer address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| stakingContract_ | address | The address of the staking contract. |
| rewardDefiner_ | address | The address of the reward definer. |

### getBoosterIndex

```solidity
function getBoosterIndex(uint16 boosterId_) external view returns (uint256)
```

Retrieves the index of a booster by its ID.

_This function returns the index of a booster by its ID. It reverts if the booster does not exist._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| boosterId_ | uint16 | The ID of the booster. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The index of the booster. |

### setBooster

```solidity
function setBooster(uint16 boosterId_, enum StakeRewards.BoosterType type_, address contractAddress_, uint256 amount_, uint256 boostPercentage_) external
```

Sets or updates a booster.

_This function sets or updates a booster with the given parameters. It validates the inputs based on the booster type.
     If the booster ID doesn't exist, it adds the booster ID to the list of booster IDs._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| boosterId_ | uint16 | The ID of the booster. |
| type_ | enum StakeRewards.BoosterType | The type of the booster (HoldingPOPA). |
| contractAddress_ | address | The address of the contract (for HoldingPOPA boosters). |
| amount_ | uint256 | The amount required for the booster. |
| boostPercentage_ | uint256 | The boost percentage for the booster. |

### removeBooster

```solidity
function removeBooster(uint16 boosterId_) external
```

Removes a booster.

_This function removes the booster with the given ID. It checks if the booster exists and updates its values to default.
     It also removes the booster ID from the list of booster IDs._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| boosterId_ | uint16 | The ID of the booster to be removed. |

### getSnapshotsAverageCalculation

```solidity
function getSnapshotsAverageCalculation(address account_, uint256 min_, uint256 max_) external view returns (struct StakeRewards.CacheAverage)
```

Get the average calculation for snapshots within the specified range.

_This function retrieves the average calculation for the given account and snapshot range from the cache.
     It returns the average calculation stored in the cache as a CacheAverage struct._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The address of the account. |
| min_ | uint256 | The minimum snapshot value. |
| max_ | uint256 | The maximum snapshot value. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.CacheAverage | The average calculation for the specified snapshots range. |

### setRewardConfig

```solidity
function setRewardConfig(uint256 rewardId_, bool vestingEnabled_, uint256 vestingStartDate_, uint256 vestingDayInterval_, uint256 vestingPeriodCount_, uint256 snapshotMin_, uint256 snapshotMax_) external
```

Set or update the reward configuration for a given reward ID.

_This function allows the reward definer to set or update the reward configuration for a specific reward ID.
The function performs various validations and checks before updating the configuration.
If vesting is enabled, the vesting start date, vesting day interval, and vesting period count must be valid.
The snapshot ranges must be within the valid range of snapshot IDs.
Once the configuration is updated, the 'RewardConfigUpdated' event is emitted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| vestingEnabled_ | bool | A boolean indicating whether vesting is enabled for the reward. |
| vestingStartDate_ | uint256 | The start date of the vesting period (in UNIX timestamp). |
| vestingDayInterval_ | uint256 | The number of days between each vesting period. |
| vestingPeriodCount_ | uint256 | The total number of vesting periods. |
| snapshotMin_ | uint256 | The minimum snapshot ID for calculating rewards. |
| snapshotMax_ | uint256 | The maximum snapshot ID for calculating rewards. |

### getRewardTier

```solidity
function getRewardTier(uint256 rewardId_, uint256 index_) external view returns (struct StakeRewards.RewardTier)
```

Get the reward tier at a specific index for a given reward ID.

_This function retrieves the reward tier at the specified index from the reward tiers array
associated with the given reward ID._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| index_ | uint256 | The index of the reward tier. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.RewardTier | The reward tier. |

### setRewardTiers

```solidity
function setRewardTiers(uint256 rewardId_, struct StakeRewards.RewardTier[] tiers_) external
```

Set or update the reward tiers for a given reward ID.

_This function sets or updates the reward tiers for a specific reward ID. It clears the existing
reward tiers for the given reward ID and then adds the new reward tiers from the provided array.
The tier length must be greater than 1, and each tier's stake minimum must be greater than the maximum
of the previous tier to avoid range collisions._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| tiers_ | struct StakeRewards.RewardTier[] | The array of reward tiers to be set or updated. |

### setNativeReward

```solidity
function setNativeReward(uint256 rewardId_, uint256 chainId_, uint256 amount_) external
```

Set a native coin reward.

_This function sets a native reward with the provided details by calling the internal
`_setReward` function with the reward type set to `RewardType.Native` and the contract address set to zero address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| chainId_ | uint256 | The ID of the chain. |
| amount_ | uint256 | The amount of the reward. |

### setTokenReward

```solidity
function setTokenReward(uint256 rewardId_, uint256 chainId_, address contractAddress_, uint256 amount_) external
```

Set a token reward.

_This function sets a token reward with the provided details by calling the internal
`_setReward` function with the reward type set to `RewardType.Token`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| chainId_ | uint256 | The ID of the chain. |
| contractAddress_ | address | The address of the contract. |
| amount_ | uint256 | The amount of the reward. |

### setZizyStakePercentageReward

```solidity
function setZizyStakePercentageReward(uint256 rewardId_, address contractAddress_, uint256 amount_, uint256 percentage_) external
```

Set a Zizy stake percentage reward.

_This function sets a Zizy stake percentage reward with the provided details by calling the internal
`_setReward` function with the reward type set to `RewardType.ZizyStakingPercentage`.
The chain ID is obtained using the `chainId()` function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| contractAddress_ | address | The address of the contract. |
| amount_ | uint256 | The amount of the reward. |
| percentage_ | uint256 | The boost percentage of the reward. |

### getAccountReward

```solidity
function getAccountReward(address account_, uint256 rewardId_, uint256 index_) external view returns (struct StakeRewards.AccountReward)
```

Get an account reward by account address, reward ID, and vesting index.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| rewardId_ | uint256 | The ID of the reward. |
| index_ | uint256 | The index of the account reward. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.AccountReward | The account reward details. |

### claimReward

```solidity
function claimReward(uint256 rewardId_, uint256 vestingIndex_) external
```

Claim a single reward with a specific vesting index.

_This function allows an account to claim a specific reward with a vesting index.
It prepares the vesting periods and performs the necessary checks and calculations for reward claiming._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| vestingIndex_ | uint256 | The index of the vesting period. |

### chainId

```solidity
function chainId() public view returns (uint256)
```

Retrieves the chain ID.

_This function returns the chain ID of the current blockchain._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The chain ID. |

### getBooster

```solidity
function getBooster(uint16 boosterId_) public view returns (struct StakeRewards.Booster)
```

Retrieves the details of a booster by its ID.

_This function returns the details of a booster by its ID._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| boosterId_ | uint16 | The ID of the booster. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.Booster | The booster details. |

### getBoosterCount

```solidity
function getBoosterCount() public view returns (uint256)
```

Retrieves the total number of boosters.

_This function returns the total number of boosters._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The count of boosters. |

### getAccountBoostPercentage

```solidity
function getAccountBoostPercentage(address account_, uint256 rewardId_, uint256 vestingIndex_) public view returns (uint256)
```

Get the account's reward booster percentage.

_This function calculates the total boost percentage for the given account by iterating through the boosters.
     It checks if each booster exists and applies the corresponding boost percentage based on the booster type.
     - For BoosterType.HoldingPOPA: If the account holds at least one POPA of the specified contract, the boost percentage is added._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The address of the account. |
| rewardId_ | uint256 | Reward id |
| vestingIndex_ | uint256 | Vesting index |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The total boost percentage for the account based on the defined boosters. |

### setStakingContract

```solidity
function setStakingContract(address contract_) public
```

Set the address of the staking contract.

_This function allows the owner to set the address of the staking contract.
     It requires a non-zero contract address to be provided._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| contract_ | address | The address of the staking contract. |

### setRewardDefiner

```solidity
function setRewardDefiner(address rewardDefiner_) public
```

Set the address of the reward definer.

_This function allows the owner to set the address of the reward definer.
     It requires a non-zero reward definer address to be provided._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardDefiner_ | address | The address of the reward definer. |

### isRewardConfigsCompleted

```solidity
function isRewardConfigsCompleted(uint256 rewardId_) public view returns (bool)
```

Check if the reward configurations are completed for a given reward ID.

_This function validates various conditions to ensure that the reward configurations are complete._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the reward configurations are completed. |

### getRewardTierCount

```solidity
function getRewardTierCount(uint256 rewardId_) public view returns (uint256)
```

Get the number of reward tiers for a given reward ID.

_This function returns the count of reward tiers for a specific reward ID.
It retrieves the length of the reward tiers array associated with the reward ID._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The number of reward tiers. |

### getReward

```solidity
function getReward(uint256 rewardId_) public view returns (struct StakeRewards.Reward)
```

Get a reward by ID.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.Reward | The reward details. |

### isRewardClaimable

```solidity
function isRewardClaimable(address account_, uint256 rewardId_, uint256 vestingIndex_) public view returns (bool)
```

Check if a reward is claimable for an account, reward ID, and vesting index.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| rewardId_ | uint256 | The ID of the reward. |
| vestingIndex_ | uint256 | The index of the vesting period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if the reward is claimable. |

### getAccountRewardDetails

```solidity
function getAccountRewardDetails(address account_, uint256 rewardId_, uint256 snapshotMin_, uint256 snapshotMax_) public view returns (struct StakeRewards.AccBaseReward, struct StakeRewards.CacheAverage, uint256)
```

Get the details of an account's reward for a specific reward, snapshot range, and reward tier.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| rewardId_ | uint256 | The ID of the reward. |
| snapshotMin_ | uint256 | The minimum snapshot ID. |
| snapshotMax_ | uint256 | The maximum snapshot ID. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.AccBaseReward | The account's base reward, the cache average, and the length of reward tiers. |
| [1] | struct StakeRewards.CacheAverage |  |
| [2] | uint256 |  |

### _cacheKey

```solidity
function _cacheKey(uint256 min_, uint256 max_) internal pure returns (bytes32)
```

Generates a cache key for snapshot range calculation.

_This function generates a cache key based on the minimum and maximum snapshot values provided._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| min_ | uint256 | The minimum snapshot value. |
| max_ | uint256 | The maximum snapshot value. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | The cache key. |

### _setAverageCalculation

```solidity
function _setAverageCalculation(address account_, uint256 min_, uint256 max_, uint256 average_) internal
```

Sets the average calculation for an account within a specific snapshot range.

_This function sets the average calculation for an account within a specific snapshot range._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| min_ | uint256 | The minimum snapshot value. |
| max_ | uint256 | The maximum snapshot value. |
| average_ | uint256 | The average value to be set. |

### _applyBoosters

```solidity
function _applyBoosters(address account_, uint256 rewardId_, uint256 vestingIndex_) internal
```

Internal function to apply boosters to the given account for a specific reward.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The address of the account to apply the boosters. |
| rewardId_ | uint256 | The ID of the specific reward to apply the boosters. |
| vestingIndex_ | uint256 |  |

### _validateReward

```solidity
function _validateReward(struct StakeRewards.Reward reward_) internal pure returns (bool)
```

_Validate the reward type._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| reward_ | struct StakeRewards.Reward | The reward object to validate. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the reward type is valid. |

### _setReward

```solidity
function _setReward(uint256 rewardId_, uint256 chainId_, enum StakeRewards.RewardType rewardType_, address contractAddress_, uint256 amount_, uint256 percentage_) internal
```

Set or update a reward.

_This internal function sets or updates a reward with the provided details. It validates the reward data
and checks if the reward is already claimed. If the reward is already claimed, the function reverts.
After updating the reward, it emits the `RewardUpdated` event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardId_ | uint256 | The ID of the reward. |
| chainId_ | uint256 | The ID of the chain. |
| rewardType_ | enum StakeRewards.RewardType | The type of the reward. |
| contractAddress_ | address | The address of the contract (only for Token rewards). |
| amount_ | uint256 | The amount of the reward. |
| percentage_ | uint256 | The boost percentage of the reward. |

### _claimReward

```solidity
function _claimReward(address account_, uint256 rewardId_, uint256 vestingIndex_) internal
```

Claim rewards for an account and a specific reward with a vesting index.

_This function allows an account to claim their rewards for a specific reward and vesting index.
It performs various checks and calculations to determine the claimability and distribution of the rewards._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| rewardId_ | uint256 | The ID of the reward. |
| vestingIndex_ | uint256 | The index of the vesting period. |

### _isVestingPeriodsPrepared

```solidity
function _isVestingPeriodsPrepared(address account_, uint256 rewardId_) internal view returns (bool)
```

Check if the vesting periods are prepared for an account and a specific reward.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| rewardId_ | uint256 | The ID of the reward. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if the vesting periods are prepared. |

### _getAccountSnapshotsAverage

```solidity
function _getAccountSnapshotsAverage(address account_, uint256 snapshotMin_, uint256 snapshotMax_) internal view returns (struct StakeRewards.CacheAverage)
```

Get the average of account snapshots within a given range.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| snapshotMin_ | uint256 | The minimum snapshot ID. |
| snapshotMax_ | uint256 | The maximum snapshot ID. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct StakeRewards.CacheAverage | The average of account snapshots within the range. |

### _prepareRewardVestingPeriods

```solidity
function _prepareRewardVestingPeriods(address account_, uint256 rewardId_) internal
```

Prepare the vesting periods for an account and a specific reward.

_This function prepares the vesting periods for an account and a specific reward.
It calculates the base reward, stores it in the state variable, and creates the vesting periods._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| rewardId_ | uint256 | The ID of the reward. |

