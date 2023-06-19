// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IZizyCompetitionTicket is IERC721, IERC721Enumerable {
    event TicketMinted(address ticketOwner, uint256 ticketId);

    function setBaseURI(string memory baseUri_) external;
    function mint(address to_, uint256 ticketId_) external;
    function pause() external;
    function unpause() external;
}
