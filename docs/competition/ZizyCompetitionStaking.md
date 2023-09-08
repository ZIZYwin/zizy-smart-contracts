# Solidity API

## ZizyCompetitionStaking

### stakeToken

```solidity
contract IERC20Upgradeable stakeToken
```

The address of the stake token used for staking (ZIZY)

### competitionFactory

```solidity
address competitionFactory
```

The address of the competition factory contract

### stakeFeePercentage

```solidity
uint8 stakeFeePercentage
```

The percentage of stake fee deducted from staked tokens

### feeAddress

```solidity
address feeAddress
```

The address that receives the stake/unstake fees

### currentPeriod

```solidity
uint256 currentPeriod
```

The current period number

### totalStaked

```solidity
uint256 totalStaked
```

The total balance of staked tokens

### coolingDelay

```solidity
uint256 coolingDelay
```

The delay time for the cooling off period after staking

### coolestDelay

```solidity
uint256 coolestDelay
```

The coolest delay time after staking

### coolingPercentage

```solidity
uint8 coolingPercentage
```

The percentage of tokens that enter the cooling off period after staking

### lockModerator

```solidity
address lockModerator
```

Stake/Unstake lock mechanism moderator

### totalStakedSnapshot

```solidity
mapping(uint256 => uint256) totalStakedSnapshot
```

### StakeFeePercentageUpdated

```solidity
event StakeFeePercentageUpdated(uint8 newPercentage)
```

Event emitted when the stake fee percentage is updated

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newPercentage | uint8 | The new stake fee percentage |

### StakeFeeReceived

```solidity
event StakeFeeReceived(uint256 amount, uint256 snapshotId, uint256 periodId)
```

Event emitted when stake fee is received

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The amount of stake fee received |
| snapshotId | uint256 | The ID of the snapshot |
| periodId | uint256 | The ID of the period |

### UnStakeFeeReceived

```solidity
event UnStakeFeeReceived(uint256 amount, uint256 snapshotId, uint256 periodId)
```

Event emitted when unstake fee is received

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The amount of unstake fee received |
| snapshotId | uint256 | The ID of the snapshot |
| periodId | uint256 | The ID of the period |

### SnapshotCreated

```solidity
event SnapshotCreated(uint256 id, uint256 periodId)
```

Event emitted when a snapshot is created

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | The ID of the snapshot |
| periodId | uint256 | The ID of the period |

### Stake

```solidity
event Stake(address account, uint256 amount, uint256 fee, uint256 snapshotId, uint256 periodId)
```

Event emitted when a stake is made

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account that made the stake |
| amount | uint256 | The amount of tokens staked |
| fee | uint256 | The stake fee amount |
| snapshotId | uint256 | The ID of the snapshot |
| periodId | uint256 | The ID of the period |

### UnStake

```solidity
event UnStake(address account, uint256 amount, uint256 snapshotId, uint256 periodId)
```

Event emitted when an unstake is made

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account that made the unstake |
| amount | uint256 | The amount of tokens unstaked |
| snapshotId | uint256 | The ID of the snapshot |
| periodId | uint256 | The ID of the period |

### CoolingOffSettingsUpdated

```solidity
event CoolingOffSettingsUpdated(uint8 percentage, uint8 coolingDay, uint8 coolestDay)
```

Event emitted when the cooling off settings are updated

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentage | uint8 | The new cooling off percentage |
| coolingDay | uint8 | The cooling off day value |
| coolestDay | uint8 | The coolest day value |

### LockModeratorUpdated

```solidity
event LockModeratorUpdated(address moderator)
```

Event emitted when the lock moderator updated

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| moderator | address | Lock moderator address |

### CompFactoryUpdated

```solidity
event CompFactoryUpdated(address factoryAddress)
```

_Emitted when the competition factory address updated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| factoryAddress | address | The address of competition factory |

### FeeReceiverUpdated

```solidity
event FeeReceiverUpdated(address receiver)
```

_Emitted when the fee receiver address updated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | Fee receiver address |

### PeriodStakeAverageCalculated

```solidity
event PeriodStakeAverageCalculated(address account, uint256 periodId, uint256 average)
```

_Emitted when any account period stake average calculated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Account |
| periodId | uint256 | Period ID |
| average | uint256 | Average of period snapshots |

### onlyCallFromFactory

```solidity
modifier onlyCallFromFactory()
```

