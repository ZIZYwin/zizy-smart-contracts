# Solidity API

## CompetitionFactory

This contract manages competitions and ticket sales for different periods.

### MAX_TICKET_PER_COMPETITION

```solidity
uint32 MAX_TICKET_PER_COMPETITION
```

### activePeriod

```solidity
uint256 activePeriod
```

The ID of the active period

### totalPeriodCount

```solidity
uint256 totalPeriodCount
```

The total number of periods

### totalCompetitionCount

```solidity
uint256 totalCompetitionCount
```

The total number of competitions

### stakingContract

```solidity
contract IZizyCompetitionStaking stakingContract
```

The staking contract

### ticketDeployer

```solidity
contract ITicketDeployer ticketDeployer
```

The ticket deployer contract

### paymentReceiver

```solidity
address paymentReceiver
```

The address to receive payment

### ticketMinter

```solidity
address ticketMinter
```

The address authorized to mint tickets

### NewPeriod

```solidity
event NewPeriod(uint256 periodId)
```

Event emitted when a new period is created.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the new period. |

### NewCompetition

```solidity
event NewCompetition(uint256 periodId, uint256 competitionId, address ticketAddress)
```

Event emitted when a new competition is created.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period in which the competition is created. |
| competitionId | uint256 | The ID of the new competition. |
| ticketAddress | address | The address of the competition ticket contract. |

### TicketBuy

```solidity
event TicketBuy(address account, uint256 periodId, uint256 competitionId, uint32 ticketCount)
```

Event emitted when a ticket is bought.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account that bought the ticket. |
| periodId | uint256 | The ID of the period in which the ticket is bought. |
| competitionId | uint256 | The ID of the competition for which the ticket is bought. |
| ticketCount | uint32 | The number of tickets bought. |

### TicketSend

```solidity
event TicketSend(address account, uint256 periodId, uint256 competitionId, uint256 ticketId)
```

Event emitted when a ticket is sent.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account that sent the ticket. |
| periodId | uint256 | The ID of the period in which the ticket is sent. |
| competitionId | uint256 | The ID of the competition for which the ticket is sent. |
| ticketId | uint256 | The ID of the sent ticket. |

### AllocationUpdate

```solidity
event AllocationUpdate(address account, uint256 periodId, uint256 competitionId, uint32 bought, uint32 max)
```

Event emitted when the allocation for an account is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account for which the allocation is updated. |
| periodId | uint256 | The ID of the period in which the allocation is updated. |
| competitionId | uint256 | The ID of the competition for which the allocation is updated. |
| bought | uint32 | The number of tickets bought by the account. |
| max | uint32 | The maximum allocation limit for the account. |

### PaymentReceiverUpdate

```solidity
event PaymentReceiverUpdate(address receiver)
```

This event is emitted when the payment receiver address is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | The new address of the payment receiver. |

### TicketMinterUpdate

```solidity
event TicketMinterUpdate(address ticketMinter)
```

This event is emitted when the ticket minter address is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ticketMinter | address | The new address of the ticket minter. |

### StakingContractUpdate

```solidity
event StakingContractUpdate(address stakingContract)
```

This event is emitted when the staking contract address is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| stakingContract | address | The new address of the staking contract. |

### TicketDeployerUpdate

```solidity
event TicketDeployerUpdate(address ticketDeployer)
```

This event is emitted when the ticket deployer address is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ticketDeployer | address | The new address of the ticket deployer. |

### ActivePeriodUpdate

```solidity
event ActivePeriodUpdate(uint256 newActivePeriodId)
```

This event is emitted when the active period ID is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newActivePeriodId | uint256 | The new active period ID. |

### PeriodUpdate

```solidity
event PeriodUpdate(uint256 periodId)
```

This event is emitted when a period is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the updated period. |

### PaymentConfigUpdate

```solidity
event PaymentConfigUpdate(uint256 periodId, uint256 competitionId, address token, uint256 ticketPrice)
```

This event is emitted when the payment configuration is updated for a specific period and competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period for which the payment configuration is updated. |
| competitionId | uint256 | The ID of the competition for which the payment configuration is updated. |
| token | address | The address of the token used for payments. |
| ticketPrice | uint256 | The updated ticket price for the competition. |

### SnapshotRangesUpdate

```solidity
event SnapshotRangesUpdate(uint256 periodId, uint256 competitionId, uint256 min, uint256 max)
```

This event is emitted when the snapshot ranges are updated for a specific period and competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period for which the snapshot ranges are updated. |
| competitionId | uint256 | The ID of the competition for which the snapshot ranges are updated. |
| min | uint256 | The updated minimum snapshot ID. |
| max | uint256 | The updated maximum snapshot ID. |

### TiersUpdate

```solidity
event TiersUpdate(uint256 periodId, uint256 competitionId)
```

This event is emitted when the tiers are updated for a specific period and competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period for which the tiers are updated. |
| competitionId | uint256 | The ID of the competition for which the tiers are updated. |

### stakeContractIsSet

```solidity
modifier stakeContractIsSet()
```

Modifier to check if the staking contract is set.

### ticketDeployerIsSet

```solidity
modifier ticketDeployerIsSet()
```

Modifier to check if the ticket deployer contract is set.

### paymentReceiverIsSet

```solidity
modifier paymentReceiverIsSet()
```

Modifier to check if the payment receiver address is set.

### onlyMinter

```solidity
modifier onlyMinter()
```

Modifier to caller is minter account

### constructor

```solidity
constructor() public
```

_Constructor function_

### initialize

```solidity
function initialize(address receiver_, address minter_) external
```

Initializes the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address to receive payments. |
| minter_ | address | The address authorized to mint tickets. |

### getCompetitionIdWithIndex

```solidity
function getCompetitionIdWithIndex(uint256 periodId, uint256 index) external view returns (uint256)
```

Gets the competition ID with the index number of the period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| index | uint256 | The index number. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The competition ID. |

### hasParticipation

```solidity
function hasParticipation(address account_, uint256 periodId_) external view returns (bool)
```

Checks if any account has participation in the specified period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_ | address | The account to check. |
| periodId_ | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if the account has participation. |

### setPaymentReceiver

```solidity
function setPaymentReceiver(address receiver_) external
```

Sets the payment receiver address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address to receive payments. |

### setTicketMinter

```solidity
function setTicketMinter(address minter_) external
```

Sets the ticket minter address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter_ | address | The address authorized to mint tickets. |

### canTicketBuy

```solidity
function canTicketBuy(uint256 periodId, uint256 competitionId) external view returns (bool)
```

Checks if tickets can be bought for the specified competition and period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if tickets can be bought. |

### getAllocation

```solidity
function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (struct ICompetitionFactory.Allocation)
```

Gets the competition allocation for an account.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account for which to get the allocation. |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Allocation | The allocation details. |

### setStakingContract

```solidity
function setStakingContract(address stakingContract_) external
```

Sets the staking contract address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| stakingContract_ | address | The address of the staking contract. |

### setTicketDeployer

```solidity
function setTicketDeployer(address ticketDeployer_) external
```

Sets the ticket deployer contract address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ticketDeployer_ | address | The address of the ticket deployer contract. |

### setActivePeriod

```solidity
function setActivePeriod(uint256 periodId) external
```

Sets the active period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period to set as active. |

### createPeriod

```solidity
function createPeriod(uint256 newPeriodId, uint256 startTime_, uint256 endTime_, uint256 ticketBuyStart_, uint256 ticketBuyEnd_) external returns (uint256)
```

