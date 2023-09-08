# Solidity API

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