_Modifier that allows the function to be called only from the competition factory contract_

### whenFeeAddressExist

```solidity
modifier whenFeeAddressExist()
```

_Modifier that checks if the fee address is defined_

### whenPeriodExist

```solidity
modifier whenPeriodExist()
```

_Modifier that checks if the current period exists_

### whenCurrentPeriodInBuyStage

```solidity
modifier whenCurrentPeriodInBuyStage()
```

_Modifier that checks if the current period is in the buy stage_

### constructor

```solidity
constructor() public
```

_Constructor function_

### initialize

```solidity
function initialize(address stakeToken_, address feeReceiver_) external
```

Initializes the contract with the specified parameters

_This function should be called only once during contract initialization.
It sets the stake token, fee receiver, and initializes other state variables._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| stakeToken_ | address | The address of the stake token |
| feeReceiver_ | address | The address of the fee receiver |

### setLockModerator

```solidity
function setLockModerator(address moderator) external
```

Sets the address of the lock moderator.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| moderator | address | The address of the new lock moderator. |

### getSnapshotId

```solidity
function getSnapshotId() external view returns (uint256)
```

Gets the current snapshot ID

_This function returns the ID of the current snapshot._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The current snapshot ID |

### updateCoolingOffSettings

```solidity
function updateCoolingOffSettings(uint8 percentage_, uint8 coolingDay_, uint8 coolestDay_) external
```

Updates the cooling off settings for un-staking

_This function allows the contract owner to update the cooling off settings for un-staking.
The percentage should be in the range of 0 to 100.
The cooling off period is specified in number of days, which is converted to seconds.
The coolest off period is also specified in number of days, which is converted to seconds.
Emits a CoolingOffSettingsUpdated event with the new settings._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentage_ | uint8 | The new percentage for cooling off |
| coolingDay_ | uint8 | The number of days for the cooling off period |
| coolestDay_ | uint8 | The number of days for the coolest off period |

### getActivityDetails

```solidity
function getActivityDetails(address account) external view returns (struct IZizyCompetitionStaking.ActivityDetails)
```

Retrieves the activity details for an account

_This function allows to retrieve the activity details for a specific account.
Returns an ActivityDetails struct containing the details of the account's activity._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct IZizyCompetitionStaking.ActivityDetails | The activity details for the specified account |

### getSnapshot

```solidity
function getSnapshot(address account, uint256 snapshotId_) external view returns (struct IZizyCompetitionStaking.Snapshot)
```

Retrieves a specific snapshot for an account

_This function allows to retrieve a specific snapshot for a given account and snapshot ID.
Returns a Snapshot struct containing the details of the snapshot._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account |
| snapshotId_ | uint256 | The ID of the snapshot |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct IZizyCompetitionStaking.Snapshot | The snapshot for the specified account and snapshot ID |

### getPeriod

```solidity
function getPeriod(uint256 periodId_) external view returns (struct IZizyCompetitionStaking.Period)
```

Retrieves the details of a specific period

_This function allows to retrieve the details of a specific period.
Returns a Period struct containing the details of the period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId_ | uint256 | The ID of the period |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct IZizyCompetitionStaking.Period | The details of the specified period |

### getPeriodSnapshotRange

```solidity
function getPeriodSnapshotRange(uint256 periodId) external view returns (uint256, uint256)
```

Retrieves the snapshot range for a specific period

_This function allows to retrieve the snapshot range for a specific period.
It returns the minimum and maximum snapshot IDs for the specified period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The minimum and maximum snapshot IDs for the specified period |
| [1] | uint256 |  |

### snapshot

```solidity
function snapshot() external
```

Takes a snapshot of the current state

_This function is used to take a snapshot of the current state by increasing the snapshot counter.
It can only be called by the contract owner.
It checks if there is an active period and then calls the internal `_snapshot` function to increase the snapshot counter._

### setPeriodId

```solidity
function setPeriodId(uint256 period) external returns (uint256)
```

Sets the period number

_This function is used to set the period number.
It can only be called by the competition factory contract.
It updates the current period, creates a new snapshot, and updates the period information.
If there was a previous active period, it sets the last snapshot of the previous period and marks it as over._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| period | uint256 | The period number to set |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The period number that was set |

### setCompetitionFactory

```solidity
function setCompetitionFactory(address competitionFactory_) external
```

