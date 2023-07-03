// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ZizyCompetitionTicket.sol";

/**
 * @title TicketDeployer
 * @dev The TicketDeployer contract is responsible for deploying and managing ZizyCompetitionTicket contracts, which represent NFT tickets for competitions.
 * The contract inherits from the Ownable contract from OpenZeppelin to handle ownership and access control.
 */
contract TicketDeployer is Ownable {
    address[] public tickets;
    uint256 private ticketContractCounter = 0;

    /**
     * @dev Constructor function
     * @param owner_ The address of the contract owner
     */
    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    /**
     * @notice Deploy a new Ticket NFT contract
     * @param name_ The name of the ticket contract
     * @param symbol_ The symbol of the ticket contract
     * @return index The index of the deployed contract
     * @return ticketContract The address of the deployed ticket contract
     *
     * @dev This function allows the contract owner to deploy a new ZizyCompetitionTicket contract with the specified name and symbol.
     * The ownership of the deployed contract is transferred to the owner of the TicketDeployer contract.
     */
    function deploy(string memory name_, string memory symbol_) external onlyOwner returns(uint256, address) {
        uint256 index = ticketContractCounter;

        ZizyCompetitionTicket ticketContract = new ZizyCompetitionTicket(name_, symbol_);
        ticketContract.transferOwnership(owner());
        tickets.push(address(ticketContract));

        ticketContractCounter++;

        return (index, address(ticketContract));
    }

    /**
     * @notice Get the count of deployed ticket contracts
     * @return The count of deployed ticket contracts
     */
    function getDeployedContractCount() external view returns(uint256) {
        return ticketContractCounter;
    }
}
