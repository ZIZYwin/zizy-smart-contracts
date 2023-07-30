// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * @title ZizyPoPa Interface
 * @notice This interface represents the ZizyPoPa contract, which is an ERC721 and ERC721Enumerable compliant contract.
 * @dev This interface defines the functions and events of the ZizyPoPa contract.
 */
interface IZizyPoPa is IERC721, IERC721Enumerable {
    /**
     * @notice Event emitted when a PoPa is minted.
     * @param to The address of the recipient of the minted PoPa.
     * @param tokenId The token ID of the minted PoPa.
     */
    event PoPaMinted(address to, uint256 tokenId);

    /**
     * @notice Sets the minter address.
     * @param minter_ The address of the new minter.
     */
    function setMinter(address minter_) external;

    /**
     * @notice Sets the base URI for computing token URIs.
     * @param baseUri_ The new base URI.
     */
    function setBaseURI(string memory baseUri_) external;

    /**
     * @notice Mints a new PoPa token and assigns it to the specified address.
     * @param to_ The address to which the PoPa token will be minted.
     * @param tokenId_ The token ID of the new PoPa token.
     */
    function mint(address to_, uint256 tokenId_) external;

    /**
     * @notice Pauses the minting and transferring of PoPa tokens.
     */
    function pause() external;

    /**
     * @notice Unpauses the minting and transferring of PoPa tokens.
     */
    function unpause() external;
}
