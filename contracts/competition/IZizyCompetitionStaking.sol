// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @title ZizyCompetitionStaking Interface
 * @notice This interface represents the ZizyCompetitionStaking contract.
 * @dev This interface defines the functions of the ZizyCompetitionStaking contract.
 */
interface IZizyCompetitionStaking {

    /// @notice Struct for stake snapshots
    struct Snapshot {
        uint256 balance;
        uint256 prevSnapshotBalance;
        bool _exist;
    }

    /// @notice Struct for period & snapshot range
    struct Period {
        uint256 firstSnapshotId;
        uint256 lastSnapshotId;
        bool isOver;
        bool _exist;
    }

    /// @notice Struct for account activity details
    struct ActivityDetails {
        uint256 lastSnapshotId;
        uint256 lastActivityBalance;
        bool _exist;
    }

    /// @notice Struct for period stake average
    struct PeriodStakeAverage {
        uint256 average;
        bool _calculated;
    }

    /**
     * @notice Get the average stake amount for an account within a specified range of snapshots.
     * @param account The address of the account.
     * @param min The minimum snapshot ID (inclusive).
     * @param max The maximum snapshot ID (inclusive).
     * @return The average stake amount for the account.
     */
    function getSnapshotAverage(address account, uint256 min, uint256 max) external view returns (uint);

    /**
     * @notice Get the average stake amount for an account within a specified range of snapshots in a particular period.
     * @param account The address of the account.
     * @param periodId The ID of the period.
     * @param min The minimum snapshot ID (inclusive).
     * @param max The maximum snapshot ID (inclusive).
     * @return The average stake amount for the account and period, and a boolean indicating if the average is calculated.
     */
    function getPeriodSnapshotsAverage(address account, uint256 periodId, uint256 min, uint256 max) external view returns (uint256, bool);

    /**
     * @notice Get the average stake amount for an account in a specific period.
     * @param account The address of the account.
     * @param periodId The ID of the period.
     * @return The average stake amount for the account and period, and a boolean indicating if the average is calculated.
     */
    function getPeriodStakeAverage(address account, uint256 periodId) external view returns (uint256, bool);

    /**
     * @notice Get the range of snapshot IDs for a specific period.
     * @param periodId The ID of the period.
     * @return The minimum and maximum snapshot IDs for the period.
     */
    function getPeriodSnapshotRange(uint256 periodId) external view returns (uint, uint);

    /**
     * @notice Set the period ID for the staking contract.
     * @param period The new period ID to set.
     * @return The new period ID.
     */
    function setPeriodId(uint256 period) external returns (uint256);

    /**
     * @notice Get the current snapshot ID.
     * @return The current snapshot ID.
     */
    function getSnapshotId() external view returns (uint256);

    /**
     * @notice Stake tokens.
     * @param amount_ The amount of tokens to stake.
     */
    function stake(uint256 amount_) external;

    /**
     * @notice Get the balance of tokens staked by an account.
     * @param account The address of the account.
     * @return The balance of tokens staked by the account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Get information about a specific period.
     * @param periodId_ The ID of the period.
     * @return The first snapshot id of period, last snapshot id of period, completion status of period, existence status of period
     */
    function getPeriod(uint256 periodId_) external view returns (Period memory);

    /**
     * @notice Un-stake tokens.
     * @param amount_ The amount of tokens to un-stake.
     */
    function unStake(uint256 amount_) external;
}
