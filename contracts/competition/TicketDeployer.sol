// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ZizyCompetitionTicket.sol";

/**
 * @dev Zizy - Competition NFT Ticket Deployer
 */
contract TicketDeployer is Ownable {
    address[] public tickets;
    uint256 private ticketContractCounter = 0;

    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    // Deploy new Ticket NFT contract
    function deploy(string memory name_, string memory symbol_) external onlyOwner returns(uint256, address) {
        uint256 index = ticketContractCounter;

        ZizyCompetitionTicket ticketContract = new ZizyCompetitionTicket(name_, symbol_);
        ticketContract.transferOwnership(owner());
        tickets.push(address(ticketContract));

        ticketContractCounter++;

        return (index, address(ticketContract));
    }

    // Get deployed contract count
    function getDeployedContractCount() external view returns(uint256) {
        return ticketContractCounter;
    }
}
