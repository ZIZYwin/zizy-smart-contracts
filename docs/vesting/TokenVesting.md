# Solidity API

## TokenVesting

### VestingSchedule

```solidity
struct VestingSchedule {
  bool initialized;
  address beneficiary;
  uint256 cliff;
  uint256 start;
  uint256 duration;
  uint256 slicePeriodSeconds;
  bool revocable;
  uint256 amountTotal;
  uint256 released;
  bool revoked;
}
```

### ScheduleCreated

```solidity
event ScheduleCreated(address beneficiary, bytes32 scheduleId, uint256 cliff, uint256 start, uint256 duration, uint256 slicePeriodSeconds, bool revocable, uint256 amount)
```

### ScheduleRevoked

```solidity
event ScheduleRevoked(bytes32 scheduleId)
```

### Withdraw

```solidity
event Withdraw(address withdrawer, uint256 amount)
```

### TokenReleased

```solidity
event TokenReleased(bytes32 scheduleId, uint256 amount)
```

### onlyIfVestingScheduleNotRevoked

```solidity
modifier onlyIfVestingScheduleNotRevoked(bytes32 vestingScheduleId)
```

_Reverts if the vesting schedule does not exist or has been revoked._

### constructor

```solidity
constructor(address token_) public
```

_Creates a vesting contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token_ | address | address of the ERC20 token contract |

### createVestingSchedule

```solidity
function createVestingSchedule(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _slicePeriodSeconds, bool _revocable, uint256 _amount) external
```

Creates a new vesting schedule for a beneficiary.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _beneficiary | address | address of the beneficiary to whom vested tokens are transferred |
| _start | uint256 | start time of the vesting period |
| _cliff | uint256 | duration in seconds of the cliff in which tokens will begin to vest |
| _duration | uint256 | duration in seconds of the period in which the tokens will vest |
| _slicePeriodSeconds | uint256 | duration of a slice period for the vesting in seconds |
| _revocable | bool | whether the vesting is revocable or not |
| _amount | uint256 | total amount of tokens to be released at the end of the vesting |

### revoke

```solidity
function revoke(bytes32 vestingScheduleId) external
```

Revokes the vesting schedule for given identifier.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| vestingScheduleId | bytes32 | the vesting schedule identifier |

### withdraw

```solidity
function withdraw(uint256 amount) external
```

Withdraw the specified amount if possible.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | the amount to withdraw |

### release

```solidity
function release(bytes32 vestingScheduleId, uint256 amount) public
```

Release vested amount of tokens.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| vestingScheduleId | bytes32 | the vesting schedule identifier |
| amount | uint256 | the amount to release |

### getVestingSchedulesCountByBeneficiary

```solidity
function getVestingSchedulesCountByBeneficiary(address _beneficiary) external view returns (uint256)
```

_Returns the number of vesting schedules associated to a beneficiary._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the number of vesting schedules |

### getVestingIdAtIndex

```solidity
function getVestingIdAtIndex(uint256 index) external view returns (bytes32)
```

_Returns the vesting schedule id at the given index._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | the vesting id |

### getVestingScheduleByAddressAndIndex

```solidity
function getVestingScheduleByAddressAndIndex(address holder, uint256 index) external view returns (struct TokenVesting.VestingSchedule)
```

Returns the vesting schedule information for a given holder and index.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct TokenVesting.VestingSchedule | the vesting schedule structure information |

### getVestingSchedulesTotalAmount

```solidity
function getVestingSchedulesTotalAmount() external view returns (uint256)
```

Returns the total amount of vesting schedules.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the total amount of vesting schedules |

### getToken

```solidity
function getToken() external view returns (address)
```

_Returns the address of the ERC20 token managed by the vesting contract._

### getVestingSchedulesCount

```solidity
function getVestingSchedulesCount() public view returns (uint256)
```

_Returns the number of vesting schedules managed by this contract._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the number of vesting schedules |

### computeReleasableAmount

```solidity
function computeReleasableAmount(bytes32 vestingScheduleId) external view returns (uint256)
```

Computes the vested amount of tokens for the given vesting schedule identifier.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the vested amount |

### getVestingSchedule

```solidity
function getVestingSchedule(bytes32 vestingScheduleId) public view returns (struct TokenVesting.VestingSchedule)
```

Returns the vesting schedule information for a given identifier.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct TokenVesting.VestingSchedule | the vesting schedule structure information |

### getWithdrawableAmount

```solidity
function getWithdrawableAmount() public view returns (uint256)
```

_Returns the amount of tokens that can be withdrawn by the owner._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the amount of tokens |

### computeNextVestingScheduleIdForHolder

```solidity
function computeNextVestingScheduleIdForHolder(address holder) public view returns (bytes32)
```

_Computes the next vesting schedule identifier for a given holder address._

### getLastVestingScheduleForHolder

```solidity
function getLastVestingScheduleForHolder(address holder) external view returns (struct TokenVesting.VestingSchedule)
```

_Returns the last vesting schedule for a given holder address._

### computeVestingScheduleIdForAddressAndIndex

```solidity
function computeVestingScheduleIdForAddressAndIndex(address holder, uint256 index) public pure returns (bytes32)
```

_Computes the vesting schedule identifier for an address and an index._

### _computeReleasableAmount

```solidity
function _computeReleasableAmount(struct TokenVesting.VestingSchedule vestingSchedule) internal view returns (uint256)
```

_Computes the releasable amount of tokens for a vesting schedule._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the amount of releasable tokens |

### getCurrentTime

```solidity
function getCurrentTime() internal view virtual returns (uint256)
```

_Returns the current time._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the current timestamp in seconds. |

