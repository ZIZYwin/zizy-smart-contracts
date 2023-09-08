# Solidity API

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

