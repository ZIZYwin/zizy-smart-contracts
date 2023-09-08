// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../utils/DepositWithdraw.sol";

/**
 * @dev Initializes the contract
 * @notice Useless on production. Just test purpose
 */
contract DepositWithdrawTest is DepositWithdraw {
    /**
     * @dev Constructor function
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the DepositWithdrawTest contract.
     *
     * @dev This function is used to initialize the DepositWithdrawTest contract
     */
    function initialize() external initializer {
        __DepositWithdraw_init();
    }

    /**
     * @notice Test method for coverage
     */
    function __DepositWithdraw_init_Test() external {
        __DepositWithdraw_init();
    }

    /**
     * @notice Test method for coverage
     */
    function __DepositWithdraw_init_unchained_Test() external {
        __DepositWithdraw_init_unchained();
    }
}
