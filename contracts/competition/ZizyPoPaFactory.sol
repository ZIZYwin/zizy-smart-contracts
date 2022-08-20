// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./ICompetitionFactory.sol";
import "./IZizyPoPa.sol";
import "./ZizyPoPa.sol";

// @dev Zizy - PoPa Factory
contract ZizyPoPaFactory is OwnableUpgradeable {
    event PopaClaimed(address indexed claimer, uint256 periodId);
    event PopaDeployed(address contractAddress, uint256 periodId);
    event AllocationPercentageUpdated(uint percentage);

    address[] private _popas;
    uint256 private popaCounter;

    // Period popa nft's [periodId > PoPa contract]
    mapping(uint256 => address) private _periodPopas;

    // Popa claim states [Account > PeriodId > State]
    mapping(address => mapping(uint256 => bool)) private _popaClaimed;

    // Popa claim allocation percentage
    uint private _popaClaimAllocationPercentage;

    // Competition factory contract
    address public competitionFactory;

    // Initializer
    function initialize(address competitionFactory_) external initializer {
        require(competitionFactory_ != address(0), "Contract address can not be zero");
        _setCompetitionFactory(competitionFactory_);

        __Ownable_init();
        popaCounter = 0;
        _popaClaimAllocationPercentage = 10;
    }

    // Set popa claim allocation percentage
    function setPopaClaimAllocationPercentage(uint percentage) external onlyOwner {
        _setPopaClaimAllocationPercentage(percentage);
    }

    // Set popa claim allocation percentage
    function _setPopaClaimAllocationPercentage(uint percentage) internal {
        require(percentage >= 0 && percentage <= 100, "Allocation percentage should between 0-100");
        _popaClaimAllocationPercentage = percentage;
        emit AllocationPercentageUpdated(percentage);
    }

    // Is popa claimed ?
    function popaClaimed(address account, uint256 periodId) external view returns (bool) {
        return _popaClaimed[account][periodId];
    }

    // Get period popa nft contract address
    function getPopaContract(uint256 periodId) external view returns (address) {
        return _periodPopas[periodId];
    }

    // Get period popa nft contract address with index
    function getPopaContractWithIndex(uint index) external view returns (address) {
        require(index < _popas.length, "Out of index");
        return _popas[index];
    }

    // Set competition factory
    function _setCompetitionFactory(address competitionFactory_) internal {
        require(competitionFactory_ != address(0), "Competition factory cant be zero address");
        competitionFactory = competitionFactory_;
    }

    // Set competition factory
    function setCompetitionFactory(address competitionFactory_) external onlyOwner {
        _setCompetitionFactory(competitionFactory_);
    }

    // Deploy new PoPa NFT contract
    function deploy(string memory name_, string memory symbol_, uint256 periodId_) external onlyOwner returns (uint256, address) {
        uint256 index = popaCounter;

        require(_periodPopas[periodId_] == address(0), "Period popa already deployed");

        ZizyPoPa popa = new ZizyPoPa(name_, symbol_, address(this));
        address contractAddress = address(popa);
        popa.transferOwnership(owner());
        _popas.push(address(popa));

        _periodPopas[periodId_] = address(popa);

        popaCounter++;

        emit PopaDeployed(contractAddress, periodId_);
        return (index, address(popa));
    }

    // Claim PoPa NFT
    function claim(uint256 periodId_) external {
        address popaContract = _periodPopas[periodId_];
        require(popaContract != address(0), "Unknown period id");

        require(_popaClaimed[_msgSender()][periodId_] == false, "You already claimed this popa nft");

        bool canClaim = _claimableCheck(_msgSender(), periodId_);
        require(canClaim == true, "Claim conditions not met");

        IZizyPoPa popa = IZizyPoPa(popaContract);

        _popaClaimed[_msgSender()][periodId_] = true;
        popa.mint(_msgSender());
        emit PopaClaimed(_msgSender(), periodId_);
    }

    // Get participation percentage condition
    function allocationPercentage() external view returns (uint) {
        return _popaClaimAllocationPercentage;
    }

    // User popa claim conditions check
    function claimableCheck(address account, uint256 periodId) external view returns (bool) {
        return _claimableCheck(account, periodId);
    }

    // User popa claim conditions check
    function _claimableCheck(address account, uint256 periodId) internal view returns (bool) {
        // User already claimed PoPa
        if (_popaClaimed[account][periodId] == true) {
            return false;
        }

        uint percentage = _popaClaimAllocationPercentage;
        ICompetitionFactory factory = ICompetitionFactory(competitionFactory);

        // Check period participation
        if (factory.hasParticipation(account, periodId) == false) {
            return false;
        }

        // If allocation percentage condition is zero, account can claim the PoPa
        if (percentage == 0) {
            return true;
        }

        uint periodCompCount = factory.getPeriodCompetitionCount(periodId);
        for (uint i = 0; i < periodCompCount; ++i) {
            uint compId = factory.getCompetitionIdWithIndex(periodId, i);
            (uint32 bought, uint32 max, bool hasAlloc) = factory.getAllocation(account, periodId, compId);

            // User hasn't participated all competitions
            if (hasAlloc == false || bought == 0) {
                return false;
            }

            // User didn't bought enough ticket for competition
            if (bought < ((max * percentage) / 100)) {
                return false;
            }
        }

        return true;
    }

    // Get deployed contract count
    function getDeployedContractCount() external view returns (uint256) {
        return popaCounter;
    }
}