Creates a competition period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newPeriodId | uint256 | The ID of the new period. |
| startTime_ | uint256 | The start time of the period. |
| endTime_ | uint256 | The end time of the period. |
| ticketBuyStart_ | uint256 | The start time for ticket buying. |
| ticketBuyEnd_ | uint256 | The end time for ticket buying. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The ID of the new period. |

### updatePeriod

```solidity
function updatePeriod(uint256 periodId_, uint256 startTime_, uint256 endTime_, uint256 ticketBuyStart_, uint256 ticketBuyEnd_) external returns (bool)
```

Updates the date ranges of a period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId_ | uint256 | The ID of the period to update. |
| startTime_ | uint256 | The new start time of the period. |
| endTime_ | uint256 | The new end time of the period. |
| ticketBuyStart_ | uint256 | The new start time for ticket buying. |
| ticketBuyEnd_ | uint256 | The new end time for ticket buying. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if the update was successful. |

### createCompetition

```solidity
function createCompetition(uint256 periodId, uint256 competitionId, string name_, string symbol_) external returns (address, uint256, uint256)
```

Creates a competition for the current period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the current period. |
| competitionId | uint256 | The ID of the competition to create. |
| name_ | string | The name of the competition ticket. |
| symbol_ | string | The symbol of the competition ticket. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address and IDs of the created competition. |
| [1] | uint256 |  |
| [2] | uint256 |  |

### setCompetitionPayment

```solidity
function setCompetitionPayment(uint256 periodId, uint256 competitionId, address token, uint256 ticketPrice) external
```

Sets the payment settings for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| token | address | The address of the token to be used for payment. |
| ticketPrice | uint256 | The price of each ticket. |

### setCompetitionSnapshotRange

```solidity
function setCompetitionSnapshotRange(uint256 periodId, uint256 competitionId, uint256 min, uint256 max) external
```

Sets the snapshot range for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| min | uint256 | The minimum snapshot value. |
| max | uint256 | The maximum snapshot value. |

### setCompetitionTiers

```solidity
function setCompetitionTiers(uint256 periodId, uint256 competitionId, uint256[] mins, uint256[] maxs, uint32[] allocs) external
```

Sets the tiers for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| mins | uint256[] | The array of minimum values for each tier. |
| maxs | uint256[] | The array of maximum values for each tier. |
| allocs | uint32[] | The array of allocations for each tier. |

### buyTicket

```solidity
function buyTicket(uint256 periodId, uint256 competitionId, uint32 ticketCount) external
```

Buys tickets for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| ticketCount | uint32 | The number of tickets to buy. |

### mintTicket

```solidity
function mintTicket(uint256 periodId, uint256 competitionId, address to_, uint256 ticketId_) external
```

Mints and sends a ticket to an address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| to_ | address | The address to receive the ticket. |
| ticketId_ | uint256 | The ID of the ticket to mint. |

### mintBatchTicket

```solidity
function mintBatchTicket(uint256 periodId, uint256 competitionId, address to_, uint256[] ticketIds) external
```

Mints and sends a batch of tickets to an address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| to_ | address | The address to receive the tickets. |
| ticketIds | uint256[] | The array of ticket IDs to mint. |

### getPeriod

```solidity
function getPeriod(uint256 periodId) external view returns (struct ICompetitionFactory.Period)
```

Gets the details of a period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Period | The details of the period. |

### getPeriodCompetition

```solidity
function getPeriodCompetition(uint256 periodId, uint256 competitionId) external view returns (struct ICompetitionFactory.Competition)
```

Gets the details of a competition within a period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Competition | The details of the competition. |

### getPeriodCompetitionCount

```solidity
function getPeriodCompetitionCount(uint256 periodId) external view returns (uint256)
```

Gets the count of competitions within a period.

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

Pauses the transfers of tickets for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

### unpauseCompetitionTransfer

```solidity
function unpauseCompetitionTransfer(uint256 periodId, uint256 competitionId) external
```

Unpauses the transfers of tickets for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

### setCompetitionBaseURI

```solidity
function setCompetitionBaseURI(uint256 periodId, uint256 competitionId, string baseUri_) external
```

Sets the base URI for a competition ticket contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |
| baseUri_ | string | The new base URI. |

### totalSupplyOfCompetition

```solidity
function totalSupplyOfCompetition(uint256 periodId, uint256 competitionId) external view returns (uint256)
```

Gets the total supply of tickets for a competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The total supply of tickets. |

### isCompetitionSettingsDefined

```solidity
function isCompetitionSettingsDefined(uint256 periodId, uint256 competitionId) public view returns (bool)
```

Checks if the competition ticket buy settings are defined.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if the competition settings are defined. |

### _competitionKey

```solidity
function _competitionKey(uint256 periodId, uint256 competitionId) internal pure returns (bytes32)
```

Generates the hash of the period competition.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | The hash of the period competition. |

### _getAllocation

```solidity
function _getAllocation(address account, uint256 periodId, uint256 competitionId) internal view returns (struct ICompetitionFactory.Allocation)
```

Gets the competition allocation for an account.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account for which to get the allocation. |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ICompetitionFactory.Allocation | The allocation details. |

### _isCompetitionTiersDefined

```solidity
function _isCompetitionTiersDefined(uint256 periodId, uint256 competitionId) internal view returns (bool)
```

Checks if the competition tiers are defined.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating if the competition tiers are defined. |

### _compTicket

```solidity
function _compTicket(uint256 periodId, uint256 competitionId) internal view returns (address)
```

Gets the ticket contract address for a competition within a period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the period. |
| competitionId | uint256 | The ID of the competition. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of the ticket contract. |

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

## ITicketDeployer

This interface represents the TicketDeployer contract.

_This interface defines the functions of the TicketDeployer contract._

### deploy

```solidity
function deploy(string name_, string symbol_) external returns (uint256, address)
```

Deploy a new Ticket NFT contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the ticket contract. |
| symbol_ | string | The symbol of the ticket contract. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The index of the deployed contract and the address of the deployed ticket contract. |
| [1] | address |  |

### getDeployedContractCount

```solidity
function getDeployedContractCount() external view returns (uint256)
```

Get the count of deployed contracts.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The count of deployed contracts. |

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

### setTimeLock

```solidity
function setTimeLock(address account, uint256 lockTime) external
```

Set time lock for un-stake

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Lock account |
| lockTime | uint256 | Lock timer as second |

## IZizyCompetitionTicket

This interface represents the ZizyCompetitionTicket contract, which is an ERC721 and ERC721Enumerable compliant contract.

_This interface defines the functions and events of the ZizyCompetitionTicket contract._

### setBaseURI

```solidity
function setBaseURI(string baseUri_) external
```

Sets the base URI for computing token URIs.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseUri_ | string | The new base URI. |

### mint

```solidity
function mint(address to_, uint256 ticketId_) external
```

Mints a new ticket token and assigns it to the specified address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to which the ticket token will be minted. |
| ticketId_ | uint256 | The ID of the new ticket token. |

### pause

```solidity
function pause() external
```

Pauses the minting and transferring of ticket tokens.

### unpause

```solidity
function unpause() external
```

Unpauses the minting and transferring of ticket tokens.

### isPaused

```solidity
function isPaused() external view returns (bool)
```

_Returns true if the contract is paused, and false otherwise._

## IZizyPoPa

This interface represents the ZizyPoPa contract, which is an ERC721 and ERC721Enumerable compliant contract.