Sets the competition factory contract address

_This function is used to set the competition factory contract address.
It can only be called by the contract owner.
It updates the competition factory contract address to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| competitionFactory_ | address | The address of the competition factory contract |

### setStakeFeePercentage

```solidity
function setStakeFeePercentage(uint8 stakeFeePercentage_) external
```

Sets the stake fee percentage

_This function is used to set the stake fee percentage. It can only be called by the contract owner.
The stake fee percentage should be within the range of 0 to 5
It updates the stake fee percentage to the specified value and emits the StakeFeePercentageUpdated event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| stakeFeePercentage_ | uint8 | The stake fee percentage to be set (between 0 and 5) |

### setFeeAddress

```solidity
function setFeeAddress(address feeAddress_) external
```

Sets the stake fee address

_This function is used to set the stake fee address. It can only be called by the contract owner.
The fee address should not be the zero address.
It updates the fee address to the specified value._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feeAddress_ | address | The address to be set as the stake fee address |

### stake

```solidity
function stake(uint256 amount_) external
```

Stakes tokens

_This function allows an account to stake tokens into the contract.
The tokens are transferred from the caller to the contract.
The stake amount is calculated by subtracting the stake fee from the total amount.
The stake fee is calculated based on the stake fee percentage.
The caller's balance is increased by the stake amount.
If a stake fee is applicable, it is transferred to the fee address.
The total staked amount is increased by the stake amount.
Account details are updated, and a Stake event is emitted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_ | uint256 | The amount of tokens to stake |

### unStake

```solidity
function unStake(uint256 amount_) external
```

Un-stake tokens

_This function allows the user to un-stake a specific amount of tokens.
It checks if the user has sufficient balance for un-staking and if the amount is greater than zero.
It calculates the un-stake fee amount and the remaining amount after deducting the fee using the calculateUnStakeAmounts function.
It updates the user's balance, total staked amount, and account details.
It transfers the un-stake fee to the fee receiver address and transfers the remaining amount of tokens to the user.
It emits the UnStake event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_ | uint256 | The amount of tokens to un-stake |

### getPeriodStakeAverage

```solidity
function getPeriodStakeAverage(address account, uint256 periodId) external view returns (uint256, bool)
```

Get period stake average information

_This function returns the stake average and its calculation status for the given account and period.
It calls the internal function _getPeriodStakeAverage to retrieve the information._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address |
| periodId | uint256 | The period ID |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | average The stake average for the given account and period |
| [1] | bool | calculated Whether the stake average has been calculated for the given account and period |

### getSnapshotAverage

```solidity
function getSnapshotAverage(address account, uint256 min, uint256 max) external view returns (uint256)
```

Get snapshot average for stake rewards

_This function calculates the average balance of the account for the specified snapshot range.
It is used for stake rewards calculation. The function requires the min and max snapshot IDs to be within
the range of existing snapshots. If the account has no stake activity after the min snapshot, the function
returns the last activity balance. It then calculates the sum of snapshot balances within the range, considering
any missing snapshot data. If there are missing snapshots, it scans for any stake activity beyond the max snapshot
to fill in the missing data. If no stake activity is found, the average is calculated based on the current balance._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address |
| min | uint256 | The minimum snapshot ID |
| max | uint256 | The maximum snapshot ID |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | average The average balance of the account for the given snapshot range |

### getPeriodSnapshotsAverage

```solidity
function getPeriodSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool)
```

Get period snapshot average with min/max range

_This function calculates the average balance of the account for the specified period and snapshot range.
It requires the min and max snapshot IDs to be within the range of existing snapshots for the given period.
The function returns the average balance and a boolean indicating whether the average has been calculated for
the given period. If the average hasn't been calculated, the average value will be 0 and calculated will be false.
If the average has been calculated, the function iterates through the snapshot range and calculates the sum of balances.
It then divides the sum by the number of snapshots to get the average balance. The calculated value will be true._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address |
| periodId | uint256 | The period ID |
| min | uint256 | The minimum snapshot ID |
| max | uint256 | The maximum snapshot ID |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | average The average balance of the account for the given period and snapshot range |
| [1] | bool | calculated Whether the average has been calculated for the given period |

### calculatePeriodStakeAverage

```solidity
function calculatePeriodStakeAverage() external
```

Calculate the period stake average for the caller's account

