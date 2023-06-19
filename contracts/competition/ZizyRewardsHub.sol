// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

// @dev Zizy rewards HUB
contract ZizyRewardsHub is OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event CompRewardDefined(address indexed ticket, uint256 ticketId);
    event CompRewardUpdated(address indexed ticket, uint256 ticketId);
    event AirdropRewardDefined(address indexed receiver, uint rewardIndex, uint256 airdropId);
    event AirdropRewardUpdated(address indexed receiver, uint rewardIndex, uint256 airdropId);
    event AirdropRewardClaimed(uint256 indexed airdropId, uint rewardIndex, RewardType rewardType, address rewardAddress, address receiver, uint amount, uint tokenId);
    event AirdropRewardClaimedOnDiffChain(uint256 indexed airdropId, uint rewardIndex, RewardType rewardType, address rewardAddress, address receiver, uint chainId, uint amount, uint tokenId);
    event CompRewardClaimed(uint256 periodId, uint256 competitionId, RewardType rewardType, address rewardAddress, address receiver, uint amount, uint tokenId);
    event CompRewardClaimedOnDiffChain(uint256 periodId, uint256 competitionId, RewardType rewardType, address rewardAddress, address receiver, uint chainId, uint amount, uint tokenId);

    enum RewardType {
        Token,
        NFT,
        Native
    }

    struct CompRewardSource {
        uint256 periodId;
        uint256 competitionId;
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

    // Competition reward sources [TicketNFTAddress > TokenID > CompRewardSource]
    mapping(address => mapping(uint256 => CompRewardSource)) private _compRewardSource;

    // Airdrop rewards [Account > AirdropID > Reward[]]
    mapping(address => mapping(uint256 => Reward[])) private _airdropRewards;

    // Throw if caller isn't reward definer address
    modifier onlyRewardDefiner() {
        require(_msgSender() == rewardDefiner, "Only call from reward definer !");
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
        require(token.allowance(_msgSender(), address(this)) >= amount, "Insufficient allowance");
        token.safeTransferFrom(_msgSender(), address(this), amount);
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
        nft.safeTransferFrom(_msgSender(), address(this), tokenId_);
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
    function _setCompetitionReward(uint256 periodId, uint256 competitionId, address ticket_, uint256 ticketId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) internal {
        Reward memory reward = _competitionRewards[ticket_][ticketId_];
        require(reward.isClaimed == false, "Cant update claimed reward !");

        if (rewardType == RewardType.Token || rewardType == RewardType.NFT) {
            require(rewardAddress_ != address(0), "Token or NFT reward must has contract address");
        }

        if (reward._exist == true) {
            emit CompRewardUpdated(ticket_, ticketId_);
        } else {
            emit CompRewardDefined(ticket_, ticketId_);
        }

        _compRewardSource[ticket_][ticketId_] = CompRewardSource(periodId, competitionId);
        _competitionRewards[ticket_][ticketId_] = Reward(chainId_, rewardType, rewardAddress_, amount, tokenId, false, true);
    }

    // Define competition reward
    function setCompetitionReward(uint256 periodId, uint256 competitionId, address ticket_, uint256 ticketId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) external onlyRewardDefiner {
        _setCompetitionReward(periodId, competitionId, ticket_, ticketId_, chainId_, rewardType, rewardAddress_, amount, tokenId);
    }

    // Define Batch Native coin rewards on competition
    function setCompetitionNativeRewardBatch(uint256 periodId, uint256 competitionId, address ticket_, uint chainId_, uint[] calldata ticketIds_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = ticketIds_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setCompetitionReward(periodId, competitionId, ticket_, ticketIds_[i], chainId_, RewardType.Native, address(0), amounts_[i], 0);
        }
    }

    // Define Batch ERC20-Standard token rewards on competition
    function setCompetitionTokenRewardBatch(uint256 periodId, uint256 competitionId, address ticket_, uint chainId_, address rewardAddress_, uint[] calldata ticketIds_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = ticketIds_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setCompetitionReward(periodId, competitionId, ticket_, ticketIds_[i], chainId_, RewardType.Token, rewardAddress_, amounts_[i], 0);
        }
    }

    // Set single airdrop reward
    function _setAirdropReward(address receiver_, uint airdropId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) internal {
        uint airdropRewardCount = _airdropRewards[receiver_][airdropId_].length;

        if (rewardType == RewardType.Token || rewardType == RewardType.NFT) {
            require(rewardAddress_ != address(0), "Token or NFT reward must has contract address");
        }

        emit AirdropRewardDefined(receiver_, airdropRewardCount, airdropId_);

        _airdropRewards[receiver_][airdropId_].push(Reward(chainId_, rewardType, rewardAddress_, amount, tokenId, false, true));
    }

    // Define airdrop reward
    function setAirdropReward(address receiver_, uint airdropId_, uint chainId_, RewardType rewardType, address rewardAddress_, uint amount, uint tokenId) external onlyRewardDefiner {
        _setAirdropReward(receiver_, airdropId_, chainId_, rewardType, rewardAddress_, amount, tokenId);
    }

    // Define Batch Native coin rewards on airdrop
    function setAirdropNativeRewardBatch(uint airdropId_, uint chainId_, address[] calldata receivers_, uint[] calldata amounts_) external onlyRewardDefiner {
        uint len = receivers_.length;
        require(len > 0, "Rewards is not filled");
        require(amounts_.length == len, "Rewards length does not match");

        for (uint i = 0; i < len; ++i) {
            _setAirdropReward(receivers_[i], airdropId_, chainId_, RewardType.Native, address(0), amounts_[i], 0);
        }
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

    // Claim competition rewards
    function claimCompetitionReward(address ticketContract_, uint ticketId_) external nonReentrant {
        Reward memory rew = _competitionRewards[ticketContract_][ticketId_];
        require(rew._exist == true, "Reward does not exist");
        require(rew.isClaimed == false, "Reward already claimed");

        IERC721Upgradeable ticket = IERC721Upgradeable(ticketContract_);
        require(ticket.ownerOf(ticketId_) == _msgSender(), "You are not owner of this ticket");

        _competitionRewards[ticketContract_][ticketId_].isClaimed = true;

        CompRewardSource memory rewSource = _compRewardSource[ticketContract_][ticketId_];

        if (rew.chainId != chainId()) {
            // Reward isn't in current chain
            emit CompRewardClaimedOnDiffChain(rewSource.periodId, rewSource.competitionId, rew.rewardType, rew.rewardAddress, _msgSender(), rew.chainId, rew.amount, rew.tokenId);
        } else {
            // Reward is in current chain

            if (rew.rewardType == RewardType.Token) {
                // ERC20 Transfer
                _sendToken(_msgSender(), rew.rewardAddress, rew.amount);
            } else if (rew.rewardType == RewardType.NFT) {
                // ERC721 Transfer
                _sendNFT(_msgSender(), rew.rewardAddress, rew.tokenId);
            } else if (rew.rewardType == RewardType.Native) {
                // Native Transfer
                _sendNativeCoin(payable(_msgSender()), rew.amount);
            }

            emit CompRewardClaimed(rewSource.periodId, rewSource.competitionId, rew.rewardType, rew.rewardAddress, _msgSender(), rew.amount, rew.tokenId);
        }
    }

    // Get competition reward
    function getCompetitionReward(address ticketContract_, uint ticketId_) external view returns (Reward memory) {
        return _competitionRewards[ticketContract_][ticketId_];
    }

    // Get airdrop reward count
    function getAirdropRewardCount(address receiver_, uint airdropId_) public view returns (uint) {
        return _airdropRewards[receiver_][airdropId_].length;
    }

    // Get un-claimed airdrop reward count
    function getUnClaimedAirdropRewardCount(address receiver_, uint airdropId_) external view returns (uint) {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);

        uint unclaimedCounter = 0;
        for (uint i = 0; i < rewardCount; ++i) {
            Reward memory rew = _airdropRewards[receiver_][airdropId_][i];
            if (rew.isClaimed == false && rew._exist == true) {
                unclaimedCounter++;
            }
        }

        return unclaimedCounter;
    }

    // Claim all un-claimed airdrop rewards
    function claimAllAirdropRewards(uint airdropId_) external nonReentrant {
        uint rewardCount = getAirdropRewardCount(_msgSender(), airdropId_);

        for (uint i = 0; i < rewardCount; ++i) {
            Reward memory rew = _airdropRewards[_msgSender()][airdropId_][i];
            if (rew.isClaimed == false && rew._exist == true) {
                _claimAirdropReward(_msgSender(), airdropId_, i);
            }
        }

    }

    // Claim airdrop reward
    function _claimAirdropReward(address receiver_, uint airdropId_, uint rewardIndex) internal {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);
        require(rewardIndex < rewardCount, "Reward index out of boundaries");

        Reward memory rew = _airdropRewards[receiver_][airdropId_][rewardIndex];
        require(rew._exist == true, "Reward does not exist");
        require(rew.isClaimed == false, "Reward already claimed");

        _airdropRewards[receiver_][airdropId_][rewardIndex].isClaimed = true;

        if (rew.chainId != chainId()) {
            // Reward isn't in current chain
            emit AirdropRewardClaimedOnDiffChain(airdropId_, rewardIndex, rew.rewardType, rew.rewardAddress, receiver_, rew.chainId, rew.amount, rew.tokenId);
        } else {
            // Reward is in current chain

            if (rew.rewardType == RewardType.Token) {
                // ERC20 Transfer
                _sendToken(receiver_, rew.rewardAddress, rew.amount);
            } else if (rew.rewardType == RewardType.NFT) {
                // ERC721 Transfer
                _sendNFT(receiver_, rew.rewardAddress, rew.tokenId);
            } else if (rew.rewardType == RewardType.Native) {
                // Native Transfer
                _sendNativeCoin(payable(receiver_), rew.amount);
            }

            emit AirdropRewardClaimed(airdropId_, rewardIndex, rew.rewardType, rew.rewardAddress, receiver_, rew.amount, rew.tokenId);
        }
    }

    // Claim airdrop reward
    function claimAirdropReward(uint airdropId_, uint rewardIndex) external nonReentrant {
        _claimAirdropReward(_msgSender(), airdropId_, rewardIndex);
    }

    // Get airdrop reward
    function getAirdropReward(address receiver_, uint airdropId_, uint rewardIndex) external view returns (Reward memory) {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);
        require(rewardIndex < rewardCount, "Reward index out of boundaries");
        return _airdropRewards[receiver_][airdropId_][rewardIndex];
    }

    // Remove airdrop reward. For exceptions
    function removeAirdropReward(address receiver_, uint airdropId_, uint rewardIndex) external onlyRewardDefiner {
        uint rewardCount = getAirdropRewardCount(receiver_, airdropId_);
        require(rewardIndex < rewardCount, "Reward index out of boundaries");

        Reward memory rew = _airdropRewards[receiver_][airdropId_][rewardIndex];

        require(rew._exist == true, "Reward does not exist");
        require(rew.isClaimed == false, "Can not remove claimed reward");

        Reward[] storage receiverRewards = _airdropRewards[receiver_][airdropId_];
        receiverRewards[rewardIndex] = receiverRewards[rewardCount - 1];
        receiverRewards.pop();

        emit AirdropRewardUpdated(receiver_, rewardIndex, airdropId_);
    }
}
