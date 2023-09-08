# Solidity API

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

