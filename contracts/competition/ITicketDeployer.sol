// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @title TicketDeployer Interface
 * @notice This interface represents the TicketDeployer contract.
 * @dev This interface defines the functions of the TicketDeployer contract.
 */
interface ITicketDeployer {
    /**
     * @notice Deploy a new Ticket NFT contract.
     * @param name_ The name of the ticket contract.
     * @param symbol_ The symbol of the ticket contract.
     * @return The index of the deployed contract and the address of the deployed ticket contract.
     */
    function deploy(string memory name_, string memory symbol_) external returns(uint256, address);

    /**
     * @notice Get the count of deployed contracts.
     * @return The count of deployed contracts.
     */
    function getDeployedContractCount() external view returns(uint256);
}
