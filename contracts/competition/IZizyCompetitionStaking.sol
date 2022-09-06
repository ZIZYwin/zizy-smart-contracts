// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IZizyCompetitionStaking {
    function getSnapshotAverage(address account, uint256 min, uint256 max) external view returns (uint);
    function getPeriodSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool);
    function getPeriodStakeAverage(address account, uint256 periodId) external view returns (uint256, bool);
    function getPeriodSnapshotRange(uint256 periodId) external view returns (uint, uint);
    function setPeriodId(uint256 period) external returns (uint256);
    function getSnapshotId() external view returns (uint256);
    function stake(uint256 amount_) external;
    function balanceOf(address account) external view returns (uint256);
    function getPeriod(uint256 periodId_) external view returns (uint, uint, uint, uint, uint16, bool);
    function unStake(uint256 amount_) external;
}
