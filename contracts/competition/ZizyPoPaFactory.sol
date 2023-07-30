// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./ICompetitionFactory.sol";
import "./IZizyPoPa.sol";
import "./ZizyPoPa.sol";

/**
 * @title Zizy - PoPa Factory contract
 * @notice This contract is the factory contract for Zizy PoPa (Proof of Participation) NFTs.
 * It allows the deployment of PoPa NFT contracts for different periods and manages the claiming and minting of PoPa NFTs.
 * It also handles the allocation conditions for claiming PoPa NFTs based on participation in competitions.
 *
 * @dev This contract is based on the OpenZeppelin Upgradeable Contracts and implements the Ownable and ReentrancyGuard modules.
 * It interacts with the CompetitionFactory and ZizyPoPa contracts.
 *
 */
contract ZizyPoPaFactory is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    /**
     * @dev Emitted when a PoPa NFT is claimed by an account for a specific period.
     * @param claimer The account that claimed the PoPa NFT.
     * @param periodId The period ID associated with the PoPa NFT.
     */
    event PopaClaimed(address indexed claimer, uint256 periodId);

    /**
     * @dev Emitted when a PoPa NFT is minted for an account for a specific period.
     * @param claimer The account for which the PoPa NFT was minted.
     * @param periodId The period ID associated with the PoPa NFT.
     * @param tokenId The token ID of the minted PoPa NFT.
     */
    event PopaMinted(address indexed claimer, uint256 periodId, uint256 tokenId);

    /**
     * @dev Emitted when a PoPa contract is deployed for a specific period.
     * @param contractAddress The address of the deployed PoPa contract.
     * @param periodId The period ID associated with the PoPa contract.
     */
    event PopaDeployed(address contractAddress, uint256 periodId);

    /**
     * @dev Emitted when the allocation percentage for PoPa claims is updated.
     * @param percentage The new allocation percentage value.
     */
    event AllocationPercentageUpdated(uint percentage);

    /// @notice PoPA Claim payment amount (PoPA mint cost for network fee)
    uint256 public claimPayment;

    /// @notice PoPA Minter account/contract
    address public popaMinter;

    /// @notice PoPA contract address storage
    address[] private _popas;

    /// @notice Deployed PoPA counter
    uint256 private popaCounter;

    // @dev Mapping for period PoPA nft's: [periodId > PoPA Address]
    mapping(uint256 => address) private _periodPopas;

    // @dev Mapping for PoPA claim states: [Account > PeriodId > Claim State]
    mapping(address => mapping(uint256 => bool)) private _popaClaimed;

    // @dev Mapping for PoPA claim mint states: [Account > PeriodId > Mint State]
    mapping(address => mapping(uint256 => bool)) private _popaClaimMinted;

    // @dev Required percentage of participation in competitions for PoPA claim
    uint private _popaClaimAllocationPercentage;

    // @notice Competition factory contract address
    address public competitionFactory;

    /**
     * @dev Throws an error if the caller is not the minter.
     */
    modifier onlyMinter() {
        require(msg.sender == popaMinter, "Only call from minter");
        _;
    }

    /**
     * @dev Constructor function
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract
     * @param competitionFactory_ The address of the CompetitionFactory contract
     *
     * @dev It sets the competitionFactory address, initializes the Ownable and ReentrancyGuard contracts,
     * sets the initial values for popaCounter, _popaClaimAllocationPercentage, claimPayment, and popaMinter.
     */
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

    /**
     * @notice Sets the minter account
     * @param minter_ The address of the minter account
     *
     * @dev Only the owner of the contract can call this function.
     * It sets the popaMinter address to the specified minter_ address.
     * @dev Throws an error if the minter_ address is zero.
     */
    function setPopaMinter(address minter_) public onlyOwner {
        require(minter_ != address(0), "Minter account can not be zero");
        popaMinter = minter_;
    }

    /**
     * @notice Sets the PoPA claim payment amount
     * @param amount_ The amount of the claim payment
     *
     * @dev Only the owner of the contract can call this function.
     * It sets the claimPayment variable to the specified amount_.
     */
    function setClaimPaymentAmount(uint256 amount_) external onlyOwner {
        claimPayment = amount_;
    }

    /**
     * @notice Sets the required allocation percentage for PoPA claim
     * @param percentage The allocation percentage to be set
     *
     * @dev Only the owner of the contract can call this function.
     * It sets the _popaClaimAllocationPercentage variable to the specified percentage.
     * Emits an AllocationPercentageUpdated event with the updated percentage.
     * @dev Throws an error if the percentage is not between 0 and 100.
     */
    function setPopaClaimAllocationPercentage(uint percentage) external onlyOwner {
        _setPopaClaimAllocationPercentage(percentage);
    }

    /**
     * @notice Internal function to set the PoPA claim allocation percentage
     * @param percentage The allocation percentage to be set
     *
     * @dev It sets the _popaClaimAllocationPercentage variable to the specified percentage.
     * Emits an AllocationPercentageUpdated event with the updated percentage.
     * @dev Throws an error if the percentage is not between 0 and 100.
     */
    function _setPopaClaimAllocationPercentage(uint percentage) internal {
        require(percentage >= 0 && percentage <= 100, "Allocation percentage should between 0-100");
        _popaClaimAllocationPercentage = percentage;
        emit AllocationPercentageUpdated(percentage);
    }

    /**
     * @notice Checks if a specific PoPA has been claimed
     * @param account The account to check the claim status for
     * @param periodId The period ID of the PoPA
     * @return A boolean indicating whether the PoPA has been claimed or not
     *
     * @dev This function is callable by any external account.
     * It returns the claim status of the specified PoPA for the given account.
     */
    function popaClaimed(address account, uint256 periodId) external view returns (bool) {
        return _popaClaimed[account][periodId];
    }

    /**
     * @notice Checks if a claimed PoPA has been minted from system
     * @param account The account to check the mint status for
     * @param periodId The period ID of the PoPA
     * @return A boolean indicating whether the PoPA has been claimed or not
     *
     * @dev This function is callable by any external account.
     * It returns the mint status of the specified PoPA for the given account.
     */
    function popaMinted(address account, uint256 periodId) external view returns (bool) {
        return _popaClaimMinted[account][periodId];
    }

    /**
     * @notice Gets the contract address of the PoPA NFT for a specific period ID
     * @param periodId The period ID of the PoPA
     * @return The contract address of the PoPA NFT for the given period ID
     *
     * @dev This function is callable by any external account.
     * It returns the contract address of the PoPA NFT associated with the specified period ID.
     */
    function getPopaContract(uint256 periodId) external view returns (address) {
        return _periodPopas[periodId];
    }

    /**
     * @notice Gets the contract address of the PoPA NFT with the specified index
     * @param index The index of the PoPA NFT contract
     * @return The contract address of the PoPA NFT with the given index
     *
     * @dev This function is callable by any external account.
     * It returns the contract address of the PoPA NFT at the specified index in the `_popas` array.
     */
    function getPopaContractWithIndex(uint index) external view returns (address) {
        require(index < _popas.length, "Out of index");
        return _popas[index];
    }

    /**
     * @notice Sets the competition factory contract address
     * @param competitionFactory_ The address of the competition factory contract
     *
     * @dev It sets the competition factory contract address to the specified address.
     */
    function _setCompetitionFactory(address competitionFactory_) internal {
        require(competitionFactory_ != address(0), "Competition factory cant be zero address");
        competitionFactory = competitionFactory_;
    }

    /**
     * @notice Sets the competition factory contract address
     * @param competitionFactory_ The address of the competition factory contract
     *
     * @dev This function can only be called by the contract owner.
     * It sets the competition factory contract address to the specified address.
     */
    function setCompetitionFactory(address competitionFactory_) external onlyOwner {
        _setCompetitionFactory(competitionFactory_);
    }

    /**
     * @notice Sets the base URI for a specific period's PoPa NFTs
     * @param periodId_ The ID of the period
     * @param baseUri_ The base URI to be set
     *
     * @dev This function can only be called by the contract owner.
     * It sets the base URI for the PoPa NFTs of the specified period.
     * The PoPa NFT contract address is fetched based on the period ID,
     * and then the `setBaseURI` function is called on the PoPa contract
     * to set the base URI to the specified value.
     * Throws an error if the PoPa contract does not exist for the given period ID.
     */
    function setBaseURI(uint256 periodId_, string memory baseUri_) external onlyOwner {
        address popaAddress = _periodPopas[periodId_];
        require(popaAddress != address(0), "Popa doesnt exist");

        IZizyPoPa popa = IZizyPoPa(popaAddress);
        popa.setBaseURI(baseUri_);
    }

    /**
     * @notice Deploys a new PoPa NFT contract
     * @param name_ The name of the PoPa NFT contract
     * @param symbol_ The symbol of the PoPa NFT contract
     * @param periodId_ The ID of the period for which the PoPa NFT contract is deployed
     * @return index The index of the newly deployed PoPa contract in the internal array
     * @return contractAddress The address of the newly deployed PoPa contract
     *
     * @dev This function can only be called by the contract owner.
     * It deploys a new PoPa NFT contract with the specified name, symbol, and minter address.
     * The newly deployed PoPa contract is assigned an index in the internal array, and the period ID is mapped to its address.
     * The ownership of the PoPa contract is transferred to the contract owner.
     * Emits a `PopaDeployed` event with the contract address and period ID.
     * Throws an error if a PoPa contract has already been deployed for the specified period ID.
     */
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

    /**
     * @notice Mints a claimed PoPa NFT
     * @param claimer_ The address of the claimer
     * @param periodId_ The ID of the period for which the PoPa NFT is claimed
     * @param tokenId_ The ID of the PoPa NFT to mint
     *
     * @dev This function can only be called by the minter.
     * It mints a PoPa NFT for the specified claimer and period ID, with the specified token ID.
     * The PoPa NFT must have been claimed by the claimer for the specified period ID, and it must not have been already minted.
     * The minted state is set to true for the claimed PoPa.
     * Emits a `PopaMinted` event with the claimer's address, period ID, and token ID.
     * Throws an error if the period ID is unknown, the PoPa NFT is not claimed by the claimer, or it has already been minted.
     */
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

    /**
     * @notice Claims a PoPa NFT for the specified period ID
     * @param periodId_ The ID of the period for which to claim the PoPa NFT
     *
     * @dev This function allows users to claim a PoPa NFT for the specified period ID by sending the required claim payment.
     * The claim payment must be equal to or greater than the configured claim payment amount.
     * The period ID must be valid and the caller must not have already claimed the PoPa NFT for the specified period ID.
     * The caller must also meet the claim conditions as determined by the internal `_claimableCheck` function.
     * If the claim payment transfer to the minter fails, an error is thrown.
     * Sets the claim state for the caller and period ID to true.
     * Emits a `PopaClaimed` event with the caller's address and period ID.
     * Throws an error if the claim payment is insufficient, the period ID is unknown, the caller has already claimed the PoPa NFT,
     * or the claim conditions are not met.
     */
    function claim(uint256 periodId_) external payable nonReentrant {
        // Check payment limits
        if (msg.value < claimPayment) {
            revert("Insufficient claim payment");
        }
        if (msg.value > claimPayment) {
            revert("Overpayment. Please reduce your payment amount");
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

    /**
     * @notice Gets the participation percentage condition for claiming a PoPa NFT
     * @return The allocation percentage required for claiming a PoPa NFT
     *
     * @dev This function returns the allocation percentage required for claiming a PoPa NFT.
     * The allocation percentage determines the minimum percentage of competitions in which the caller must have participated
     * in order to be eligible to claim a PoPa NFT.
     */
    function allocationPercentage() external view returns (uint) {
        return _popaClaimAllocationPercentage;
    }

    /**
     * @notice Checks if an account is eligible to claim a PoPa NFT for a specific period
     * @param account The account address to check
     * @param periodId The ID of the period to check
     * @return A boolean indicating whether the account is eligible to claim a PoPa NFT
     *
     * @dev This function checks if the specified account is eligible to claim a PoPa NFT for the given period.
     * The account must meet the following conditions:
     * 1. The account has not already claimed a PoPa NFT for the period.
     * 2. The account has participated in all competitions of the period, according to the allocation settings.
     * 3. If the allocation percentage condition is non-zero, the account must have bought enough tickets
     *    in each competition to meet the allocation percentage requirement.
     */
    function claimableCheck(address account, uint256 periodId) external view returns (bool) {
        return _claimableCheck(account, periodId);
    }

    /**
     * @notice Checks if an account is eligible to claim a PoPa NFT for a specific period
     * @param account The account address to check
     * @param periodId The ID of the period to check
     * @return A boolean indicating whether the account is eligible to claim a PoPa NFT
     *
     * @dev This internal function checks if the specified account is eligible to claim a PoPa NFT for the given period.
     * The account must meet the conditions described in the @notice of the `claimableCheck` function.
     */
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

    /**
     * @notice Get the count of deployed PoPa NFT contracts
     * @return The number of deployed PoPa NFT contracts
     */
    function getDeployedContractCount() external view returns (uint256) {
        return popaCounter;
    }
}
