// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ZizyPoPa
 * @notice This contract represents the PoPa (NFT for competitions) contract, where unique tokens can be minted, transferred, and paused.
 * @dev This contract inherits from the ERC721, ERC721Enumerable, ERC721Pausable, and Ownable contracts from OpenZeppelin.
 */
contract ZizyPoPa is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {

    /**
     * @dev Emitted when a new PoPa token is minted.
     * @param to The address to which the token is minted.
     * @param tokenId The ID of the minted token.
     */
    event PoPaMinted(address to, uint256 tokenId);

    /**
     * @dev Emitted when base uri changed
     * @param timestamp Block timestamp
     */
    event BaseURIUpdated(uint timestamp);

    /**
     * @dev Popa base uri [optional]
     */
    string public baseUri = "";

    /**
     * @notice The address of the minter account.
     */
    address public minterAccount;

    /**
     * @notice Initializes the ZizyPoPa contract.
     * @param name_ The name of the NFT contract.
     * @param symbol_ The symbol of the NFT contract.
     * @param minter_ The address of the minter account.
     *
     */
    constructor(string memory name_, string memory symbol_, address minter_) ERC721(name_, symbol_) {
        _setMinter(minter_);
    }

    /**
     * @dev Throws if the caller is not the minter account.
     */
    modifier onlyMinter() {
        require(msg.sender == minterAccount, "Only call from minter");
        _;
    }

    /**
     * @notice Sets the minter account address.
     * @param minter_ The address of the minter account.
     *
     * @dev It sets the minter account address to the specified address.
     */
    function _setMinter(address minter_) internal {
        require(minter_ != address(0), "Minter account can not be zero");
        minterAccount = minter_;
    }

    /**
     * @notice Sets the minter account address.
     * @param minter_ The address of the minter account.
     *
     * @dev This function can only be called by the contract owner.
     * It sets the minter account address to the specified address.
     */
    function setMinter(address minter_) external onlyOwner {
        _setMinter(minter_);
    }

    /**
     * @inheritdoc ERC721
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Sets the base URI for token metadata.
     * @param baseUri_ The base URI to be set.
     *
     * @dev This function can only be called by the contract owner.
     * It sets the base URI used for computing the tokenURI of each token.
     */
    function setBaseURI(string memory baseUri_) external virtual onlyOwner {
        baseUri = baseUri_;
        emit BaseURIUpdated(block.timestamp);
    }

    /**
     * @inheritdoc ERC721
     */
    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseUri;
    }

    /**
     * @notice Mints a new PoPa NFT token.
     * @param to_ The address to which the token will be minted.
     * @param tokenId_ The ID of the token to be minted.
     *
     * @dev This function can only be called by the minter account.
     * It mints a new PoPa token with the specified ID and assigns it to the specified address.
     * Emits a `PoPaMinted` event.
     */
    function mint(address to_, uint256 tokenId_) external virtual onlyMinter {
        _mint(to_, tokenId_);
        emit PoPaMinted(to_, tokenId_);
    }

    /**
     * @notice Pauses token transfers.
     *
     * @dev This function can only be called by the contract owner.
     * It pauses all token transfers.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Unpauses token transfers.
     *
     * @dev This function can only be called by the contract owner.
     * It unpauses all token transfers.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @inheritdoc ERC721
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    /**
     * @inheritdoc ERC721
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721) {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