_This interface defines the functions and events of the ZizyPoPa contract._

### setMinter

```solidity
function setMinter(address minter_) external
```

Sets the minter address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter_ | address | The address of the new minter. |

### setBaseURI

```solidity
function setBaseURI(string baseUri_) external
```

Sets the base URI for computing token URIs.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseUri_ | string | The new base URI. |

### mint

```solidity
function mint(address to_, uint256 tokenId_) external
```

Mints a new PoPa token and assigns it to the specified address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to which the PoPa token will be minted. |
| tokenId_ | uint256 | The token ID of the new PoPa token. |

### pause

```solidity
function pause() external
```

Pauses the minting and transferring of PoPa tokens.

### unpause

```solidity
function unpause() external
```

Unpauses the minting and transferring of PoPa tokens.

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
  HoldingPOPA,
  StakingBalance
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
| boosterType | enum StakeRewards.BoosterType | The type of the booster (StakingBalance or HoldingPOPA). |
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
| type_ | enum StakeRewards.BoosterType | The type of the booster (HoldingPOPA, StakingBalance). |
| contractAddress_ | address | The address of the contract (for HoldingPOPA boosters). |
| amount_ | uint256 | The amount required for the booster (for StakingBalance boosters). |
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
     - For BoosterType.StakingBalance: If the staking balance is higher than the specified amount, the boost percentage is added.
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

## TicketDeployer

_The TicketDeployer contract is responsible for deploying and managing ZizyCompetitionTicket contracts, which represent NFT tickets for competitions.
The contract inherits from the Ownable contract from OpenZeppelin to handle ownership and access control._

### tickets

```solidity
address[] tickets
```

Ticket list

### TicketDeployed

```solidity
event TicketDeployed(address ticketContract, uint256 index)
```

Emit when new ticket deployed

### constructor

```solidity
constructor(address owner_) public
```

_Constructor function_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owner_ | address | The address of the contract owner |

### deploy

```solidity
function deploy(string name_, string symbol_) external returns (uint256, address)
```

Deploy a new Ticket NFT contract

_This function allows the contract owner to deploy a new ZizyCompetitionTicket contract with the specified name and symbol.
The ownership of the deployed contract is transferred to the owner of the TicketDeployer contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the ticket contract |
| symbol_ | string | The symbol of the ticket contract |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | index The index of the deployed contract |
| [1] | address | ticketContract The address of the deployed ticket contract |

### getDeployedContractCount

```solidity
function getDeployedContractCount() external view returns (uint256)
```

Get the count of deployed ticket contracts

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The count of deployed ticket contracts |

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

### UnstakeTimeLock

```solidity
event UnstakeTimeLock(address account, uint256 lockTime)
```

Event emitted when any account unstake time locked

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Locked account |
| lockTime | uint256 | Lock time |

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

### onlyModerator

```solidity
modifier onlyModerator()
```

_Modifier that checks caller is lock moderator_

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

### setTimeLock

```solidity
function setTimeLock(address account, uint256 lockTime) external
```

Set time lock for un-stake

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Lock account |
| lockTime | uint256 | Lock timer as second |

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

### isTimeLocked

```solidity
function isTimeLocked(address account) public view returns (bool)
```

Get time lock status of any account

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Account for check status |

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

## ZizyCompetitionTicket

This contract represents the competition ticket contract, where unique tickets can be minted, transferred, and paused.

_This contract inherits from the ERC721, ERC721Enumerable, ERC721Pausable, and Ownable contracts from OpenZeppelin._

### baseUri

```solidity
string baseUri
```

_Ticket base uri [optional]_

### TicketMinted

```solidity
event TicketMinted(address ticketOwner, uint256 ticketId)
```

Emitted when a new ticket is minted.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ticketOwner | address | The address of the owner of the ticket. |
| ticketId | uint256 | The ID of the minted ticket. |

### BaseURIUpdated

```solidity
event BaseURIUpdated(uint256 timestamp)
```

_Emitted when base uri changed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| timestamp | uint256 | Block timestamp |

### constructor

```solidity
constructor(string name_, string symbol_) public
```

### setBaseURI

```solidity
function setBaseURI(string baseUri_) external virtual
```

Sets the base URI for token metadata

_This function can only be called by the contract owner.
It sets the base URI for computing the {tokenURI} of each token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseUri_ | string | The base URI string |

### pause

```solidity
function pause() external
```

Pauses token transfers.

_This function can only be called by the contract owner.
It pauses all token transfers._

### unpause

```solidity
function unpause() external
```

Unpauses token transfers.

_This function can only be called by the contract owner.
It unpauses all token transfers._

### isPaused

```solidity
function isPaused() external view returns (bool)
```

_Returns true if the contract is paused, and false otherwise._

### mint

```solidity
function mint(address to_, uint256 ticketId_) external virtual
```

Mints a new competition ticket

_This function can only be called by the contract owner.
It mints a new competition ticket to the specified address with the specified ticket ID.
It emits a `TicketMinted` event.
If the contract is paused on minting, it will temporarily unpause the contract during the minting process._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to mint the ticket to |
| ticketId_ | uint256 | The ID of the ticket to mint |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_See {IERC165-supportsInterface}._

### _baseURI

```solidity
function _baseURI() internal view virtual returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual
```

_Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
- When `from` is zero, the tokens will be minted for `to`.
- When `to` is zero, ``from``'s tokens will be burned.
- `from` and `to` are never both zero.
- `batchSize` is non-zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _afterTokenTransfer

```solidity
function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual
```

_Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
- When `from` is zero, the tokens were minted for `to`.
- When `to` is zero, ``from``'s tokens were burned.
- `from` and `to` are never both zero.
- `batchSize` is non-zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

## ZizyPoPa

This contract represents the PoPa (NFT for competitions) contract, where unique tokens can be minted, transferred, and paused.

_This contract inherits from the ERC721, ERC721Enumerable, ERC721Pausable, and Ownable contracts from OpenZeppelin._

### baseUri

```solidity
string baseUri
```

_Popa base uri [optional]_

### minterAccount

```solidity
address minterAccount
```

The address of the minter account.

### PoPaMinted

```solidity
event PoPaMinted(address to, uint256 tokenId)
```

_Emitted when a new PoPa token is minted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to which the token is minted. |
| tokenId | uint256 | The ID of the minted token. |

### BaseURIUpdated

```solidity
event BaseURIUpdated(uint256 timestamp)
```

_Emitted when base uri changed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| timestamp | uint256 | Block timestamp |

### onlyMinter

```solidity
modifier onlyMinter()
```

_Throws if the caller is not the minter account._

### constructor

```solidity
constructor(string name_, string symbol_, address minter_) public
```

Initializes the ZizyPoPa contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the NFT contract. |
| symbol_ | string | The symbol of the NFT contract. |
| minter_ | address | The address of the minter account. |

### setMinter

```solidity
function setMinter(address minter_) external
```

Sets the minter account address.

_This function can only be called by the contract owner.
It sets the minter account address to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter_ | address | The address of the minter account. |

### setBaseURI

```solidity
function setBaseURI(string baseUri_) external virtual
```

Sets the base URI for token metadata.

_This function can only be called by the contract owner.
It sets the base URI used for computing the tokenURI of each token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseUri_ | string | The base URI to be set. |

### mint

```solidity
function mint(address to_, uint256 tokenId_) external virtual
```

Mints a new PoPa NFT token.

