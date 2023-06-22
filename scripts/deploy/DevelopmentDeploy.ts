import { ethers } from "hardhat";
import * as hre from "hardhat";
import { ZizyCompetitionStaking } from "../../typechain-types";

const { upgrades } = require("hardhat");

async function sleep(milliSecond: number) {
  await new Promise((resolve) => {
    setTimeout(() => {
      resolve("ok");
    }, milliSecond);
  });
}

async function main() {
  const signers = await ethers.getSigners();
  const signerAccount = signers[0];
  const feePaymentReceiver = signers[1];
  const competitionTicketMinter = signers[2];

  const ZizyToken = await ethers.getContractFactory("ZizyERC20");
  const zizyTokenContractAddress = "0xAf3CbaeBA9fe7A7d4E7531F1B2553972FD1c4E9c";
  const ZizyTokenContract = await ZizyToken.attach(zizyTokenContractAddress);

  //region Competition Factory - Deploy
  console.log(`Pay/Fee receiver: ${feePaymentReceiver.address}`);
  console.log(`Competition ticket minter: ${competitionTicketMinter.address}`);
  const CompetitionFactory = await ethers.getContractFactory("CompetitionFactory");
  const CompetitionFactoryContract = await upgrades.deployProxy(CompetitionFactory, [feePaymentReceiver.address, competitionTicketMinter.address], {
    initializer: "initialize"
  });
  await CompetitionFactoryContract.deployed();
  console.log("Competition factory deployed to:", CompetitionFactoryContract.address);
  const CompetitionFactoryImplement = await upgrades.erc1967.getImplementationAddress(CompetitionFactoryContract.address);
  console.log("Competition factory implementation:", CompetitionFactoryImplement);
  //endregion

  await sleep(15000);

  //region Staking Contract - Deploy
  const CompetitionStaking = await ethers.getContractFactory("ZizyCompetitionStaking");
  const StakingContract = await upgrades.deployProxy(CompetitionStaking, [zizyTokenContractAddress, feePaymentReceiver.address], {
    initializer: "initialize"
  });
  await StakingContract.deployed();
  console.log("Staking contract deployed to:", StakingContract.address);
  const StakingContractImplement = await upgrades.erc1967.getImplementationAddress(StakingContract.address);
  console.log("Staking contract implementation:", StakingContractImplement);
  //endregion

  await sleep(15000);

  //region Ticket Deployer - Deploy
  const TicketDeployer = await ethers.getContractFactory("TicketDeployer");
  const TicketDeployerContract = await TicketDeployer.deploy(CompetitionFactoryContract.address);
  await TicketDeployerContract.deployed();
  console.log("Ticket deployer contract deployed to:", TicketDeployerContract.address);
  //endregion

  await sleep(15000);

  //region Initial Settings for Contracts
  await StakingContract.setCompetitionFactory(CompetitionFactoryContract.address).then(() => {
    console.log(`Set competition factory call completed !`);
  });
  await sleep(15000);
  await CompetitionFactoryContract.setStakingContract(StakingContract.address).then(() => {
    console.log(`Set staking contract call completed !`);
  });
  await sleep(15000);
  await CompetitionFactoryContract.setTicketDeployer(TicketDeployerContract.address).then(() => {
    console.log(`Set ticket deployer contract call completed !`);
  });
  //endregion

  await sleep(15000);

  //region PoPa Factory - Deploy
  const ZizyPoPaFactory = await ethers.getContractFactory("ZizyPoPaFactory");
  const ZizyPoPaFactoryContract = await upgrades.deployProxy(ZizyPoPaFactory, [CompetitionFactoryContract.address], {
    initializer: "initialize"
  });
  await ZizyPoPaFactoryContract.deployed();
  console.log("PoPa factory contract deployed to:", ZizyPoPaFactoryContract.address);
  const ZizyPoPaFactoryImplement = await upgrades.erc1967.getImplementationAddress(ZizyPoPaFactoryContract.address);
  console.log("PoPa factory implementation:", ZizyPoPaFactoryImplement);
  //endregion

  await sleep(15000);

  //region Rewards Hub - Deploy
  console.log(`Reward Definer Acc: ${signerAccount.address}`);
  const ZizyRewardsHub = await ethers.getContractFactory("ZizyRewardsHub");
  const ZizyRewardsHubContract = await upgrades.deployProxy(ZizyRewardsHub, [signerAccount.address], {
    initializer: "initialize"
  });
  await ZizyRewardsHubContract.deployed();
  console.log("Rewards Hub contract deployed to:", ZizyRewardsHubContract.address);
  const ZizyRewardsHubImplement = await upgrades.erc1967.getImplementationAddress(ZizyRewardsHubContract.address);
  console.log("Rewards Hub implementation:", ZizyRewardsHubImplement);
  //endregion

  await sleep(15000);

  //region Stake Rewards - Deploy
  const StakeRewards = await ethers.getContractFactory("StakeRewards");
  const StakeRewardsContract = await upgrades.deployProxy(StakeRewards, ['0x90b91c109a3D5D4845c5CD454b19d8Febbe0B191', signerAccount.address], {
    initializer: "initialize"
  });
  await StakeRewardsContract.deployed();
  console.log("Stake rewards contract deployed to:", StakeRewardsContract.address);
  const StakeRewardsImplement = await upgrades.erc1967.getImplementationAddress(StakeRewardsContract.address);
  console.log("Stake rewards implementation:", StakeRewardsImplement);
  //endregion

  console.log(`>>> ZIZY Deployment Done ! <<<`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
