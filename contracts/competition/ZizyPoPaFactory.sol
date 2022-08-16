// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICompetitionFactory.sol";
import "./IZizyPoPa.sol";
import "./ZizyPoPa.sol";

// @dev Zizy - PoPa Factory
contract ZizyPoPaFactory is Ownable {
    event PopaClaimed(address indexed claimer, uint256 periodId);
    event PopaDeployed(address contractAddress, uint256 periodId);

    address[] private _popas;
    uint256 private popaCounter = 0;

    // Period popa nft's [periodId > PoPa contract]
    mapping(uint256 => address) private _periodPopas;

    // Popa claim states [Account > PeriodId > State]
    mapping(address => mapping(uint256 => bool)) private _popaClaimed;

    // Competition factory contract
    address public competitionFactory;

    constructor(address competitionFactory_) {
        _setCompetitionFactory(competitionFactory_);
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

        emit PopaDeployed(contractAddress, periodId);
        return (index, address(popa));
    }

    // Claim PoPa NFT
    function claim(uint256 periodId_) external {
        address popaContract = _periodPopas[periodId_];
        require(popaContract != address(0), "Unknown period id");

        require(_popaClaimed[msg.sender][periodId_] == false, "You already claimed this popa nft");

        ICompetitionFactory factory = ICompetitionFactory(competitionFactory);

        require(factory.hasParticipation(msg.sender, periodId_) == true, "You hasn't participation for this period");

        IZizyPoPa popa = IZizyPoPa(popaContract);

        _popaClaimed[msg.sender][periodId_] = true;
        popa.mint(msg.sender);
        emit PopaClaimed(msg.sender, periodId_);
    }

    // Get deployed contract count
    function getDeployedContractCount() external view returns (uint256) {
        return popaCounter;
    }
}