_This function can only be called by the minter account.
It mints a new PoPa token with the specified ID and assigns it to the specified address.
Emits a `PoPaMinted` event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to which the token will be minted. |
| tokenId_ | uint256 | The ID of the token to be minted. |

### pause

```solidity
function pause() external
```

Pauses token transfers.

_This function can only be called by the contract owner.
It pauses all token transfers._

### unpause

```solidity
function unpause() external
```

Unpauses token transfers.

_This function can only be called by the contract owner.
It unpauses all token transfers._

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_See {IERC165-supportsInterface}._

### _setMinter

```solidity
function _setMinter(address minter_) internal
```

Sets the minter account address.

_It sets the minter account address to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter_ | address | The address of the minter account. |

### _baseURI

```solidity
function _baseURI() internal view virtual returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual
```

_Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
- When `from` is zero, the tokens will be minted for `to`.
- When `to` is zero, ``from``'s tokens will be burned.
- `from` and `to` are never both zero.
- `batchSize` is non-zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _afterTokenTransfer

```solidity
function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual
```

_Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
- When `from` is zero, the tokens were minted for `to`.
- When `to` is zero, ``from``'s tokens were burned.
- `from` and `to` are never both zero.
- `batchSize` is non-zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

## ZizyPoPaFactory

This contract is the factory contract for Zizy PoPa (Proof of Participation) NFTs.
It allows the deployment of PoPa NFT contracts for different periods and manages the claiming and minting of PoPa NFTs.
It also handles the allocation conditions for claiming PoPa NFTs based on participation in competitions.

_This contract is based on the OpenZeppelin Upgradeable Contracts and implements the Ownable and ReentrancyGuard modules.
It interacts with the CompetitionFactory and ZizyPoPa contracts._

### claimPayment

```solidity
uint256 claimPayment
```

PoPA Claim payment amount (PoPA mint cost for network fee)

### popaMinter

```solidity
address popaMinter
```

PoPA Minter account/contract

### competitionFactory

```solidity
address competitionFactory
```

### PopaClaimed

```solidity
event PopaClaimed(address claimer, uint256 periodId)
```

_Emitted when a PoPa NFT is claimed by an account for a specific period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| claimer | address | The account that claimed the PoPa NFT. |
| periodId | uint256 | The period ID associated with the PoPa NFT. |

### PopaMinted

```solidity
event PopaMinted(address claimer, uint256 periodId, uint256 tokenId)
```

_Emitted when a PoPa NFT is minted for an account for a specific period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| claimer | address | The account for which the PoPa NFT was minted. |
| periodId | uint256 | The period ID associated with the PoPa NFT. |
| tokenId | uint256 | The token ID of the minted PoPa NFT. |

### PopaDeployed

```solidity
event PopaDeployed(address contractAddress, uint256 periodId)
```

_Emitted when a PoPa contract is deployed for a specific period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| contractAddress | address | The address of the deployed PoPa contract. |
| periodId | uint256 | The period ID associated with the PoPa contract. |

### AllocationPercentageUpdated

```solidity
event AllocationPercentageUpdated(uint256 percentage)
```

_Emitted when the allocation percentage for PoPa claims is updated._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentage | uint256 | The new allocation percentage value. |

### PopaMinterUpdated

```solidity
event PopaMinterUpdated(address minter)
```

_Emitted when the popa minter updated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter | address | Minter account |

### PopaClaimPaymentUpdate

```solidity
event PopaClaimPaymentUpdate(uint256 amount)
```

_Emitted when the popa claim payment amount updated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | New payment amount |

### CompFactoryUpdated

```solidity
event CompFactoryUpdated(address factoryAddress)
```

_Emitted when the competition factory address updated_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| factoryAddress | address | The address of competition factory |

### onlyMinter

```solidity
modifier onlyMinter()
```

_Throws an error if the caller is not the minter._

### constructor

```solidity
constructor() public
```

_Constructor function_

### claim

```solidity
function claim(uint256 periodId_) external payable
```

Claims a PoPa NFT for the specified period ID

_This function allows users to claim a PoPa NFT for the specified period ID by sending the required claim payment.
The claim payment must be equal to or greater than the configured claim payment amount.
The period ID must be valid and the caller must not have already claimed the PoPa NFT for the specified period ID.
The caller must also meet the claim conditions as determined by the internal `_claimableCheck` function.
If the claim payment transfer to the minter fails, an error is thrown.
Sets the claim state for the caller and period ID to true.
Emits a `PopaClaimed` event with the caller's address and period ID.
Throws an error if the claim payment is insufficient, the period ID is unknown, the caller has already claimed the PoPa NFT,
or the claim conditions are not met._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId_ | uint256 | The ID of the period for which to claim the PoPa NFT |

### initialize

```solidity
function initialize(address competitionFactory_) external
```

Initializes the contract

_It sets the competitionFactory address, initializes the Ownable and ReentrancyGuard contracts,
sets the initial values for popaCounter, _popaClaimAllocationPercentage, claimPayment, and popaMinter._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| competitionFactory_ | address | The address of the CompetitionFactory contract |

### setPopaMinter

```solidity
function setPopaMinter(address minter_) external
```

Sets the minter account

_Only the owner of the contract can call this function.
It sets the popaMinter address to the specified minter_ address.
Throws an error if the minter_ address is zero._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| minter_ | address | The address of the minter account |

### setClaimPaymentAmount

```solidity
function setClaimPaymentAmount(uint256 amount_) external
```

Sets the PoPA claim payment amount

_Only the owner of the contract can call this function.
It sets the claimPayment variable to the specified amount_._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_ | uint256 | The amount of the claim payment |

### setPopaClaimAllocationPercentage

```solidity
function setPopaClaimAllocationPercentage(uint256 percentage) external
```

Sets the required allocation percentage for PoPA claim

_Only the owner of the contract can call this function.
It sets the _popaClaimAllocationPercentage variable to the specified percentage.
Emits an AllocationPercentageUpdated event with the updated percentage.
Throws an error if the percentage is not between 0 and 100._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentage | uint256 | The allocation percentage to be set |

### popaClaimed

```solidity
function popaClaimed(address account, uint256 periodId) external view returns (bool)
```

Checks if a specific PoPA has been claimed

_This function is callable by any external account.
It returns the claim status of the specified PoPA for the given account._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account to check the claim status for |
| periodId | uint256 | The period ID of the PoPA |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the PoPA has been claimed or not |

### popaMinted

```solidity
function popaMinted(address account, uint256 periodId) external view returns (bool)
```

Checks if a claimed PoPA has been minted from system

_This function is callable by any external account.
It returns the mint status of the specified PoPA for the given account._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account to check the mint status for |
| periodId | uint256 | The period ID of the PoPA |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the PoPA has been claimed or not |

### getPopaContract

```solidity
function getPopaContract(uint256 periodId) external view returns (address)
```

Gets the contract address of the PoPA NFT for a specific period ID

_This function is callable by any external account.
It returns the contract address of the PoPA NFT associated with the specified period ID._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The period ID of the PoPA |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The contract address of the PoPA NFT for the given period ID |

### getPopaContractWithIndex

```solidity
function getPopaContractWithIndex(uint256 index) external view returns (address)
```

Gets the contract address of the PoPA NFT with the specified index

_This function is callable by any external account.
It returns the contract address of the PoPA NFT at the specified index in the `_popas` array._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| index | uint256 | The index of the PoPA NFT contract |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The contract address of the PoPA NFT with the given index |

