// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @dev Default ERC20 Token
contract ERC20Def is Context, ERC20, ERC20Burnable, Ownable {
    uint8 constant DECIMALS = 8;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(_msgSender(), (250_000_000 * (10 ** DECIMALS)));
    }

    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
