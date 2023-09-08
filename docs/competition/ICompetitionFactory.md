# Solidity API

## ICompetitionFactory

This interface represents the CompetitionFactory contract.

_This interface defines the functions of the CompetitionFactory contract._

### Competition

```solidity
struct Competition {
  contract IZizyCompetitionTicket ticket;
  address sellToken;
  uint256 ticketPrice;
  uint256 snapshotMin;
  uint256 snapshotMax;
  uint32 ticketSold;
  bool pairDefined;
  bool _exist;
}
```

### Period

```solidity
struct Period {
  uint256 startTime;
  uint256 endTime;
  uint256 ticketBuyStartTime;
  uint256 ticketBuyEndTime;
  uint256 competitionCount;
  bool isOver;
  bool _exist;
}
```

### Tier

```solidity
struct Tier {
  uint256 min;
  uint256 max;
  uint32 allocation;
}
```

### Allocation

```solidity
struct Allocation {
  uint32 bought;
  uint32 max;
  bool hasAllocation;
}
```

### totalPeriodCount

```solidity
function totalPeriodCount() external view returns (uint256)
```

Get the total count of periods.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The total count of periods. |

### totalCompetitionCount

```solidity
function totalCompetitionCount() external view returns (uint256)
```

Get the total count of competitions.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The total count of competitions. |

### getCompetitionIdWithIndex

```solidity
function getCompetitionIdWithIndex(uint256 periodId, uint256 index) external view returns (uint256)
```

Get the competition ID with the specified index.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| index | uint256 | The index of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The competition ID. |

### getPeriod

```solidity
function getPeriod(uint256 periodId) external view returns (struct ICompetitionFactory.Period)
```

Get the period details.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Period | The start time, end time, ticket buy start time, ticket buy end time, competition count on period, completion status of period, existence status of period |

### getAllocation

```solidity
function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (struct ICompetitionFactory.Allocation)
```

Get the allocation details for an account in a period and competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address. |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Allocation | The allocation for the account (staking percentage, winning percentage, and existence flag). |

### hasParticipation

```solidity
function hasParticipation(address account_, uint256 periodId_) external view returns (bool)
```

Check if an account has participated in a period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account address. |
| periodId_ | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the account has participated. |

### isCompetitionSettingsDefined

```solidity
function isCompetitionSettingsDefined(uint256 periodId, uint256 competitionId) external view returns (bool)
```

Check if competition settings are defined for a period and competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the competition settings are defined. |

### getPeriodCompetition

```solidity
function getPeriodCompetition(uint256 periodId, uint256 competitionId) external view returns (struct ICompetitionFactory.Competition)
```

Get the competition address and pause flag for a period and competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Competition | The competition address and pause flag. |

### getPeriodCompetitionCount

```solidity
function getPeriodCompetitionCount(uint256 periodId) external view returns (uint256)
```

Get the count of competitions for a period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The count of competitions. |

### pauseCompetitionTransfer

```solidity
function pauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external
```

Pause the ticket transfer of competition

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

### unpauseCompetitionTransfer

```solidity
function unpauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external
```

Unpause the ticket transfer of competition

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

### setCompetitionBaseURI

```solidity
function setCompetitionBaseURI(uint256 periodId, uint256 competitionId, string baseUri_) external
```

Set the ticket base URI for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| baseUri_ | string | The base URI to set. |

### totalSupplyOfCompetition

```solidity
function totalSupplyOfCompetition(uint256 periodId, uint256 competitionId) external view returns (uint256)
```

Get the total sold ticket count for a competition

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The total supply of competitions. |

