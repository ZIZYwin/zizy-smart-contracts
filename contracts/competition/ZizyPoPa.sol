// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @dev PoPa - NFT for competitions. Maybe a treasure is hidden here
contract ZizyPoPa is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {

    event PoPaMinted(address to, uint256 tokenId);

    /**
     * @dev Popa base uri [optional]
     */
    string public baseUri = "";

    address public minterAccount;

    constructor(string memory name_, string memory symbol_, address minter_) ERC721(name_, symbol_) {
        _setMinter(minter_);
    }

    // Throw if caller is not minter
    modifier onlyMinter() {
        require(msg.sender == minterAccount, "Only call from minter");
        _;
    }

    // Set minter account
    function _setMinter(address minter_) internal {
        require(minter_ != address(0), "Minter account can not be zero");
        minterAccount = minter_;
    }

    // Set minter account
    function setMinter(address minter_) external onlyOwner {
        _setMinter(minter_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Set base uri
     */
    function setBaseURI(string memory baseUri_) public virtual onlyOwner {
        baseUri = baseUri_;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseUri;
    }

    /**
     * @dev Popa minted
     */
    function mint(address to_, uint256 tokenId_) public virtual onlyMinter {
        _mint(to_, tokenId_);
        emit PoPaMinted(to_, tokenId_);
    }

    /**
     * @dev Pause token transfers
     */
    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev Un-pause token transfers
     */
    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
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
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
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