### setCompetitionFactory

```solidity
function setCompetitionFactory(address competitionFactory_) external
```

Sets the competition factory contract address

_This function can only be called by the contract owner.
It sets the competition factory contract address to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| competitionFactory_ | address | The address of the competition factory contract |

### deploy

```solidity
function deploy(string name_, string symbol_, uint256 periodId_) external returns (uint256, address)
```

Deploys a new PoPa NFT contract

_This function can only be called by the contract owner.
It deploys a new PoPa NFT contract with the specified name, symbol, and minter address.
The newly deployed PoPa contract is assigned an index in the internal array, and the period ID is mapped to its address.
The ownership of the PoPa contract is transferred to the contract owner.
Emits a `PopaDeployed` event with the contract address and period ID.
Throws an error if a PoPa contract has already been deployed for the specified period ID._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the PoPa NFT contract |
| symbol_ | string | The symbol of the PoPa NFT contract |
| periodId_ | uint256 | The ID of the period for which the PoPa NFT contract is deployed |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | index The index of the newly deployed PoPa contract in the internal array |
| [1] | address | contractAddress The address of the newly deployed PoPa contract |

### mintClaimedPopa

```solidity
function mintClaimedPopa(address claimer_, uint256 periodId_, uint256 tokenId_) external
```

Mints a claimed PoPa NFT

_This function can only be called by the minter.
It mints a PoPa NFT for the specified claimer and period ID, with the specified token ID.
The PoPa NFT must have been claimed by the claimer for the specified period ID, and it must not have been already minted.
The minted state is set to true for the claimed PoPa.
Emits a `PopaMinted` event with the claimer's address, period ID, and token ID.
Throws an error if the period ID is unknown, the PoPa NFT is not claimed by the claimer, or it has already been minted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| claimer_ | address | The address of the claimer |
| periodId_ | uint256 | The ID of the period for which the PoPa NFT is claimed |
| tokenId_ | uint256 | The ID of the PoPa NFT to mint |

### allocationPercentage

```solidity
function allocationPercentage() external view returns (uint256)
```

Gets the participation percentage condition for claiming a PoPa NFT

_This function returns the allocation percentage required for claiming a PoPa NFT.
The allocation percentage determines the minimum percentage of competitions in which the caller must have participated
in order to be eligible to claim a PoPa NFT._

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The allocation percentage required for claiming a PoPa NFT |

### claimableCheck

```solidity
function claimableCheck(address account, uint256 periodId) external view returns (bool)
```

Checks if an account is eligible to claim a PoPa NFT for a specific period

_This function checks if the specified account is eligible to claim a PoPa NFT for the given period.
The account must meet the following conditions:
1. The account has not already claimed a PoPa NFT for the period.
2. The account has participated in all competitions of the period, according to the allocation settings.
3. If the allocation percentage condition is non-zero, the account must have bought enough tickets
   in each competition to meet the allocation percentage requirement._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address to check |
| periodId | uint256 | The ID of the period to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the account is eligible to claim a PoPa NFT |

### getDeployedContractCount

```solidity
function getDeployedContractCount() external view returns (uint256)
```

Get the count of deployed PoPa NFT contracts

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The number of deployed PoPa NFT contracts |

### _setPopaClaimAllocationPercentage

```solidity
function _setPopaClaimAllocationPercentage(uint256 percentage) internal
```

Internal function to set the PoPA claim allocation percentage

_It sets the _popaClaimAllocationPercentage variable to the specified percentage.
Emits an AllocationPercentageUpdated event with the updated percentage.
Throws an error if the percentage is not between 0 and 100._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentage | uint256 | The allocation percentage to be set |

### _setCompetitionFactory

```solidity
function _setCompetitionFactory(address competitionFactory_) internal
```

Sets the competition factory contract address

_It sets the competition factory contract address to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| competitionFactory_ | address | The address of the competition factory contract |

### _claimableCheck

```solidity
function _claimableCheck(address account, uint256 periodId) internal view returns (bool)
```

Checks if an account is eligible to claim a PoPa NFT for a specific period

_This internal function checks if the specified account is eligible to claim a PoPa NFT for the given period.
The account must meet the conditions described in the @notice of the `claimableCheck` function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The account address to check |
| periodId | uint256 | The ID of the period to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A boolean indicating whether the account is eligible to claim a PoPa NFT |

## ZizyRewardsHub

This contract is used to manage and distribute rewards for the ZIZY platform.

_It inherits functionalities from OpenZeppelin's Ownable, ReentrancyGuard and ERC721Holder contracts._

### RewardType

```solidity
enum RewardType {
  Token,
  NFT,
  Native
}
```

### CompRewardSource

```solidity
struct CompRewardSource {
  uint256 periodId;
  uint256 competitionId;
}
```

### Reward

```solidity
struct Reward {
  uint256 chainId;
  enum ZizyRewardsHub.RewardType rewardType;
  address rewardAddress;
  uint256 amount;
  uint256 tokenId;
  bool isClaimed;
  bool _exist;
}
```

### rewardDefiner

```solidity
address rewardDefiner
```

Address of the reward definer.

### CompRewardDefined

```solidity
event CompRewardDefined(address ticket, uint256 ticketId)
```

Event emitted when a competition reward is defined.

### CompRewardUpdated

```solidity
event CompRewardUpdated(address ticket, uint256 ticketId)
```

Event emitted when a competition reward is updated.

### AirdropRewardDefined

```solidity
event AirdropRewardDefined(address receiver, uint256 rewardIndex, uint256 airdropId)
```

Event emitted when an airdrop reward is defined.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | The address of the receiver of the airdrop. |
| rewardIndex | uint256 | The index of the reward in the airdrop. |
| airdropId | uint256 | The ID of the airdrop. |

### AirdropRewardUpdated

```solidity
event AirdropRewardUpdated(address receiver, uint256 rewardIndex, uint256 airdropId)
```

Event emitted when an airdrop reward is updated.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver | address | The address of the receiver of the airdrop. |
| rewardIndex | uint256 | The index of the reward in the airdrop. |
| airdropId | uint256 | The ID of the airdrop. |

### AirdropRewardClaimed

```solidity
event AirdropRewardClaimed(uint256 airdropId, uint256 rewardIndex, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress, address receiver, uint256 amount, uint256 tokenId)
```

Event emitted when an airdrop reward is claimed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| airdropId | uint256 | The ID of the airdrop. |
| rewardIndex | uint256 | The index of the reward in the airdrop. |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward (Token, NFT, Native). |
| rewardAddress | address | The address of the reward token or NFT contract. |
| receiver | address | The address of the receiver of the reward. |
| amount | uint256 |  |
| tokenId | uint256 |  |

### AirdropRewardClaimedOnDiffChain

```solidity
event AirdropRewardClaimedOnDiffChain(uint256 airdropId, uint256 rewardIndex, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress, address receiver, uint256 chainId, uint256 amount, uint256 tokenId)
```

Event emitted when an airdrop reward is claimed on a different chain.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| airdropId | uint256 | The ID of the airdrop. |
| rewardIndex | uint256 | The index of the reward in the airdrop. |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward (Token, NFT, Native). |
| rewardAddress | address | The address of the reward token or NFT contract. |
| receiver | address | The address of the receiver of the reward. |
| chainId | uint256 | The ID of the chain where the reward is claimed. |
| amount | uint256 |  |
| tokenId | uint256 |  |

### CompRewardClaimed

