// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IZizyPoPa is IERC721, IERC721Enumerable {
    event PoPaMinted(address to, uint256 tokenId);

    function setMinter(address minter_) external;
    function setBaseURI(string memory baseUri_) external;
    function mint(address to_, uint256 tokenId_) external;
    function pause() external;
    function unpause() external;
}
