import { ethers } from "hardhat";
import * as hre from "hardhat";

const { upgrades } = require("hardhat");

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const signers = await ethers.getSigners();
  const signerAccount = signers[0];
  const feePaymentReceiverMinter = signers[1];

  const ZizyToken = await ethers.getContractFactory("ZizyERC20");
  const zizyTokenContractAddress = "0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE";
  const ZizyTokenContract = await ZizyToken.attach(zizyTokenContractAddress);

  //region Competition Factory - Deploy
  console.log(`Pay/Fee receiver & Minter: ${feePaymentReceiverMinter.address}`);
  const CompetitionFactory = await ethers.getContractFactory("CompetitionFactory");
  const CompetitionFactoryContract = await upgrades.deployProxy(CompetitionFactory, [feePaymentReceiverMinter.address, feePaymentReceiverMinter.address], {
    initializer: "initialize"
  });
  await CompetitionFactoryContract.deployed();
  console.log("Competition factory deployed to:", CompetitionFactoryContract.address);
  //endregion

  //region Staking Contract - Deploy
  const CompetitionStaking = await ethers.getContractFactory("ZizyCompetitionStaking");
  const StakingContract = await upgrades.deployProxy(CompetitionStaking, [zizyTokenContractAddress, feePaymentReceiverMinter.address], {
    initializer: "initialize"
  });
  await StakingContract.deployed();
  console.log("Staking contract deployed to:", StakingContract.address);
  //endregion

  //region Ticket Deployer - Deploy
  const TicketDeployer = await ethers.getContractFactory("TicketDeployer");
  const TicketDeployerContract = await TicketDeployer.deploy(CompetitionFactoryContract.address);
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

  //region PoPa Factory - Deploy
  const ZizyPoPaFactory = await ethers.getContractFactory("ZizyPoPaFactory");
  const ZizyPoPaFactoryContract = await upgrades.deployProxy(ZizyPoPaFactory, [CompetitionFactoryContract.address], {
    initializer: "initialize"
  });
  await ZizyPoPaFactoryContract.deployed();
  console.log("PoPa factory contract deployed to:", ZizyPoPaFactoryContract.address);
  //endregion

  //region Rewards Hub - Deploy
  console.log(`Reward Definer Acc: ${signerAccount.address}`);
  const ZizyRewardsHub = await ethers.getContractFactory("ZizyRewardsHub");
  const ZizyRewardsHubContract = await upgrades.deployProxy(ZizyRewardsHub, [signerAccount.address], {
    initializer: "initialize"
  });
  await ZizyRewardsHubContract.deployed();
  console.log("Rewards Hub contract deployed to:", ZizyRewardsHubContract.address);
  //endregion

  /**
   * Development Purpose
   */

  // Approve for stake
  await ZizyTokenContract.approve(StakingContract.address, 50000_00000000).then(() => {
    console.log(`Staking contract approved with 50000_00000000`);
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
