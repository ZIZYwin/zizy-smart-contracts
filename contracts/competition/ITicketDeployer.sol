// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ITicketDeployer {
    function deploy(string memory name_, string memory symbol_) external returns(uint256, address);
    function getDeployedContractCount() external view returns(uint256);
}
