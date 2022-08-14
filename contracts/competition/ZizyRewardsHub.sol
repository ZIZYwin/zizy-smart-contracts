// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

// @dev Zizy rewards HUB
contract ZizyRewardsHub is OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event CompRewardDefined(address indexed ticket, uint256 ticketId);
    event CompRewardUpdated(address indexed ticket, uint256 ticketId);
    event AirdropRewardDefined(address indexed receiver, uint256 airdropId);
    event AirdropRewardUpdated(address indexed receiver, uint256 airdropId);
    event RewardClaimed(RewardType rewardType, address rewardAddress, address receiver, uint amount, uint tokenId);
    event RewardClaimedOnDiffChain(RewardType rewardType, address rewardAddress, address receiver, uint chainId, uint amount, uint tokenId);

    enum RewardType {
        Token,
        NFT,
        Native
    }

    struct Reward {
        uint chainId;
        RewardType rewardType;
        address rewardAddress;
        uint amount; // Only (ERC-20 Standard token & Native coin) rewards
        uint tokenId; // Only NFT rewards
        bool isClaimed;
        bool _exist;
    }

    address public rewardDefiner;

    // Competition rewards [TicketNFTAddress > TokenID > Reward]
    mapping(address => mapping(uint256 => Reward)) private _competitionRewards;

    // Airdrop rewards [Account > AirdropID > Reward]
    mapping(address => mapping(uint256 => Reward)) private _airdropRewards;

    // Throw if caller isn't reward definer address
    modifier onlyRewardDefiner() {
        require(msg.sender == rewardDefiner, "Only call from reward definer !");
        _;
    }

    function initialize(address rewardDefiner_) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721Holder_init();
        _setRewardDefiner(rewardDefiner_);
    }

    // Get chainId
    function chainId() public view returns (uint) {
        return block.chainid;
    }

    // Deposit native coin on contract
    function deposit() public payable {
    }

    // Withdraw native coin
    function _sendNativeCoin(address payable to_, uint amount) internal {
        require(address(this).balance >= amount, "Insufficient native balance");
        (bool sent,) = to_.call{value : amount}("");
        require(sent, "Native coin transfer failed");
    }

    // Withdraw native coin from contract
    function withdraw(uint amount) external nonReentrant onlyOwner {
        address payable to_ = payable(owner());
        _sendNativeCoin(to_, amount);
    }

    // Withdraw native coin from contract to address
    function withdrawTo(address payable to_, uint amount) external nonReentrant onlyOwner {
        _sendNativeCoin(to_, amount);
    }

    // Deposit reward tokens to contract
    function depositToken(address token_, uint amount) external onlyOwner {
        IERC20Upgradeable token = IERC20Upgradeable(token_);
        require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    // Withdraw ERC20-Standards token
    function _sendToken(address to_, address token_, uint amount) internal {
        IERC20Upgradeable token = IERC20Upgradeable(token_);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        token.safeTransfer(to_, amount);
    }

    // Withdraw token from contract
    function withdrawToken(address token_, uint amount) external onlyOwner {
        _sendToken(owner(), token_, amount);
    }

    // Withdraw token from contract to address
    function withdrawTokenTo(address to_, address token_, uint amount) external onlyOwner {
        _sendToken(to_, token_, amount);
    }

    // Deposit reward NFT's to contract
    function depositNFT(address token_, uint tokenId_) external onlyOwner {
        IERC721Upgradeable nft = IERC721Upgradeable(token_);
        nft.safeTransferFrom(msg.sender, address(this), tokenId_);
    }

    // Withdraw ERC721-Standard token
    function _sendNFT(address to_, address token_, uint tokenId_) internal {
        IERC721Upgradeable nft = IERC721Upgradeable(token_);
        require(nft.ownerOf(tokenId_) == address(this), "Rewards hub contract is not owner of this nft");
        nft.safeTransferFrom(address(this), to_, tokenId_);
    }

    // Withdraw NFT from contract
    function withdrawNFT(address token_, uint tokenId_) external onlyOwner {
        _sendNFT(owner(), token_, tokenId_);
    }

    // Withdraw NFT from contract to address
    function withdrawNFTTo(address to_, address token_, uint tokenId_) external onlyOwner {
        _sendNFT(to_, token_, tokenId_);
    }

    // Set reward definer address
    function _setRewardDefiner(address rewardDefiner_) internal {
        require(rewardDefiner_ != address(0), "Reward definer address can not be zero");
        rewardDefiner = rewardDefiner_;
    }

    // Set reward definer address
    function setRewardDefiner(address rewardDefiner_) external onlyOwner {
        _setRewardDefiner(rewardDefiner_);
    }

    // Set single competition reward
    function _setCompetitionReward(address ticket_, uint256 ticketId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) internal {
        Reward memory reward = _competitionRewards[ticket_][ticketId_];
        require(reward.isClaimed == false, "Cant update claimed reward !");

        if (rewardType == RewardType.Token || rewardType == RewardType.NFT) {
            require(rewardAddress_ != address(0), "Token or NFT reward must has contract address");
        }

        if (reward._exist == true) {
            emit CompRewardDefined(ticket_, ticketId_);
        } else {
            emit CompRewardUpdated(ticket_, ticketId_);
        }

        _competitionRewards[ticket_][ticketId_] = Reward(chainId_, rewardType, rewardAddress_, amount, tokenId, false, true);
    }

    // Define competition reward
    function setCompetitionReward(address ticket_, uint256 ticketId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) external onlyRewardDefiner {
        _setCompetitionReward(ticket_, ticketId_, chainId_, rewardType, rewardAddress_, amount, tokenId);
    }

    // Define Batch ERC20-Standard token rewards on competition
    function setCompetitionTokenRewardBatch(address ticket_, uint chainId_, address rewardAddress_, uint[] calldata ticketIds_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = ticketIds_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setCompetitionReward(ticket_, ticketIds_[i], chainId_, RewardType.Token, rewardAddress_, amounts_[i], 0);
        }
    }

    // Set single airdrop reward
    function _setAirdropReward(address receiver_, uint airdropId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) internal {
        Reward memory reward = _airdropRewards[receiver_][airdropId_];
        require(reward.isClaimed == false, "Cant update claimed reward !");

        if (rewardType == RewardType.Token || rewardType == RewardType.NFT) {
            require(rewardAddress_ != address(0), "Token or NFT reward must has contract address");
        }

        if (reward._exist == true) {
            emit AirdropRewardDefined(receiver_, airdropId_);
        } else {
            emit AirdropRewardUpdated(receiver_, airdropId_);
        }

        _airdropRewards[receiver_][airdropId_] = Reward(chainId_, rewardType, rewardAddress_, amount, tokenId, false, true);
    }

    // Define airdrop reward
    function setAirdropReward(address receiver_, uint airdropId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) external onlyRewardDefiner {
        _setAirdropReward(receiver_, airdropId_, chainId_, rewardType, rewardAddress_, amount, tokenId);
    }

    // Define Batch ERC20-Standard token reward on airdrop
    function setAirdropTokenRewardBatch(uint airdropId_, address rewardAddress_, uint chainId_, address[] calldata receivers_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = receivers_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setAirdropReward(receivers_[i], airdropId_, chainId_, RewardType.Token, rewardAddress_, amounts_[i], 0);
        }
    }

    // Claim airdrop reward
    function claimAirdropReward(uint airdropId_) external nonReentrant {
        Reward memory rew = _airdropRewards[msg.sender][airdropId_];
        require(rew._exist == true, "Reward does not exist");
        require(rew.isClaimed == false, "Reward already claimed");

        _airdropRewards[msg.sender][airdropId_].isClaimed = true;

        if (rew.chainId != chainId()) {
            // Reward isn't in current chain
            emit RewardClaimedOnDiffChain(rew.rewardType, rew.rewardAddress, msg.sender, rew.chainId, rew.amount, rew.tokenId);
        } else {
            // Reward is in current chain

            if (rew.rewardType == RewardType.Token) {
                // ERC20 Transfer
                _sendToken(msg.sender, rew.rewardAddress, rew.amount);
            } else if (rew.rewardType == RewardType.NFT) {
                // ERC721 Transfer
                _sendNFT(msg.sender, rew.rewardAddress, rew.tokenId);
            } else if (rew.rewardType == RewardType.Native) {
                // Native Transfer
                _sendNativeCoin(payable(msg.sender), rew.amount);
            }

            emit RewardClaimed(rew.rewardType, rew.rewardAddress, msg.sender, rew.amount, rew.tokenId);
        }
    }

    // Claim competition rewards
    function claimCompetitionReward(address ticketContract_, uint ticketId_) external nonReentrant {
        Reward memory rew = _competitionRewards[ticketContract_][ticketId_];
        require(rew._exist == true, "Reward does not exist");
        require(rew.isClaimed == false, "Reward already claimed");

        IERC721Upgradeable ticket = IERC721Upgradeable(ticketContract_);
        require(ticket.ownerOf(ticketId_) == msg.sender, "You are not owner of this ticket");

        _competitionRewards[ticketContract_][ticketId_].isClaimed = true;

        if (rew.chainId != chainId()) {
            // Reward isn't in current chain
            emit RewardClaimedOnDiffChain(rew.rewardType, rew.rewardAddress, msg.sender, rew.chainId, rew.amount, rew.tokenId);
        } else {
            // Reward is in current chain

            if (rew.rewardType == RewardType.Token) {
                // ERC20 Transfer
                _sendToken(msg.sender, rew.rewardAddress, rew.amount);
            } else if (rew.rewardType == RewardType.NFT) {
                // ERC721 Transfer
                _sendNFT(msg.sender, rew.rewardAddress, rew.tokenId);
            } else if (rew.rewardType == RewardType.Native) {
                // Native Transfer
                _sendNativeCoin(payable(msg.sender), rew.amount);
            }

            emit RewardClaimed(rew.rewardType, rew.rewardAddress, msg.sender, rew.amount, rew.tokenId);
        }
    }

    // Get airdrop reward
    function getAirdropReward(address receiver_, uint airdropId_) external view returns (Reward memory) {
        return _airdropRewards[receiver_][airdropId_];
    }

    // Get competition reward
    function getCompetitionReward(address ticketContract_, uint ticketId_) external view returns (Reward memory) {
        return _competitionRewards[ticketContract_][ticketId_];
    }
}
