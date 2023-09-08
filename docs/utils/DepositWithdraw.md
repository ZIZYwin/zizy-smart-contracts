# Solidity API

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

