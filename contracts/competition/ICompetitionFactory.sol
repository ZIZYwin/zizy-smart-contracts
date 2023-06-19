// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ICompetitionFactory {
    function totalPeriodCount() external view returns (uint);
    function totalCompetitionCount() external view returns (uint);
    function createCompetitionPeriod(uint newPeriodId, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external returns (uint256);
    function updateCompetitionPeriod(uint periodId_, uint startTime_, uint endTime_, uint ticketBuyStart_, uint ticketBuyEnd_) external returns (bool);
    function getCompetitionIdWithIndex(uint256 periodId, uint index) external view returns (uint);
    function getPeriod(uint256 periodId) external view returns (uint, uint, uint, uint, uint16, bool, bool);
    function getAllocation(address account, uint256 periodId, uint256 competitionId) external view returns (uint32, uint32, bool);
    function getPeriodEndTime(uint256 periodId) external view returns (uint);
    function hasParticipation(address account_, uint256 periodId_) external view returns (bool);
    function isCompetitionSettingsDefined(uint256 periodId, uint256 competitionId) external view returns (bool);
    function getPeriodCompetition(uint256 periodId, uint16 competitionId) external view returns (address, bool);
    function getPeriodCompetitionCount(uint256 periodId) external view returns (uint);
    function pauseCompetitionTransfer(uint256 periodId, uint16 competitionId) external;
    function unpauseCompetitionTransfer(uint256 periodId, uint16 competitionId) external;
    function setCompetitionBaseURI(uint256 periodId, uint16 competitionId, string memory baseUri_) external;
    function setCompetitionDescription(uint256 periodId, uint16 competitionId, string memory description_) external;
    function totalSupplyOfCompetition(uint256 periodId, uint16 competitionId) external view returns (uint256);
}
