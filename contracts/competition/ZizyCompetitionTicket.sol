// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/ERC721Pausable.sol";

// @dev We building sth big. Stay tuned!
contract ZizyCompetitionTicket is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {

    event TicketMinted(address ticketOwner, uint256 ticketId);

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
     * @dev Ticket mint [Override if contract is paused]
     */
    function mint(address to_, uint256 ticketId_) public virtual onlyOwner {
        bool isPausedOnMint = isPaused();

        if (isPausedOnMint) {
            _unpauseSilence();
        }

        _mint(to_, ticketId_);
        emit TicketMinted(to_, ticketId_);

        if (isPausedOnMint) {
            _pauseSilence();
        }
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
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
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
        uint256 tokenId
    ) internal virtual override(ERC721) {
        super._afterTokenTransfer(from, to, tokenId);
    }
}
