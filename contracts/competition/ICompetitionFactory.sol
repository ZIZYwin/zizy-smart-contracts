// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ICompetitionFactory {
    function totalPeriodCount() external view returns (uint);
    function totalCompetitionCount() external view returns (uint);
    function createCompetitionPeriod(uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external returns (uint256);
    function updateCompetitionPeriod(uint periodId_, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external returns (bool);
    function getPeriod(uint256 periodNum) external view returns (uint, uint, uint, uint, uint16, bool);
    function getAllocation(address account, uint256 periodId, uint16 competitionId) external view returns (uint32, uint32, bool);
    function getPeriodEndTime(uint256 periodNum) external view returns (uint);
    function hasParticipation(address account_, uint256 periodId_) external view returns (bool);
    function getPeriodCompetition(uint256 periodNum, uint16 competitionNum) external view returns (address, bool);
    function getPeriodCompetitionCount(uint256 periodNum) external view returns (uint);
    function pauseCompetitionTransfer(uint256 periodNum, uint16 competitionNum) external;
    function unpauseCompetitionTransfer(uint256 periodNum, uint16 competitionNum) external;
    function setCompetitionBaseURI(uint256 periodNum, uint16 competitionNum, string memory baseUri_) external;
    function setCompetitionDescription(uint256 periodNum, uint16 competitionNum, string memory description_) external;
    function totalSupplyOfCompetition(uint256 periodNum, uint16 competitionNum) external view returns (uint256);
}