_This function calculates the period stake average for the caller's account.
It can only be called during a valid period and within the buy stage of the current period.
The function checks if the average has already been calculated for the current period.
If it has, the function reverts with an error message.
If the average has not been calculated, the function iterates through the snapshots of the account in reverse order.
It updates the balances and existence flags of the snapshots, and calculates the total stake amount.
Finally, it calculates the average stake amount and stores it in the averages mapping for the caller's account and period._

### balanceOf

```solidity
function balanceOf(address account) public view returns (uint256)
```

Retrieves the balance of staked tokens for a specific account

_This function allows to retrieve the staked balance of tokens for a specific account.
It returns the number of tokens held by the specified account._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The balance of tokens for the specified account |

### calculateUnStakeAmounts

```solidity
function calculateUnStakeAmounts(uint256 requestAmount_) public view returns (uint256, uint256)
```

Calculate the un-stake fee amount and remaining amount after cooling off period

_This function calculates the un-stake fee amount and the remaining amount after deducting the fee,
based on the cooling off settings and the current period.
It takes the requested un-stake amount as input and returns the un-stake fee amount and the remaining amount.
If the period does not exist or the cooling off delays are not defined, the function returns the requested amount as is.
If the current time is within the coolest period, the function deducts the cooling off fee percentage from the requested amount.
If the current time is within the cooling off period, the function calculates the remaining amount after deducting the cooling off fee gradually.
Otherwise, if the cooling off period has passed, the function returns the requested amount as is, without any fee deduction._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| requestAmount_ | uint256 | The amount requested for un-stake |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The un-stake fee amount and the remaining amount after deducting the fee |
| [1] | uint256 |  |

### _snapshot

```solidity
function _snapshot() internal
```

Increases the snapshot counter

_This internal function is used to increase the snapshot counter.
It increments the snapshotId and records the total staked balance for the current snapshot.
Emits a SnapshotCreated event with the current snapshot ID and the current period._

### _isInRange

```solidity
function _isInRange(uint256 number, uint256 min, uint256 max) internal pure returns (bool)
```

Checks if a number is within the specified range

_This internal function is used to check if a given number is within the specified range.
It throws an error if the minimum value is higher than the maximum value.
Returns true if the number is greater than or equal to the minimum value and less than or equal to the maximum value._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| number | uint256 | The number to check |
| min | uint256 | The minimum value of the range |
| max | uint256 | The maximum value of the range |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the number is within the range |

### updateDetails

```solidity
function updateDetails(address account, uint256 previousBalance, uint256 currentBalance) internal
```

Updates the account details

_This internal function is used to update the account details based on the provided balances.
It updates the current snapshot balance and the previous snapshot balance if it doesn't exist.
It also updates the account details with the latest snapshot and activity balance._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account |
| previousBalance | uint256 | The previous balance of the account |
| currentBalance | uint256 | The current balance of the account |

### _getPeriod

```solidity
function _getPeriod(uint256 periodId_) internal view returns (struct ICompetitionFactory.Period)
```

Get period details from the competition factory

_This internal function retrieves the period details from the competition factory contract.
It returns the (start time, end time, ticket buy start time, ticket buy end time, competition count on period, completion status of the period, existence status)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId_ | uint256 | The ID of the period |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Period | The start time, end time, ticket buy start time, ticket buy end time, total allocation, existence status, and completion status of the period |

### _unStakeFeeTransfer

```solidity
function _unStakeFeeTransfer(uint256 amount, uint256 snapshotId_, uint256 periodId) internal
```

Transfer un-stake fees

_This internal function transfers the un-stake fees to the fee receiver address.
It checks if the amount is greater than zero before transferring the fees.
It uses the safeTransfer function of the stakeToken to transfer the fees.
It emits the UnStakeFeeReceived event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The amount of un-stake fees to transfer |
| snapshotId_ | uint256 | The snapshot ID |
| periodId | uint256 | The period ID |

### _getPeriodStakeAverage

```solidity
function _getPeriodStakeAverage(address account, uint256 periodId) internal view returns (uint256, bool)
```

Get period stake average information

_This internal function returns the stake average and its calculation status for the given account and period.
It retrieves the PeriodStakeAverage struct from the averages mapping and returns the average and _calculated values._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address |
| periodId | uint256 | The period ID |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | average The stake average for the given account and period |
| [1] | bool | calculated Whether the stake average has been calculated for the given account and period |

