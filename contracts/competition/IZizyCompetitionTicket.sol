// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * @title ZizyCompetitionTicket Interface
 * @notice This interface represents the ZizyCompetitionTicket contract, which is an ERC721 and ERC721Enumerable compliant contract.
 * @dev This interface defines the functions and events of the ZizyCompetitionTicket contract.
 */
interface IZizyCompetitionTicket is IERC721, IERC721Enumerable {

    /**
     * @notice Sets the base URI for computing token URIs.
     * @param baseUri_ The new base URI.
     */
    function setBaseURI(string memory baseUri_) external;

    /**
     * @notice Mints a new ticket token and assigns it to the specified address.
     * @param to_ The address to which the ticket token will be minted.
     * @param ticketId_ The ID of the new ticket token.
     */
    function mint(address to_, uint256 ticketId_) external;

    /**
     * @notice Pauses the minting and transferring of ticket tokens.
     */
    function pause() external;

    /**
     * @notice Unpauses the minting and transferring of ticket tokens.
     */
    function unpause() external;

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function isPaused() external view returns (bool);
}