```solidity
event CompRewardClaimed(uint256 periodId, uint256 competitionId, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress, address receiver, uint256 amount, uint256 tokenId)
```

Event emitted when a competition reward is claimed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the competition period. |
| competitionId | uint256 | The ID of the competition. |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward (Token, NFT, Native). |
| rewardAddress | address | The address of the reward token or NFT contract. |
| receiver | address | The address of the receiver of the reward. |
| amount | uint256 | Amount of rewards (Token, Native) |
| tokenId | uint256 | ID of reward (NFT) |

### CompRewardClaimedOnDiffChain

```solidity
event CompRewardClaimedOnDiffChain(uint256 periodId, uint256 competitionId, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress, address receiver, uint256 chainId, uint256 amount, uint256 tokenId)
```

Event emitted when a competition reward is claimed on a different chain.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The ID of the competition period. |
| competitionId | uint256 | The ID of the competition. |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward (Token, NFT, Native). |
| rewardAddress | address | The address of the reward token or NFT contract. |
| receiver | address | The address of the receiver of the reward. |
| chainId | uint256 | The ID of the chain where the reward is claimed. |
| amount | uint256 | Amount of rewards (Token, Native) |
| tokenId | uint256 | ID of reward (NFT) |

### RewardWithdraw

```solidity
event RewardWithdraw(enum ZizyRewardsHub.RewardType withdrawType, address assetAddress, uint256 amount, uint256 tokenId)
```

Event emitted when a competition reward is claimed on a different chain.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| withdrawType | enum ZizyRewardsHub.RewardType | The type of the reward (Token, NFT, Native). |
| assetAddress | address | The contract address of withdrawed asset (Token, NFT) |
| amount | uint256 | Withdraw amount (Token, Native) |
| tokenId | uint256 | ID of reward (NFT) |

### SetRewardDefiner

```solidity
event SetRewardDefiner(address account)
```

Event emitted when reward definer updated

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Reward definer address |

### onlyRewardDefiner

```solidity
modifier onlyRewardDefiner()
```

### constructor

```solidity
constructor() public
```

_Constructor function_

### initialize

```solidity
function initialize(address rewardDefiner_) external
```

Initializes the smart contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardDefiner_ | address | The address of the reward definer. |

### setRewardDefiner

```solidity
function setRewardDefiner(address rewardDefiner_) external
```

Sets the reward definer address

_Note that the function checks if the caller is the contract owner. Only the contract owner is allowed to set the reward definer address.
After confirming the ownership, the function calls the internal `_setRewardDefiner` function to set the reward definer address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardDefiner_ | address | The address of the reward definer |

### setCompetitionReward

```solidity
function setCompetitionReward(uint256 periodId, uint256 competitionId, address ticket_, uint256 ticketId_, uint256 chainId_, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress_, uint256 amount, uint256 tokenId) external
```

Sets a single competition reward

_Note that the function can only be called by the reward definer address.
The function simply calls the internal `_setCompetitionReward` function to set the competition reward with the specified values._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The period ID |
| competitionId | uint256 | The competition ID |
| ticket_ | address | The address of the winner ticket NFT |
| ticketId_ | uint256 | The ID of the winner ticket |
| chainId_ | uint256 | The chain ID |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward |
| rewardAddress_ | address | The address of the reward |
| amount | uint256 | The amount of the reward |
| tokenId | uint256 | The ID of the token |

### setCompetitionNativeRewardBatch

```solidity
function setCompetitionNativeRewardBatch(uint256 periodId, uint256 competitionId, address ticket_, uint256 chainId_, uint256[] ticketIds_, uint256[] amounts_) external
```

Sets a multiple competition rewards as `Native` coin

_The function allows the reward definer to set multiple competition rewards with Native coin rewards.
The length of the `ticketIds_` and `amounts_` arrays must match.
Each reward is set by calling the internal `_setCompetitionReward` function with the specified values and `RewardType.Native`.
Note that `rewardAddress_` is set to address(0) for Native coin rewards._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The period ID |
| competitionId | uint256 | The competition ID |
| ticket_ | address | The address of the winner ticket NFT |
| chainId_ | uint256 | The chain ID |
| ticketIds_ | uint256[] |  |
| amounts_ | uint256[] |  |

### setCompetitionTokenRewardBatch

```solidity
function setCompetitionTokenRewardBatch(uint256 periodId, uint256 competitionId, address ticket_, uint256 chainId_, address rewardAddress_, uint256[] ticketIds_, uint256[] amounts_) external
```

Sets a multiple competition rewards as `ERC20-Token`

_The function allows the reward definer to set multiple competition rewards with ERC20-Token rewards.
The length of the `ticketIds_` and `amounts_` arrays must match.
Each reward is set by calling the internal `_setCompetitionReward` function with the specified values and `RewardType.Token`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The period ID |
| competitionId | uint256 | The competition ID |
| ticket_ | address | The address of the winner ticket NFT |
| chainId_ | uint256 | The chain ID |
| rewardAddress_ | address | The address of the reward ERC20-Token |
| ticketIds_ | uint256[] |  |
| amounts_ | uint256[] |  |

### setAirdropReward

```solidity
function setAirdropReward(address receiver_, uint256 airdropId_, uint256 chainId_, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress_, uint256 amount, uint256 tokenId) external
```

Sets a single airdrop without ticket

_The function allows the reward definer to set a single airdrop reward without requiring a ticket.
The reward is defined by calling the internal `_setAirdropReward` function with the specified values.
The function emits the `AirdropRewardDefined` event and adds the reward to the `_airdropRewards` mapping._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | Receiver address to reward |
| airdropId_ | uint256 | Competition or Airdrop ID |
| chainId_ | uint256 | The reward chain ID |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward |
| rewardAddress_ | address | The address of the reward |
| amount | uint256 | The amount of the reward |
| tokenId | uint256 | The ID of the token |

### setAirdropNativeRewardBatch

```solidity
function setAirdropNativeRewardBatch(uint256 airdropId_, uint256 chainId_, address[] receivers_, uint256[] amounts_) external
```

Sets a multiple airdrop rewards as `Native` coin

_The function allows the reward definer to set multiple airdrop rewards with Native coin.
It takes the airdrop ID, chain ID, an array of receiver addresses, and an array of reward amounts as parameters.
The function calls the internal `_setAirdropReward` function for each receiver to set the reward.
The reward type is set as `Native`, and the reward address is set to 0 (native coin).
The function emits the `AirdropRewardDefined` event for each reward added to the `_airdropRewards` mapping._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| airdropId_ | uint256 | Competition or Airdrop ID |
| chainId_ | uint256 | The reward chain ID |
| receivers_ | address[] |  |
| amounts_ | uint256[] |  |

### setAirdropTokenRewardBatch

```solidity
function setAirdropTokenRewardBatch(uint256 airdropId_, address rewardAddress_, uint256 chainId_, address[] receivers_, uint256[] amounts_) external
```

Sets a multiple airdrop rewards as `ERC20-Token`

_The function allows the reward definer to set multiple airdrop rewards with ERC20 tokens.
It takes the airdrop ID, reward address (ERC20 token address), chain ID, an array of receiver addresses,
and an array of reward amounts as parameters.
The function calls the internal `_setAirdropReward` function for each receiver to set the reward.
The reward type is set as `Token`, and the reward address is set to the provided ERC20 token address.
The function emits the `AirdropRewardDefined` event for each reward added to the `_airdropRewards` mapping._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| airdropId_ | uint256 | Competition or Airdrop ID |
| rewardAddress_ | address | The address of the reward ERC20-Token |
| chainId_ | uint256 | The reward chain ID |
| receivers_ | address[] |  |
| amounts_ | uint256[] |  |

