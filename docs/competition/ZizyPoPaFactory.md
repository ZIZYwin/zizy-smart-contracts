# Solidity API

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

