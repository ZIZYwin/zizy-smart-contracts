// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

/**
 * @dev Initializes the contract setting the deployer as the initial owner.
 */
contract DepositWithdraw is OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @dev Storage gap for futures updates
     */
    uint256[49] private __gap;

    /**
     * @notice Allows anyone to deposit native coin on the contract
     */
    function deposit() public payable {
    }

    /**
     * @notice This internal function handles the transfer of native coins (Ether in case of Ethereum).
     * @param to_ The recipient's address. The recipient must be payable, as they are receiving native coins.
     * @param amount The amount of native coins to be transferred. This value is in the smallest denomination (Wei in case of Ethereum).
     *
     * @dev Note that the function checks if the contract has sufficient balance to send the requested amount.
     * If there are not enough native coins in the contract, the transaction will fail with an error message.
     * After confirming there are enough native coins, the function uses a low-level `call` to transfer them.
     */
    function _sendNativeCoin(address payable to_, uint amount) internal {
        require(address(this).balance >= amount, "Insufficient native balance");
        (bool sent,) = to_.call{value : amount}("");
        require(sent, "Native coin transfer failed");
    }

    /**
     * @notice Internal function to send ERC20 tokens
     * @param to_ The address of the recipient of the ERC20 token transfer. The recipient must be a valid address.
     * @param token_ The address of the ERC20 token to send.
     * @param amount The amount of ERC20 tokens to send.
     *
     * @dev Note that the function checks if the contract has sufficient balance of the specified ERC20 token to send the requested amount.
     * If there are not enough tokens in the contract, the transaction will fail with an error message.
     * After confirming there are enough tokens, the function uses the `safeTransfer` function of the ERC20 token contract to transfer the tokens to the recipient.
     */
    function _sendToken(address to_, address token_, uint amount) internal {
        IERC20Upgradeable token = IERC20Upgradeable(token_);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        token.safeTransfer(to_, amount);
    }

    /**
     * @notice Internal function to send NFTs
     * @param to_ The address to send the NFT to. The address must be a valid address capable of receiving NFTs.
     * @param token_ The address of the NFT contract.
     * @param tokenId_ The ID of the NFT to send.
     *
     * @dev Note that the function checks if the contract is the owner of the specified NFT. Only if the contract owns the NFT, it can be transferred.
     * After confirming the ownership, the function uses the `safeTransferFrom` function of the NFT contract to transfer the NFT to the specified address.
     */
    function _sendNFT(address to_, address token_, uint tokenId_) internal {
        IERC721Upgradeable nft = IERC721Upgradeable(token_);
        require(nft.ownerOf(tokenId_) == address(this), "Rewards hub contract is not owner of this nft");
        nft.safeTransferFrom(address(this), to_, tokenId_);
    }

    /**
     * @notice This function allows the contract owner to withdraw native coins (Ether in case of Ethereum) from the contract.
     * @param amount The amount of native coins to withdraw. This value is in the smallest denomination (Wei in case of Ethereum).
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw native coins.
     * After confirming the ownership, the function uses the internal `_sendNativeCoin` function to send the native coins to the owner's address.
     */
    function withdraw(uint amount) external nonReentrant onlyOwner {
        address payable to_ = payable(owner());
        _sendNativeCoin(to_, amount);
    }

    /**
     * @notice This function allows the contract owner to withdraw native coins (Ether in case of Ethereum) from the contract and send them to a specific address.
     * @param to_ The address to send the native coins to. The address must be payable, as they are receiving native coins.
     * @param amount The amount of native coins to send. This value is in the smallest denomination (Wei in case of Ethereum).
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw native coins.
     * After confirming the ownership, the function uses the internal `_sendNativeCoin` function to send the native coins to the specified address.
     */
    function withdrawTo(address payable to_, uint amount) external nonReentrant onlyOwner {
        _sendNativeCoin(to_, amount);
    }

    /**
     * @notice Allows the contract owner to deposit reward tokens to the contract.
     * @param token_ The address of the token to deposit.
     * @param amount The amount of tokens to deposit.
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to deposit tokens.
     * The function requires that the contract has sufficient allowance from the caller to transfer the specified amount of tokens.
     * After confirming the allowance, the function uses the `safeTransferFrom` function of the token contract to transfer the tokens to the contract.
     */
    function depositToken(address token_, uint amount) external onlyOwner {
        IERC20Upgradeable token = IERC20Upgradeable(token_);
        require(token.allowance(_msgSender(), address(this)) >= amount, "Insufficient allowance");
        token.safeTransferFrom(_msgSender(), address(this), amount);
    }

    /**
     * @notice This function allows the contract owner to withdraw ERC20 tokens from the contract.
     * @param token_ The address of the token to withdraw.
     * @param amount The amount of tokens to withdraw.
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw tokens.
     * After confirming the ownership, the function uses the internal `_sendToken` function to send the tokens to the owner's address.
     */
    function withdrawToken(address token_, uint amount) external onlyOwner {
        _sendToken(owner(), token_, amount);
    }

    /**
     * @notice This function allows the contract owner to withdraw ERC20 tokens from the contract and send them to a specific address.
     * @param to_ The address to send the ERC20 tokens to. The address must be valid and capable of receiving ERC20 tokens.
     * @param token_ The address of the ERC20 token to send.
     * @param amount The amount of ERC20 tokens to send.
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw tokens.
     * After confirming the ownership, the function uses the internal `_sendToken` function to send the tokens to the specified address.
     */
    function withdrawTokenTo(address to_, address token_, uint amount) external onlyOwner {
        _sendToken(to_, token_, amount);
    }

    /**
     * @notice This function allows the contract owner to deposit NFT rewards to the contract.
     * @param token_ The address of the NFT contract.
     * @param tokenId_ The ID of the NFT to deposit.
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to deposit NFT rewards.
     * After confirming the ownership, the function uses the `safeTransferFrom` function of the NFT contract to transfer the NFT to the contract.
     */
    function depositNFT(address token_, uint tokenId_) external onlyOwner {
        IERC721Upgradeable nft = IERC721Upgradeable(token_);
        nft.safeTransferFrom(_msgSender(), address(this), tokenId_);
    }

    /**
     * @notice This function allows the contract owner to withdraw NFTs from the contract.
     * @param token_ The address of the NFT contract.
     * @param tokenId_ The ID of the NFT to withdraw.
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw NFTs.
     * After confirming the ownership, the function uses the internal `_sendNFT` function to send the NFT to the owner's address.
     */
    function withdrawNFT(address token_, uint tokenId_) external onlyOwner {
        _sendNFT(owner(), token_, tokenId_);
    }

    /**
     * @notice This function allows the contract owner to withdraw NFTs from the contract and send them to a specific address.
     * @param to_ The address to send the NFT to. The address must be valid and capable of receiving NFTs.
     * @param token_ The address of the NFT contract.
     * @param tokenId_ The ID of the NFT to send.
     *
     * @dev Note that the function checks if the contract owner is calling the function. Only the contract owner is allowed to withdraw NFTs.
     * After confirming the ownership, the function uses the internal `_sendNFT` function to send the NFT to the specified address.
     */
    function withdrawNFTTo(address to_, address token_, uint tokenId_) external onlyOwner {
        _sendNFT(to_, token_, tokenId_);
    }
}
