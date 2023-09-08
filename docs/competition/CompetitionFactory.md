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