### claimCompetitionReward

```solidity
function claimCompetitionReward(address ticketContract_, uint256 ticketId_) external
```

Claims the competition reward

_This function allows to claim a reward for a competition. It first fetches the reward associated with the
provided ticketContract_ and ticketId_ from the _competitionRewards mapping. It ensures that the reward exists
and has not already been claimed.

Next, it checks the owner of the NFT ticket. The owner must be the sender of this transaction.

The function then marks the reward as claimed to prevent double claiming.

Depending on the chain ID of the reward, it either emits an event that the reward has been claimed on a
different chain or it executes a transfer of the reward. In case of a transfer, it checks the reward type
and executes either an ERC20 token transfer, an ERC721 NFT transfer, or a native coin transfer. In the end,
it emits an event that the reward has been claimed._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ticketContract_ | address | The address of the ticket NFT contract |
| ticketId_ | uint256 | The ID of the winning ticket |

### getCompetitionReward

```solidity
function getCompetitionReward(address ticketContract_, uint256 ticketId_) external view returns (struct ZizyRewardsHub.Reward)
```

Fetches the competition reward associated with the given ticket contract and ticket ID

_This function fetches the competition reward for the given ticket contract and ticket ID from the
_competitionRewards mapping and returns it._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| ticketContract_ | address | The address of the ticket NFT contract |
| ticketId_ | uint256 | The ID of the ticket |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ZizyRewardsHub.Reward | Returns the Reward structure associated with the ticket contract and ticket ID |

### getUnClaimedAirdropRewardCount

```solidity
function getUnClaimedAirdropRewardCount(address receiver_, uint256 airdropId_) external view returns (uint256)
```

Fetches the count of unclaimed airdrop rewards associated with the given receiver and airdrop ID

_This function fetches the total count of airdrop rewards for the given receiver and airdrop ID
from the _airdropRewards mapping and then counts the number of those rewards that are unclaimed._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address of the receiver |
| airdropId_ | uint256 | The ID of the airdrop |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Count of unclaimed rewards as uint |

### getAirdropReward

```solidity
function getAirdropReward(address receiver_, uint256 airdropId_, uint256 rewardIndex) external view returns (struct ZizyRewardsHub.Reward)
```

Retrieves a specific airdrop reward

_This external function allows anyone to retrieve the details of a specific reward associated
with an airdrop for a specific receiver. It checks if the rewardIndex is within the boundaries
of the array of rewards for the airdrop before returning the reward._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address of the receiver of the airdrop |
| airdropId_ | uint256 | The ID of the airdrop |
| rewardIndex | uint256 | The index of the reward in the list of rewards associated with the airdrop |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct ZizyRewardsHub.Reward | The reward structure associated with the specified index within the airdrop |

### removeAirdropReward

```solidity
function removeAirdropReward(address receiver_, uint256 airdropId_, uint256 rewardIndex) external
```

Removes a specific airdrop reward. Used for handling exceptions

_This function can only be executed by the reward definer. It allows for removing a specific
reward associated with an airdrop for a specific receiver. It checks if the rewardIndex is
within the boundaries of the array of rewards for the airdrop, verifies the reward exists
and is unclaimed, and then replaces it with the last reward in the array before reducing
the array's length by one. A corresponding event is then emitted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address of the receiver of the airdrop |
| airdropId_ | uint256 | The ID of the airdrop |
| rewardIndex | uint256 | The index of the reward in the list of rewards associated with the airdrop |

### claimAllAirdropRewards

```solidity
function claimAllAirdropRewards(uint256 airdropId_) external
```

Allows the caller to claim all unclaimed airdrop rewards associated with a specific airdrop ID

_This function enables a user to claim all unclaimed rewards from a specific airdrop.
It iterates over all rewards associated with the caller's address and the provided
airdrop ID, and calls the internal `_claimAirdropReward` function for each unclaimed reward._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| airdropId_ | uint256 | The ID of the airdrop for which to claim rewards |

### claimAirdropReward

```solidity
function claimAirdropReward(uint256 airdropId_, uint256 rewardIndex) external
```

Allows a user to claim a specific airdrop reward

_This external function enables a caller to claim a specific reward from an airdrop.
It simply invokes the internal _claimAirdropReward function with the caller's address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| airdropId_ | uint256 | The ID of the airdrop that includes the reward |
| rewardIndex | uint256 | The index of the reward in the list of rewards associated with the airdrop |

### chainId

```solidity
function chainId() public view returns (uint256)
```

This function returns the chainId of the current blockchain.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The chainId of the blockchain where the contract is currently deployed. |

### getAirdropRewardCount

```solidity
function getAirdropRewardCount(address receiver_, uint256 airdropId_) public view returns (uint256)
```

Fetches the count of airdrop rewards associated with the given receiver and airdrop ID

_This function fetches the count of airdrop rewards for the given receiver and airdrop ID from the
_airdropRewards mapping and returns it._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address of the receiver |
| airdropId_ | uint256 | The ID of the airdrop |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Airdrop reward count as uint |

### _setRewardDefiner

```solidity
function _setRewardDefiner(address rewardDefiner_) internal
```

Internal function to set the reward definer address

_Note that the function checks if the reward definer address is not zero. The reward definer address must be a valid address.
After validating the address, the function sets the `rewardDefiner` variable to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| rewardDefiner_ | address | The address of the reward definer |

### _setCompetitionReward

```solidity
function _setCompetitionReward(uint256 periodId, uint256 competitionId, address ticket_, uint256 ticketId_, uint256 chainId_, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress_, uint256 amount, uint256 tokenId) internal
```

Sets a single competition reward

_Note that the function checks if the reward is already claimed. If the reward is claimed, it cannot be updated.
The function also checks if the reward type is Token or NFT, in which case the reward address must not be zero.
If the reward already exists, the function emits a `CompRewardUpdated` event. Otherwise, it emits a `CompRewardDefined` event.
The function updates the competition reward mapping and the competition reward source mapping with the specified values._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| periodId | uint256 | The period ID |
| competitionId | uint256 | The competition ID |
| ticket_ | address | The address of the winner ticket NFT |
| ticketId_ | uint256 | The ID of the winner ticket |
| chainId_ | uint256 | The chain ID |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward |
| rewardAddress_ | address | The address of the reward |
| amount | uint256 | The amount of the reward |
| tokenId | uint256 | The ID of the token |

### _setAirdropReward

```solidity
function _setAirdropReward(address receiver_, uint256 airdropId_, uint256 chainId_, enum ZizyRewardsHub.RewardType rewardType, address rewardAddress_, uint256 amount, uint256 tokenId) internal
```

Sets a single airdrop without ticket

_The function allows the reward definer to set a single airdrop reward without requiring a ticket.
The reward is defined by calling the internal `_setAirdropReward` function with the specified values.
The function emits the `AirdropRewardDefined` event and adds the reward to the `_airdropRewards` mapping._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | Receiver address to reward |
| airdropId_ | uint256 | Competition or Airdrop ID |
| chainId_ | uint256 | The reward chain ID |
| rewardType | enum ZizyRewardsHub.RewardType | The type of the reward |
| rewardAddress_ | address | The address of the reward |
| amount | uint256 | The amount of the reward |
| tokenId | uint256 | The ID of the token |

