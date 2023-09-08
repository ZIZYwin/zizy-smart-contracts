# Solidity API

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

