// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IZizyCompetitionTicket.sol";

/**
 * @title ZizyCompetitionTicket
 * @notice This contract represents the competition ticket contract, where unique tickets can be minted, transferred, and paused.
 * @dev This contract inherits from the ERC721, ERC721Enumerable, ERC721Pausable, and Ownable contracts from OpenZeppelin.
 */
contract ZizyCompetitionTicket is ERC721, IZizyCompetitionTicket, ERC721Enumerable, ERC721Pausable, Ownable {

    /**
     * @dev Ticket base uri [optional]
     */
    string public baseUri = "";

    /**
     * @notice Emitted when a new ticket is minted.
     * @param ticketOwner The address of the owner of the ticket.
     * @param ticketId The ID of the minted ticket.
     */
    event TicketMinted(address ticketOwner, uint256 ticketId);

    /**
     * @dev Emitted when base uri changed
     * @param timestamp Block timestamp
     */
    event BaseURIUpdated(uint timestamp);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {

    }

    /**
     * @notice Sets the base URI for token metadata
     * @param baseUri_ The base URI string
     *
     * @dev This function can only be called by the contract owner.
     * It sets the base URI for computing the {tokenURI} of each token.
     */
    function setBaseURI(string memory baseUri_) external virtual onlyOwner {
        baseUri = baseUri_;
        emit BaseURIUpdated(block.timestamp);
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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function isPaused() external view returns (bool) {
        return paused();
    }

    /**
     * @notice Mints a new competition ticket
     * @param to_ The address to mint the ticket to
     * @param ticketId_ The ID of the ticket to mint
     *
     * @dev This function can only be called by the contract owner.
     * It mints a new competition ticket to the specified address with the specified ticket ID.
     * It emits a `TicketMinted` event.
     * If the contract is paused on minting, it will temporarily unpause the contract during the minting process.
     */
    function mint(address to_, uint256 ticketId_) external virtual onlyOwner {
        _mint(to_, ticketId_);
        emit TicketMinted(to_, ticketId_);
    }

    /**
     * @inheritdoc ERC721
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ERC721
     */
    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseUri;
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
