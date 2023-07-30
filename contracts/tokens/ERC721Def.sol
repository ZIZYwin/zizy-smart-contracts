// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @dev Default ERC721 Token
contract ERC721Def is ERC721, ERC721Enumerable, Ownable {

    /**
     * @dev Ticket base uri [optional]
     */
    string public baseUri = "";

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {

    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Set base uri
     */
    function setBaseURI(string memory baseUri_) external virtual onlyOwner {
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
     * @dev Mint NFT
     */
    function mint(address to_, uint256 ticketId_) external virtual onlyOwner {
        _mint(to_, ticketId_);
    }

    /**
     * @dev Batch mint NFT
     */
    function mintBatch(address to_, uint256 ticketMin_, uint256 ticketMax_) external onlyOwner {
        for (uint i = ticketMin_; i <= ticketMax_; ++i) {
            _mint(to_, i);
        }
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
    ) internal virtual override(ERC721, ERC721Enumerable) {
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
