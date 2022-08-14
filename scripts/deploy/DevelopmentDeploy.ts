import { ethers } from "hardhat";
import * as hre from "hardhat";

const { upgrades } = require("hardhat");

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const ZizyToken = await ethers.getContractFactory("ZizyERC20");
  const zizyTokenContractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
  const ZizyTokenContract = await ZizyToken.attach(zizyTokenContractAddress);

  //region Competition Factory - Deploy
  const CompetitionFactory = await ethers.getContractFactory("CompetitionFactory");
  const CompetitionFactoryContract = await upgrades.deployProxy(CompetitionFactory, [], {
    initializer: "initialize"
  });
  await CompetitionFactoryContract.deployed();
  console.log("Competition factory deployed to:", CompetitionFactoryContract.address);
  //endregion

  //region Staking Contract - Deploy
  const CompetitionStaking = await ethers.getContractFactory("ZizyCompetitionStaking");
  const StakingContract = await upgrades.deployProxy(CompetitionStaking, [zizyTokenContractAddress], {
    initializer: "initialize"
  });
  await StakingContract.deployed();
  console.log("Staking contract deployed to:", StakingContract.address);
  //endregion

  //region Ticket Deployer - Deploy
  const TicketDeployer = await ethers.getContractFactory("TicketDeployer");
  const TicketDeployerContract = await upgrades.deployProxy(TicketDeployer, [CompetitionFactoryContract.address], {
    initializer: "initialize"
  });
  await TicketDeployerContract.deployed();
  console.log("Ticket deployer contract deployed to:", TicketDeployerContract.address);
  //endregion

  //region Initial Settings for Contracts
  await StakingContract.setCompetitionFactory(CompetitionFactoryContract.address).then(() => {
    console.log(`Set competition factory call completed !`);
  });
  await CompetitionFactoryContract.setStakingContract(StakingContract.address).then(() => {
    console.log(`Set staking contract call completed !`);
  });
  await CompetitionFactoryContract.setTicketDeployer(TicketDeployerContract.address).then(() => {
    console.log(`Set ticket deployer contract call completed !`);
  });
  //endregion

  /**
   * Development Purpose
   */
  const currentDate = new Date();
  const currentTimeInSeconds = Math.floor(currentDate.getTime() / 1000);
  // Create 30days period
  await CompetitionFactoryContract.createCompetitionPeriod(currentTimeInSeconds, (currentTimeInSeconds + (86400 * 30))).then(() => {
    console.log(`Competition period #1 has created in 30 days period`);
  });

  // Approve for stake
  await ZizyTokenContract.approve(StakingContract.address, 50000_00000000).then(() => {
    console.log(`Staking contract approved with 50000_00000000`);
  });

  // await StakingContract.stake(10000_00000000).then(() => {
  //   console.log(`Staking completed with 10000_00000000 token`);
  // });

  // await CompetitionFactoryContract.createCompetitionPeriod(1656055560, 1656655560);
  // await CompetitionFactoryContract.createCompetition("Zizy Competition", "ZCMP", "Zizy car competition #0001");
  // await CompetitionFactoryContract.createCompetition("Zizy Competition", "ZCMP", "Zizy bitcoin competition #0001");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