### _claimAirdropReward

```solidity
function _claimAirdropReward(address receiver_, uint256 airdropId_, uint256 rewardIndex) internal
```

This internal function allows a specific airdrop reward to be claimed

_This function enables a specific reward from an airdrop to be claimed. It requires that the
reward exists and has not yet been claimed. Once the reward is claimed, depending on its type
and whether it's in the current chain, the function emits an event and transfers the reward._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| receiver_ | address | The address of the receiver who claims the reward |
| airdropId_ | uint256 | The ID of the airdrop that includes the reward |
| rewardIndex | uint256 | The index of the reward in the list of rewards associated with the airdrop |

## ExploreRewards

### constructor

```solidity
constructor() public
```

## DepositWithdrawTest

Useless on production. Just test purpose

_Initializes the contract_

### constructor

```solidity
constructor() public
```

_Constructor function_

### initialize

```solidity
function initialize() external
```

Initializes the DepositWithdrawTest contract.

_This function is used to initialize the DepositWithdrawTest contract_

### __DepositWithdraw_init_Test

```solidity
function __DepositWithdraw_init_Test() external
```

Test method for coverage

### __DepositWithdraw_init_unchained_Test

```solidity
function __DepositWithdraw_init_unchained_Test() external
```

Test method for coverage

## ZizyERC20

### DECIMALS

```solidity
uint8 DECIMALS
```

### constructor

```solidity
constructor(string name_, string symbol_) public
```

### decimals

```solidity
function decimals() public view virtual returns (uint8)
```

_Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).

Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value {ERC20} uses, unless this function is
overridden;

NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}._

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual
```

_Hook that is called before any transfer of tokens. This includes
minting and burning.

Calling conditions:

- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
will be transferred to `to`.
- when `from` is zero, `amount` tokens will be minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens will be burned.
- `from` and `to` are never both zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

## DepositWithdraw

_Initializes the contract setting the deployer as the initial owner._

### AssetType

```solidity
enum AssetType {
  Native,
  ERC20,
  ERC721
}
```

### Deposit

```solidity
event Deposit(address account, uint256 amount)
```

Emit when native coin deposit on this contract

### Withdraw

```solidity
event Withdraw(enum DepositWithdraw.AssetType assetType, address assetAddress, uint256 amount, uint256 tokenId)
```

Event emitted when withdraw any asset from this contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| assetType | enum DepositWithdraw.AssetType | The type of the asset (ERC20, ERC721, Native). |
| assetAddress | address | The contract address of withdrawed asset (ERC20, ERC721) |
| amount | uint256 | Withdraw amount (ERC20, Native) |
| tokenId | uint256 | ID of the ERC721 asset (ERC721) |

### deposit

```solidity
function deposit() external payable
```

Allows deposit native coin on the contract

### withdraw

```solidity
function withdraw(uint256 amount) external
```

This function allows the contract owner to withdraw native coins (Ether in case of Ethereum) from the contract.

_Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw native coins.
After confirming the ownership, the function uses the internal `_sendNativeCoin` function to send the native coins to the owner's address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The amount of native coins to withdraw. This value is in the smallest denomination (Wei in case of Ethereum). |

### withdrawTo

```solidity
function withdrawTo(address payable to_, uint256 amount) external
```

This function allows the contract owner to withdraw native coins (Ether in case of Ethereum) from the contract and send them to a specific address.

_Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw native coins.
After confirming the ownership, the function uses the internal `_sendNativeCoin` function to send the native coins to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address payable | The address to send the native coins to. The address must be payable, as they are receiving native coins. |
| amount | uint256 | The amount of native coins to send. This value is in the smallest denomination (Wei in case of Ethereum). |

### withdrawToken

```solidity
function withdrawToken(address token_, uint256 amount) external
```

This function allows the contract owner to withdraw ERC20 tokens from the contract.

_Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw tokens.
After confirming the ownership, the function uses the internal `_sendToken` function to send the tokens to the owner's address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token_ | address | The address of the token to withdraw. |
| amount | uint256 | The amount of tokens to withdraw. |

### withdrawTokenTo

```solidity
function withdrawTokenTo(address to_, address token_, uint256 amount) external
```

This function allows the contract owner to withdraw ERC20 tokens from the contract and send them to a specific address.

_Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw tokens.
After confirming the ownership, the function uses the internal `_sendToken` function to send the tokens to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to send the ERC20 tokens to. The address must be valid and capable of receiving ERC20 tokens. |
| token_ | address | The address of the ERC20 token to send. |
| amount | uint256 | The amount of ERC20 tokens to send. |

### withdrawNFT

```solidity
function withdrawNFT(address token_, uint256 tokenId_) external
```

This function allows the contract owner to withdraw NFTs from the contract.

_Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw NFTs.
After confirming the ownership, the function uses the internal `_sendNFT` function to send the NFT to the owner's address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token_ | address | The address of the NFT contract. |
| tokenId_ | uint256 | The ID of the NFT to withdraw. |

### withdrawNFTTo

```solidity
function withdrawNFTTo(address to_, address token_, uint256 tokenId_) external
```

This function allows the contract owner to withdraw NFTs from the contract and send them to a specific address.

_Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw NFTs.
After confirming the ownership, the function uses the internal `_sendNFT` function to send the NFT to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to send the NFT to. The address must be valid and capable of receiving NFTs. |
| token_ | address | The address of the NFT contract. |
| tokenId_ | uint256 | The ID of the NFT to send. |

### __DepositWithdraw_init

```solidity
function __DepositWithdraw_init() internal
```

_Initializes the contract_

### __DepositWithdraw_init_unchained

```solidity
function __DepositWithdraw_init_unchained() internal
```

### _sendNativeCoin

```solidity
function _sendNativeCoin(address payable to_, uint256 amount) internal
```

This internal function handles the transfer of native coins (Ether in case of Ethereum).

_Note that the function checks if the contract has sufficient balance to send the requested amount.
If there are not enough native coins in the contract, the transaction will fail with an error message.
After confirming there are enough native coins, the function uses a low-level `call` to transfer them._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address payable | The recipient's address. The recipient must be payable, as they are receiving native coins. |
| amount | uint256 | The amount of native coins to be transferred. This value is in the smallest denomination (Wei in case of Ethereum). |

### _sendToken

```solidity
function _sendToken(address to_, address token_, uint256 amount) internal
```

Internal function to send ERC20 tokens

_Note that the function checks if the contract has sufficient balance of the specified ERC20 token to send the requested amount.
If there are not enough tokens in the contract, the transaction will fail with an error message.
After confirming there are enough tokens, the function uses the `safeTransfer` function of the ERC20 token contract to transfer the tokens to the recipient._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address of the recipient of the ERC20 token transfer. The recipient must be a valid address. |
| token_ | address | The address of the ERC20 token to send. |
| amount | uint256 | The amount of ERC20 tokens to send. |

### _sendNFT

```solidity
function _sendNFT(address to_, address token_, uint256 tokenId_) internal
```

Internal function to send NFTs

_Note that the function checks if the contract is the owner of the specified NFT. Only if the contract owns the NFT, it can be transferred.
After confirming the ownership, the function uses the `safeTransferFrom` function of the NFT contract to transfer the NFT to the specified address._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to_ | address | The address to send the NFT to. The address must be a valid address capable of receiving NFTs. |
| token_ | address | The address of the NFT contract. |
| tokenId_ | uint256 | The ID of the NFT to send. |

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

