# Solidity API

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

