# Solidity API

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

