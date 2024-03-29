// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "./../utils/DepositWithdraw.sol";

/**
 * @title Zizy Rewards Hub
 * @notice This contract is used to manage and distribute rewards for the ZIZY platform.
 *
 * @dev It inherits functionalities from OpenZeppelin's Ownable, ReentrancyGuard and ERC721Holder contracts.
 */
contract ZizyRewardsHub is DepositWithdraw {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @notice Enum for reward types
    enum RewardType {
        Token,
        NFT,
        Native
    }

    /// @notice Struct for competition reward source
    struct CompRewardSource {
        uint256 periodId;
        uint256 competitionId;
    }

    /// @notice Struct for rewards.
    struct Reward {
        uint chainId;
        RewardType rewardType;
        address rewardAddress;
        uint amount; // Only for ERC-20 and Native coin rewards
        uint tokenId; // Only for NFT rewards
        bool isClaimed;
        bool _exist;
    }

    /// @notice Address of the reward definer.
    address public rewardDefiner;

    // @dev Mapping for competition rewards: [TicketNFTAddress > TokenID > Reward]
    mapping(address => mapping(uint256 => Reward)) private _competitionRewards;

    // @dev Mapping for competition reward sources: [TicketNFTAddress > TokenID > CompRewardSource]
    mapping(address => mapping(uint256 => CompRewardSource)) private _compRewardSource;

    // @dev Mapping for airdrop rewards: [Account > AirdropID > Reward[]]
    mapping(address => mapping(uint256 => Reward[])) private _airdropRewards;

    /// @notice Event emitted when a competition reward is defined.
    event CompRewardDefined(address indexed ticket, uint256 ticketId);

    /// @notice Event emitted when a competition reward is updated.
    event CompRewardUpdated(address indexed ticket, uint256 ticketId);

    /**
     * @notice Event emitted when an airdrop reward is defined.
     * @param receiver The address of the receiver of the airdrop.
     * @param rewardIndex The index of the reward in the airdrop.
     * @param airdropId The ID of the airdrop.
     */
    event AirdropRewardDefined(address indexed receiver, uint rewardIndex, uint256 airdropId);

    /**
     * @notice Event emitted when an airdrop reward is updated.
     * @param receiver The address of the receiver of the airdrop.
     * @param rewardIndex The index of the reward in the airdrop.
     * @param airdropId The ID of the airdrop.
     */
    event AirdropRewardUpdated(address indexed receiver, uint rewardIndex, uint256 airdropId);

    /**
     * @notice Event emitted when an airdrop reward is claimed.
     * @param airdropId The ID of the airdrop.
     * @param rewardIndex The index of the reward in the airdrop.
     * @param rewardType The type of the reward (Token, NFT, Native).
     * @param rewardAddress The address of the reward token or NFT contract.
     * @param receiver The address of the receiver of the reward.
     */
    event AirdropRewardClaimed(uint256 indexed airdropId, uint rewardIndex, RewardType rewardType, address rewardAddress, address receiver, uint amount, uint tokenId);

    /**
     * @notice Event emitted when an airdrop reward is claimed on a different chain.
     * @param airdropId The ID of the airdrop.
     * @param rewardIndex The index of the reward in the airdrop.
     * @param rewardType The type of the reward (Token, NFT, Native).
     * @param rewardAddress The address of the reward token or NFT contract.
     * @param receiver The address of the receiver of the reward.
     * @param chainId The ID of the chain where the reward is claimed.
     */
    event AirdropRewardClaimedOnDiffChain(uint256 indexed airdropId, uint rewardIndex, RewardType rewardType, address rewardAddress, address receiver, uint chainId, uint amount, uint tokenId);

    /**
     * @notice Event emitted when a competition reward is claimed.
     * @param periodId The ID of the competition period.
     * @param competitionId The ID of the competition.
     * @param rewardType The type of the reward (Token, NFT, Native).
     * @param rewardAddress The address of the reward token or NFT contract.
     * @param receiver The address of the receiver of the reward.
     * @param amount Amount of rewards (Token, Native)
     * @param tokenId ID of reward (NFT)
     */
    event CompRewardClaimed(uint256 periodId, uint256 competitionId, RewardType rewardType, address rewardAddress, address receiver, uint amount, uint tokenId);

    /**
     * @notice Event emitted when a competition reward is claimed on a different chain.
     * @param periodId The ID of the competition period.
     * @param competitionId The ID of the competition.
     * @param rewardType The type of the reward (Token, NFT, Native).
     * @param rewardAddress The address of the reward token or NFT contract.
     * @param receiver The address of the receiver of the reward.
     * @param chainId The ID of the chain where the reward is claimed.
     * @param amount Amount of rewards (Token, Native)
     * @param tokenId ID of reward (NFT)
     */
    event CompRewardClaimedOnDiffChain(uint256 periodId, uint256 competitionId, RewardType rewardType, address rewardAddress, address receiver, uint chainId, uint amount, uint tokenId);

    /**
     * @notice Event emitted when a competition reward is claimed on a different chain.
     * @param withdrawType The type of the reward (Token, NFT, Native).
     * @param assetAddress The contract address of withdrawed asset (Token, NFT)
     * @param amount Withdraw amount (Token, Native)
     * @param tokenId ID of reward (NFT)
     */
    event RewardWithdraw(RewardType withdrawType, address assetAddress, uint amount, uint tokenId);

    /**
     * @notice Event emitted when reward definer updated
     * @param account Reward definer address
     */
    event SetRewardDefiner(address account);

    // @dev Modifier to restrict function calls only to the reward definer address
    modifier onlyRewardDefiner() {
        require(_msgSender() == rewardDefiner, "Only call from reward definer !");
        _;
    }

    /**
     * @dev Constructor function
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the smart contract
     * @param rewardDefiner_ The address of the reward definer.
     */
    function initialize(address rewardDefiner_) external initializer {
        __DepositWithdraw_init();
        _setRewardDefiner(rewardDefiner_);
    }

    /**
     * @notice Sets the reward definer address
     * @param rewardDefiner_ The address of the reward definer
     *
     * @dev Note that the function checks if the caller is the contract owner. Only the contract owner is allowed to set the reward definer address.
     * After confirming the ownership, the function calls the internal `_setRewardDefiner` function to set the reward definer address.
     */
    function setRewardDefiner(address rewardDefiner_) external onlyOwner {
        _setRewardDefiner(rewardDefiner_);
    }

    /**
     * @notice Sets a single competition reward
     * @param periodId The period ID
     * @param competitionId The competition ID
     * @param ticket_ The address of the winner ticket NFT
     * @param ticketId_ The ID of the winner ticket
     * @param chainId_ The chain ID
     * @param rewardType The type of the reward
     * @param rewardAddress_ The address of the reward
     * @param amount The amount of the reward
     * @param tokenId The ID of the token
     *
     * @dev Note that the function can only be called by the reward definer address.
     * The function simply calls the internal `_setCompetitionReward` function to set the competition reward with the specified values.
     *
     */
    function setCompetitionReward(uint256 periodId, uint256 competitionId, address ticket_, uint256 ticketId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) external onlyRewardDefiner {
        _setCompetitionReward(periodId, competitionId, ticket_, ticketId_, chainId_, rewardType, rewardAddress_, amount, tokenId);
    }

    /**
     * @notice Sets a multiple competition rewards as `Native` coin
     * @param periodId The period ID
     * @param competitionId The competition ID
     * @param ticket_ The address of the winner ticket NFT
     * @param chainId_ The chain ID
     * @param ticketIds_[] The ID list of the winner tickets
     * @param amounts_[] The amount list of the native coin rewards
     *
     * @dev The function allows the reward definer to set multiple competition rewards with Native coin rewards.
     * The length of the `ticketIds_` and `amounts_` arrays must match.
     * Each reward is set by calling the internal `_setCompetitionReward` function with the specified values and `RewardType.Native`.
     * Note that `rewardAddress_` is set to address(0) for Native coin rewards.
     *
     */
    function setCompetitionNativeRewardBatch(uint256 periodId, uint256 competitionId, address ticket_, uint chainId_, uint[] calldata ticketIds_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = ticketIds_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setCompetitionReward(periodId, competitionId, ticket_, ticketIds_[i], chainId_, RewardType.Native, address(0), amounts_[i], 0);
        }
    }

    /**
     * @notice Sets a multiple competition rewards as `ERC20-Token`
     * @param periodId The period ID
     * @param competitionId The competition ID
     * @param ticket_ The address of the winner ticket NFT
     * @param chainId_ The chain ID
     * @param rewardAddress_ The address of the reward ERC20-Token
     * @param ticketIds_[] The ID list of the winner tickets
     * @param amounts_[] The amount list of the ERC20-Token rewards
     *
     * @dev The function allows the reward definer to set multiple competition rewards with ERC20-Token rewards.
     * The length of the `ticketIds_` and `amounts_` arrays must match.
     * Each reward is set by calling the internal `_setCompetitionReward` function with the specified values and `RewardType.Token`.
     *
     */
    function setCompetitionTokenRewardBatch(uint256 periodId, uint256 competitionId, address ticket_, uint chainId_, address rewardAddress_, uint[] calldata ticketIds_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = ticketIds_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setCompetitionReward(periodId, competitionId, ticket_, ticketIds_[i], chainId_, RewardType.Token, rewardAddress_, amounts_[i], 0);
        }
    }

    /**
     * @notice Sets a single airdrop without ticket
     * @param receiver_ Receiver address to reward
     * @param airdropId_ Competition or Airdrop ID
     * @param chainId_ The reward chain ID
     * @param rewardType The type of the reward
     * @param rewardAddress_ The address of the reward
     * @param amount The amount of the reward
     * @param tokenId The ID of the token
     *
     * @dev The function allows the reward definer to set a single airdrop reward without requiring a ticket.
     * The reward is defined by calling the internal `_setAirdropReward` function with the specified values.
     * The function emits the `AirdropRewardDefined` event and adds the reward to the `_airdropRewards` mapping.
     *
     */
    function setAirdropReward(address receiver_, uint airdropId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) external onlyRewardDefiner {
        _setAirdropReward(receiver_, airdropId_, chainId_, rewardType, rewardAddress_, amount, tokenId);
    }

    /**
     * @notice Sets a multiple airdrop rewards as `Native` coin
     * @param airdropId_ Competition or Airdrop ID
     * @param chainId_ The reward chain ID
     * @param receivers_[] Receiver address list to reward
     * @param amounts_[] The amount list of the reward
     *
     * @dev The function allows the reward definer to set multiple airdrop rewards with Native coin.
     * It takes the airdrop ID, chain ID, an array of receiver addresses, and an array of reward amounts as parameters.
     * The function calls the internal `_setAirdropReward` function for each receiver to set the reward.
     * The reward type is set as `Native`, and the reward address is set to 0 (native coin).
     * The function emits the `AirdropRewardDefined` event for each reward added to the `_airdropRewards` mapping.
     *
     */
    function setAirdropNativeRewardBatch(uint airdropId_, uint chainId_, address[] calldata receivers_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = receivers_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setAirdropReward(receivers_[i], airdropId_, chainId_, RewardType.Native, address(0), amounts_[i], 0);
        }
    }

    /**
     * @notice Sets a multiple airdrop rewards as `ERC20-Token`
     * @param airdropId_ Competition or Airdrop ID
     * @param rewardAddress_ The address of the reward ERC20-Token
     * @param chainId_ The reward chain ID
     * @param receivers_[] Receiver address list to reward
     * @param amounts_[] The amount list of the reward
     *
     * @dev The function allows the reward definer to set multiple airdrop rewards with ERC20 tokens.
     * It takes the airdrop ID, reward address (ERC20 token address), chain ID, an array of receiver addresses,
     * and an array of reward amounts as parameters.
     * The function calls the internal `_setAirdropReward` function for each receiver to set the reward.
     * The reward type is set as `Token`, and the reward address is set to the provided ERC20 token address.
     * The function emits the `AirdropRewardDefined` event for each reward added to the `_airdropRewards` mapping.
     */
    function setAirdropTokenRewardBatch(uint airdropId_, address rewardAddress_, uint chainId_, address[] calldata receivers_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = receivers_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setAirdropReward(receivers_[i], airdropId_, chainId_, RewardType.Token, rewardAddress_, amounts_[i], 0);
        }
    }

    /**
     * @notice Claims the competition reward
     * @param ticketContract_ The address of the ticket NFT contract
     * @param ticketId_ The ID of the winning ticket
     *
     * @dev This function allows to claim a reward for a competition. It first fetches the reward associated with the
     * provided ticketContract_ and ticketId_ from the _competitionRewards mapping. It ensures that the reward exists
     * and has not already been claimed.
     *
     * Next, it checks the owner of the NFT ticket. The owner must be the sender of this transaction.
     *
     * The function then marks the reward as claimed to prevent double claiming.
     *
     * Depending on the chain ID of the reward, it either emits an event that the reward has been claimed on a
     * different chain or it executes a transfer of the reward. In case of a transfer, it checks the reward type
     * and executes either an ERC20 token transfer, an ERC721 NFT transfer, or a native coin transfer. In the end,
     * it emits an event that the reward has been claimed.
     */
    function claimCompetitionReward(address ticketContract_, uint ticketId_) external nonReentrant {
        Reward memory rew = _competitionRewards[ticketContract_][ticketId_];
        require(rew._exist, "Reward does not exist");
        require(!rew.isClaimed, "Reward already claimed");

        IERC721Upgradeable ticket = IERC721Upgradeable(ticketContract_);
        require(ticket.ownerOf(ticketId_) == _msgSender(), "You are not owner of this ticket");

        _competitionRewards[ticketContract_][ticketId_].isClaimed = true;

        CompRewardSource memory rewSource = _compRewardSource[ticketContract_][ticketId_];

        if (rew.chainId != chainId()) {
            // Reward isn't in current chain
            emit CompRewardClaimedOnDiffChain(rewSource.periodId, rewSource.competitionId, rew.rewardType, rew.rewardAddress, _msgSender(), rew.chainId, rew.amount, rew.tokenId);
        } else {
            // Reward is in current chain

            if (rew.rewardType == RewardType.Native) {
                // Native Transfer
                _sendNativeCoin(payable(_msgSender()), rew.amount);
            } else if (rew.rewardType == RewardType.Token) {
                // ERC20 Transfer
                _sendToken(_msgSender(), rew.rewardAddress, rew.amount);
            } else {
                // ERC721 Transfer
                _sendNFT(_msgSender(), rew.rewardAddress, rew.tokenId);
            }

            emit CompRewardClaimed(rewSource.periodId, rewSource.competitionId, rew.rewardType, rew.rewardAddress, _msgSender(), rew.amount, rew.tokenId);
        }
    }

    /**
     * @notice Fetches the competition reward associated with the given ticket contract and ticket ID
     * @param ticketContract_ The address of the ticket NFT contract
     * @param ticketId_ The ID of the ticket
     * @return Returns the Reward structure associated with the ticket contract and ticket ID
     *
     * @dev This function fetches the competition reward for the given ticket contract and ticket ID from the
     * _competitionRewards mapping and returns it.
     */
    function getCompetitionReward(address ticketContract_, uint ticketId_) external view returns (Reward memory) {
        return _competitionRewards[ticketContract_][ticketId_];
    }

    /**
     * @notice Fetches the count of unclaimed airdrop rewards associated with the given receiver and airdrop ID
     * @param receiver_ The address of the receiver
     * @param airdropId_ The ID of the airdrop
     *
     * @dev This function fetches the total count of airdrop rewards for the given receiver and airdrop ID
     * from the _airdropRewards mapping and then counts the number of those rewards that are unclaimed.
     * @return Count of unclaimed rewards as uint
     */
    function getUnClaimedAirdropRewardCount(address receiver_, uint airdropId_) external view returns (uint) {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);

        uint unclaimedCounter = 0;
        for (uint i = 0; i < rewardCount; ++i) {
            Reward memory rew = _airdropRewards[receiver_][airdropId_][i];
            if (!rew.isClaimed && rew._exist) {
                unclaimedCounter++;
            }
        }

        return unclaimedCounter;
    }

    /**
     * @notice Retrieves a specific airdrop reward
     * @param receiver_ The address of the receiver of the airdrop
     * @param airdropId_ The ID of the airdrop
     * @param rewardIndex The index of the reward in the list of rewards associated with the airdrop
     * @return The reward structure associated with the specified index within the airdrop
     *
     * @dev This external function allows anyone to retrieve the details of a specific reward associated
     * with an airdrop for a specific receiver. It checks if the rewardIndex is within the boundaries
     * of the array of rewards for the airdrop before returning the reward.
     */
    function getAirdropReward(address receiver_, uint airdropId_, uint rewardIndex) external view returns (Reward memory) {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);
        require(rewardIndex < rewardCount, "Reward index out of boundaries");
        return _airdropRewards[receiver_][airdropId_][rewardIndex];
    }

    /**
     * @notice Removes a specific airdrop reward. Used for handling exceptions
     * @param receiver_ The address of the receiver of the airdrop
     * @param airdropId_ The ID of the airdrop
     * @param rewardIndex The index of the reward in the list of rewards associated with the airdrop
     *
     * @dev This function can only be executed by the reward definer. It allows for removing a specific
     * reward associated with an airdrop for a specific receiver. It checks if the rewardIndex is
     * within the boundaries of the array of rewards for the airdrop, verifies the reward exists
     * and is unclaimed, and then replaces it with the last reward in the array before reducing
     * the array's length by one. A corresponding event is then emitted.
     */
    function removeAirdropReward(address receiver_, uint airdropId_, uint rewardIndex) external onlyRewardDefiner {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);
        require(rewardIndex < rewardCount, "Reward index out of boundaries");

        Reward memory rew = _airdropRewards[receiver_][airdropId_][rewardIndex];

        require(!rew.isClaimed, "Can not remove claimed reward");

        Reward[] storage receiverRewards = _airdropRewards[receiver_][airdropId_];
        receiverRewards[rewardIndex] = receiverRewards[rewardCount - 1];
        receiverRewards.pop();

        emit AirdropRewardUpdated(receiver_, rewardIndex, airdropId_);
    }

    /**
     * @notice Allows the caller to claim all unclaimed airdrop rewards associated with a specific airdrop ID
     * @param airdropId_ The ID of the airdrop for which to claim rewards
     *
     * @dev This function enables a user to claim all unclaimed rewards from a specific airdrop.
     * It iterates over all rewards associated with the caller's address and the provided
     * airdrop ID, and calls the internal `_claimAirdropReward` function for each unclaimed reward.
     */
    function claimAllAirdropRewards(uint airdropId_) external nonReentrant {
        uint rewardCount = getAirdropRewardCount(_msgSender(), airdropId_);

        for (uint i = 0; i < rewardCount; ++i) {
            Reward memory rew = _airdropRewards[_msgSender()][airdropId_][i];
            if (!rew.isClaimed && rew._exist) {
                _claimAirdropReward(_msgSender(), airdropId_, i);
            }
        }
    }

    /**
     * @notice Allows a user to claim a specific airdrop reward
     * @param airdropId_ The ID of the airdrop that includes the reward
     * @param rewardIndex The index of the reward in the list of rewards associated with the airdrop
     *
     * @dev This external function enables a caller to claim a specific reward from an airdrop.
     * It simply invokes the internal _claimAirdropReward function with the caller's address.
     */
    function claimAirdropReward(uint airdropId_, uint rewardIndex) external nonReentrant {
        _claimAirdropReward(_msgSender(), airdropId_, rewardIndex);
    }

    /**
     * @notice This function returns the chainId of the current blockchain.
     * @return The chainId of the blockchain where the contract is currently deployed.
     */
    function chainId() public view returns (uint) {
        return block.chainid;
    }

    /**
     * @notice Fetches the count of airdrop rewards associated with the given receiver and airdrop ID
     * @param receiver_ The address of the receiver
     * @param airdropId_ The ID of the airdrop
     *
     * @dev This function fetches the count of airdrop rewards for the given receiver and airdrop ID from the
     * _airdropRewards mapping and returns it.
     * @return Airdrop reward count as uint
     */
    function getAirdropRewardCount(address receiver_, uint airdropId_) public view returns (uint) {
        return _airdropRewards[receiver_][airdropId_].length;
    }

    /**
     * @notice Internal function to set the reward definer address
     * @param rewardDefiner_ The address of the reward definer
     *
     * @dev Note that the function checks if the reward definer address is not zero. The reward definer address must be a valid address.
     * After validating the address, the function sets the `rewardDefiner` variable to the specified address.
     */
    function _setRewardDefiner(address rewardDefiner_) internal {
        require(rewardDefiner_ != address(0), "Reward definer address can not be zero");
        if (rewardDefiner != rewardDefiner_) {
            rewardDefiner = rewardDefiner_;
            emit SetRewardDefiner(rewardDefiner_);
        }
    }

    /**
     * @notice Sets a single competition reward
     * @param periodId The period ID
     * @param competitionId The competition ID
     * @param ticket_ The address of the winner ticket NFT
     * @param ticketId_ The ID of the winner ticket
     * @param chainId_ The chain ID
     * @param rewardType The type of the reward
     * @param rewardAddress_ The address of the reward
     * @param amount The amount of the reward
     * @param tokenId The ID of the token
     *
     * @dev Note that the function checks if the reward is already claimed. If the reward is claimed, it cannot be updated.
     * The function also checks if the reward type is Token or NFT, in which case the reward address must not be zero.
     * If the reward already exists, the function emits a `CompRewardUpdated` event. Otherwise, it emits a `CompRewardDefined` event.
     * The function updates the competition reward mapping and the competition reward source mapping with the specified values.
     *
     */
    function _setCompetitionReward(uint256 periodId, uint256 competitionId, address ticket_, uint256 ticketId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) internal {
        Reward memory reward = _competitionRewards[ticket_][ticketId_];
        require(!reward.isClaimed, "Cant update claimed reward !");

        if (rewardType == RewardType.Token || rewardType == RewardType.NFT) {
            require(rewardAddress_ != address(0), "Token or NFT reward must has contract address");
        }

        if (reward._exist) {
            emit CompRewardUpdated(ticket_, ticketId_);
        } else {
            emit CompRewardDefined(ticket_, ticketId_);
        }

        _compRewardSource[ticket_][ticketId_] = CompRewardSource(periodId, competitionId);
        _competitionRewards[ticket_][ticketId_] = Reward(chainId_, rewardType, rewardAddress_, amount, tokenId, false, true);
    }

    /**
     * @notice Sets a single airdrop without ticket
     * @param receiver_ Receiver address to reward
     * @param airdropId_ Competition or Airdrop ID
     * @param chainId_ The reward chain ID
     * @param rewardType The type of the reward
     * @param rewardAddress_ The address of the reward
     * @param amount The amount of the reward
     * @param tokenId The ID of the token
     *
     * @dev The function allows the reward definer to set a single airdrop reward without requiring a ticket.
     * The reward is defined by calling the internal `_setAirdropReward` function with the specified values.
     * The function emits the `AirdropRewardDefined` event and adds the reward to the `_airdropRewards` mapping.
     *
     */
    function _setAirdropReward(address receiver_, uint airdropId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) internal {
        uint airdropRewardCount = _airdropRewards[receiver_][airdropId_].length;

        if (rewardType == RewardType.Token || rewardType == RewardType.NFT) {
            require(rewardAddress_ != address(0), "Token or NFT reward must has contract address");
        }

        emit AirdropRewardDefined(receiver_, airdropRewardCount, airdropId_);

        _airdropRewards[receiver_][airdropId_].push(Reward(chainId_, rewardType, rewardAddress_, amount, tokenId, false, true));
    }

    /**
     * @notice This internal function allows a specific airdrop reward to be claimed
     * @param receiver_ The address of the receiver who claims the reward
     * @param airdropId_ The ID of the airdrop that includes the reward
     * @param rewardIndex The index of the reward in the list of rewards associated with the airdrop
     *
     * @dev This function enables a specific reward from an airdrop to be claimed. It requires that the
     * reward exists and has not yet been claimed. Once the reward is claimed, depending on its type
     * and whether it's in the current chain, the function emits an event and transfers the reward.
     */
    function _claimAirdropReward(address receiver_, uint airdropId_, uint rewardIndex) internal {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);
        require(rewardIndex < rewardCount, "Reward index out of boundaries");

        Reward memory rew = _airdropRewards[receiver_][airdropId_][rewardIndex];
        require(!rew.isClaimed, "Reward already claimed");

        _airdropRewards[receiver_][airdropId_][rewardIndex].isClaimed = true;

        if (rew.chainId != chainId()) {
            // Reward isn't in current chain
            emit AirdropRewardClaimedOnDiffChain(airdropId_, rewardIndex, rew.rewardType, rew.rewardAddress, receiver_, rew.chainId, rew.amount, rew.tokenId);
        } else {
            // Reward is in current chain

            if (rew.rewardType == RewardType.Native) {
                // Native Transfer
                _sendNativeCoin(payable(receiver_), rew.amount);
            } else if (rew.rewardType == RewardType.Token) {
                // ERC20 Transfer
                _sendToken(receiver_, rew.rewardAddress, rew.amount);
            } else {
                // ERC721 Transfer
                _sendNFT(receiver_, rew.rewardAddress, rew.tokenId);
            }

            emit AirdropRewardClaimed(airdropId_, rewardIndex, rew.rewardType, rew.rewardAddress, receiver_, rew.amount, rew.tokenId);
        }
    }
}
