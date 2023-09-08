# Solidity API

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

