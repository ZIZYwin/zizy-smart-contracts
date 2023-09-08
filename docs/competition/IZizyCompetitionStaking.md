# Solidity API

## IZizyCompetitionStaking

This interface represents the ZizyCompetitionStaking contract.

_This interface defines the functions of the ZizyCompetitionStaking contract._

### Snapshot

```solidity
struct Snapshot {
  uint256 balance;
  uint256 prevSnapshotBalance;
  bool _exist;
}
```

### Period

```solidity
struct Period {
  uint256 firstSnapshotId;
  uint256 lastSnapshotId;
  bool isOver;
  bool _exist;
}
```

### ActivityDetails

```solidity
struct ActivityDetails {
  uint256 lastSnapshotId;
  uint256 lastActivityBalance;
  bool _exist;
}
```

### PeriodStakeAverage

```solidity
struct PeriodStakeAverage {
  uint256 average;
  bool _calculated;
}
```

### getSnapshotAverage

```solidity
function getSnapshotAverage(address account, uint256 min, uint256 max) external view returns (uint256)
```

Get the average stake amount for an account within a specified range of snapshots.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account. |
| min | uint256 | The minimum snapshot ID (inclusive). |
| max | uint256 | The maximum snapshot ID (inclusive). |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The average stake amount for the account. |

### getPeriodSnapshotsAverage

```solidity
function getPeriodSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool)
```

Get the average stake amount for an account within a specified range of snapshots in a particular period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account. |
| periodId | uint256 | The ID of the period. |
| min | uint256 | The minimum snapshot ID (inclusive). |
| max | uint256 | The maximum snapshot ID (inclusive). |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The average stake amount for the account and period, and a boolean indicating if the average is calculated. |
| [1] | bool |  |

### getPeriodStakeAverage

```solidity
function getPeriodStakeAverage(address account, uint256 periodId) external view returns (uint256, bool)
```

Get the average stake amount for an account in a specific period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account. |
| periodId | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The average stake amount for the account and period, and a boolean indicating if the average is calculated. |
| [1] | bool |  |

### getPeriodSnapshotRange

```solidity
function getPeriodSnapshotRange(uint256 periodId) external view returns (uint256, uint256)
```

Get the range of snapshot IDs for a specific period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The minimum and maximum snapshot IDs for the period. |
| [1] | uint256 |  |

### setPeriodId

```solidity
function setPeriodId(uint256 period) external returns (uint256)
```

Set the period ID for the staking contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| period | uint256 | The new period ID to set. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The new period ID. |

### getSnapshotId

```solidity
function getSnapshotId() external view returns (uint256)
```

Get the current snapshot ID.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The current snapshot ID. |

### stake

```solidity
function stake(uint256 amount_) external
```

Stake tokens.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_ | uint256 | The amount of tokens to stake. |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```

Get the balance of tokens staked by an account.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the account. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The balance of tokens staked by the account. |

### getPeriod

```solidity
function getPeriod(uint256 periodId_) external view returns (struct IZizyCompetitionStaking.Period)
```

Get information about a specific period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId_ | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct IZizyCompetitionStaking.Period | The first snapshot id of period, last snapshot id of period, completion status of period, existence status of period |

### unStake

```solidity
function unStake(uint256 amount_) external
```

Un-stake tokens.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_ | uint256 | The amount of tokens to un-stake. |

