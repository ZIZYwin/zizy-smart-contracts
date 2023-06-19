// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./ICompetitionFactory.sol";
import "./IZizyPoPa.sol";
import "./ZizyPoPa.sol";

// @dev Zizy - PoPa Factory
contract ZizyPoPaFactory is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    event PopaClaimed(address indexed claimer, uint256 periodId);
    event PopaMinted(address indexed claimer, uint256 periodId, uint256 tokenId);
    event PopaDeployed(address contractAddress, uint256 periodId);
    event AllocationPercentageUpdated(uint percentage);

    uint256 public claimPayment;
    address public popaMinter;

    address[] private _popas;
    uint256 private popaCounter;

    // Period popa nft's [periodId > PoPa contract]
    mapping(uint256 => address) private _periodPopas;

    // Popa claim states [Account > PeriodId > Claim State]
    mapping(address => mapping(uint256 => bool)) private _popaClaimed;

    // Popa claim mint states [Account > PeriodId > Mint State]
    mapping(address => mapping(uint256 => bool)) private _popaClaimMinted;

    // Popa claim allocation percentage
    uint private _popaClaimAllocationPercentage;

    // Competition factory contract
    address public competitionFactory;

    // Throw if caller is not minter
    modifier onlyMinter() {
        require(msg.sender == popaMinter, "Only call from minter");
        _;
    }

    // Initializer
    function initialize(address competitionFactory_) external initializer {
        require(competitionFactory_ != address(0), "Contract address can not be zero");
        _setCompetitionFactory(competitionFactory_);

        __Ownable_init();
        __ReentrancyGuard_init();
        popaCounter = 0;
        _popaClaimAllocationPercentage = 10;
        claimPayment = 0.2 ether;
        popaMinter = owner();
    }

    // Set minter account
    function setPopaMinter(address minter_) public onlyOwner {
        require(minter_ != address(0), "Minter account can not be zero");
        popaMinter = minter_;
    }

    // Set claim payment amount
    function setClaimPaymentAmount(uint256 amount_) external onlyOwner {
        claimPayment = amount_;
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

    // Set popa base uri
    function setBaseURI(uint256 periodId_, string memory baseUri_) external onlyOwner {
        address popaAddress = _periodPopas[periodId_];
        require(popaAddress != address(0), "Popa doesnt exist");

        IZizyPoPa popa = IZizyPoPa(popaAddress);
        popa.setBaseURI(baseUri_);
    }

    // Deploy new PoPa NFT contract
    function deploy(string memory name_, string memory symbol_, uint256 periodId_) external onlyOwner returns (uint256, address) {
        uint256 index = popaCounter;

        require(_periodPopas[periodId_] == address(0), "Period popa already deployed");

        ZizyPoPa popa = new ZizyPoPa(name_, symbol_, popaMinter);
        address contractAddress = address(popa);
        popa.transferOwnership(owner());
        _popas.push(address(popa));

        _periodPopas[periodId_] = address(popa);

        popaCounter++;

        emit PopaDeployed(contractAddress, periodId_);
        return (index, address(popa));
    }

    // Mint claimed PoPa
    function mintClaimedPopa(address claimer_, uint256 periodId_, uint256 tokenId_) external onlyMinter {
        address popaContract = _periodPopas[periodId_];
        require(popaContract != address(0), "Unknown period id");
        require(_popaClaimed[claimer_][periodId_] == true, "Not claimed by claimer");
        require(_popaClaimMinted[claimer_][periodId_] == false, "Already minted");

        // Set minted state
        _popaClaimMinted[claimer_][periodId_] = true;

        IZizyPoPa popa = IZizyPoPa(popaContract);
        popa.mint(claimer_, tokenId_);

        emit PopaMinted(claimer_, periodId_, tokenId_);
    }

    // Claim request for PoPa NFT
    function claim(uint256 periodId_) external payable nonReentrant {
        // Check payment limit
        if (msg.value < claimPayment) {
            revert("Insufficient claim payment");
        }

        address popaContract = _periodPopas[periodId_];
        if (popaContract == address(0)) {
            revert("Unknown period id");
        }
        if (_popaClaimed[_msgSender()][periodId_] == true) {
            revert("You already claimed this popa nft");
        }

        bool canClaim = _claimableCheck(_msgSender(), periodId_);
        if (canClaim == false) {
            revert("Claim conditions not met");
        }

        // Transfer claim payment to minter
        (bool success,) = popaMinter.call{value : msg.value}("");
        if (success == false) {
            revert("Transfer failed");
        }

        _popaClaimed[_msgSender()][periodId_] = true;
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

            // Continue if competition ticket buy settings isn't defined
            if (factory.isCompetitionSettingsDefined(periodId, compId) == false) {
                continue;
            }

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
