// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/**
 * @title CompetitionFactory Interface
 * @notice This interface represents the CompetitionFactory contract.
 * @dev This interface defines the functions of the CompetitionFactory contract.
 */
interface ICompetitionFactory {
    /**
     * @notice Get the total count of periods.
     * @return The total count of periods.
     */
    function totalPeriodCount() external view returns (uint);

    /**
     * @notice Get the total count of competitions.
     * @return The total count of competitions.
     */
    function totalCompetitionCount() external view returns (uint);

    /**
     * @notice Create a new competition period.
     * @param newPeriodId The ID of the new period.
     * @param startTime_ The start time of the period.
     * @param endTime_ The end time of the period.
     * @param ticketBuyStart_ The start time for buying tickets.
     * @param ticketBuyEnd_ The end time for buying tickets.
     * @return The ID of the created competition period.
     */
    function createCompetitionPeriod(uint newPeriodId, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external returns (uint256);

    /**
     * @notice Update a competition period.
     * @param periodId_ The ID of the period to update.
     * @param startTime_ The new start time of the period.
     * @param endTime_ The new end time of the period.
     * @param ticketBuyStart_ The new start time for buying tickets.
     * @param ticketBuyEnd_ The new end time for buying tickets.
     * @return A boolean indicating whether the update was successful.
     */
    function updateCompetitionPeriod(uint periodId_, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external returns (bool);

    /**
     * @notice Get the competition ID with the specified index.
     * @param periodId The ID of the period.
     * @param index The index of the competition.
     * @return The competition ID.
     */
    function getCompetitionIdWithIndex(uint256 periodId, uint index) external view returns (uint);

    /**
     * @notice Get the period details.
     * @param periodId The ID of the period.
     * @return The start time, end time, ticket buy start time, ticket buy end time, competition count on period, completion status of period, existence status of period
     */
    function getPeriod(uint256 periodId) external view returns (uint, uint, uint, uint, uint16, bool, bool);

    /**
     * @notice Get the allocation details for an account in a period and competition.
     * @param account The account address.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The allocation for the account (staking percentage, winning percentage, and existence flag).
     */
    function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (uint32, uint32, bool);

    /**
     * @notice Get the end time of a period.
     * @param periodId The ID of the period.
     * @return The end time of the period.
     */
    function getPeriodEndTime(uint256 periodId) external view returns (uint);

    /**
     * @notice Check if an account has participated in a period.
     * @param account_ The account address.
     * @param periodId_ The ID of the period.
     * @return A boolean indicating whether the account has participated.
     */
    function hasParticipation(address account_, uint256 periodId_) external view returns (bool);

    /**
     * @notice Check if competition settings are defined for a period and competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return A boolean indicating whether the competition settings are defined.
     */
    function isCompetitionSettingsDefined(uint256 periodId, uint256 competitionId) external view returns (bool);

    /**
     * @notice Get the competition address and pause flag for a period and competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The competition address and pause flag.
     */
    function getPeriodCompetition(uint256 periodId, uint16 competitionId) external view returns (address, bool);

    /**
     * @notice Get the count of competitions for a period.
     * @param periodId The ID of the period.
     * @return The count of competitions.
     */
    function getPeriodCompetitionCount(uint256 periodId) external view returns (uint);

    /**
     * @notice Pause the ticket transfer of competition
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     */
    function pauseCompetitionTransfer(uint256 periodId, uint16 competitionId) external;

    /**
     * @notice Unpause the ticket transfer of competition
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     */
    function unpauseCompetitionTransfer(uint256 periodId, uint16 competitionId) external;

    /**
     * @notice Set the ticket base URI for a competition.
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @param baseUri_ The base URI to set.
     */
    function setCompetitionBaseURI(uint256 periodId, uint16 competitionId, string memory baseUri_) external;

    /**
     * @notice Get the total sold ticket count for a competition
     * @param periodId The ID of the period.
     * @param competitionId The ID of the competition.
     * @return The total supply of competitions.
     */
    function totalSupplyOfCompetition(uint256 periodId, uint16 competitionId) external view returns (uint256);
}
