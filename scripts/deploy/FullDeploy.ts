import { ethers } from "hardhat";
import * as hre from "hardhat";

const { upgrades } = require("hardhat");

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const rewardsDefiner = '0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc';
  const ticketMinter = '0x70997970c51812dc3a010c7d01b50e0d17dc79c8';
  const paymentReceiver = '0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc';
  const feeReceiver = '0x90f79bf6eb2c4f870365e785982e1f101e93b906';

  const ZizyToken = await ethers.getContractFactory("ZizyERC20");
  const zizyTokenContractAddress = '0xc5a5C42992dECbae36851359345FE25997F5C42d';
  const ZizyTokenContract = await ZizyToken.attach(zizyTokenContractAddress);

  //region Competition Factory - Deploy
  const CompetitionFactory = await ethers.getContractFactory("CompetitionFactory");
  const CompetitionFactoryContract = await upgrades.deployProxy(CompetitionFactory, [paymentReceiver, ticketMinter], {
    initializer: "initialize"
  });
  await CompetitionFactoryContract.deployed();
  console.log("Competition factory deployed to:", CompetitionFactoryContract.address);
  //endregion

  //region Staking Contract - Deploy
  const CompetitionStaking = await ethers.getContractFactory("ZizyCompetitionStaking");
  const StakingContract = await upgrades.deployProxy(CompetitionStaking, [zizyTokenContractAddress, feeReceiver], {
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

  //region Zizy PoPa Factory - Deploy
  const ZizyPoPaFactory = await ethers.getContractFactory("ZizyPoPaFactory");
  const ZizyPoPaFactoryContract = await ZizyPoPaFactory.deploy(CompetitionFactoryContract.address);
  await ZizyPoPaFactoryContract.deployed();
  console.log("Zizy PoPa Factory contract deployed to:", ZizyPoPaFactoryContract.address);
  //endregion

  //region Rewards Hub - Deploy
  const ZizyRewardsHub = await ethers.getContractFactory("ZizyRewardsHub");
  const ZizyRewardsHubContract = await upgrades.deployProxy(ZizyRewardsHub, [rewardsDefiner], {
    initializer: "initialize"
  });
  await ZizyRewardsHubContract.deployed();
  console.log("RewardsHub contract deployed to:", ZizyRewardsHubContract.address);
  //endregion





  /**
   * Development Purpose
   */

  // const ERC20Def = await ethers.getContractFactory("ERC20Def");
  // const usdtz = await ERC20Def.deploy("USDT.z", "USDT Z");
  // await usdtz.deployed();
  // console.log(`USDT.z Deployed to: ${usdtz.address}`);
  //
  // // Approve for stake
  // await ZizyTokenContract.approve(StakingContract.address, 50000_00000000).then(() => {
  //   console.log(`Staking contract approved with 50000_00000000`);
  // });
  //
  //
  // const currentDate = new Date();
  // const cT = Math.floor(currentDate.getTime() / 1000);
  // const hour = 60 * 60;
  // const pD = {
  //   start: cT,
  //   end: (cT + (hour * 4)),
  //   ticketStart: (cT + hour),
  //   ticketEnd: (cT + (hour * 2)),
  // };
  // // Create 4 hour period
  // await CompetitionFactoryContract.createCompetitionPeriod(pD.start, pD.end, pD.ticketStart, pD.ticketEnd).then(() => {
  //   console.log(`Competition period #1 has created in 4 hour period`);
  // });
  //
  // await CompetitionFactoryContract.createCompetition("Zizy Competition", "ZCMP", "Zizy bitcoin competition #0001");
  //
  // // Stake
  // await StakingContract.stake(10000_00000000);
  // await StakingContract.snapshot(); // #2
  // await StakingContract.stake(5000_00000000);
  // await StakingContract.snapshot(); // #3
  // await StakingContract.snapshot(); // #4
  // await StakingContract.unStake(10000_00000000);
  // await StakingContract.snapshot(); // #5
  //
  // await CompetitionFactoryContract.setCompetitionPayment(1, 1, usdtz.address, 25_00000000); // Set Payment for ticket
  // await CompetitionFactoryContract.setCompetitionSnapshotRange(1, 1, 1, 5); // Set snapshot range for competition
  // await CompetitionFactoryContract.setCompetitionTiers(1, 1,
  //   [1000_00000000, 5001_00000000, 10001_00000000],
  //   [5000_00000000, 10000_00000000, 25000_00000000],
  //   [5, 10, 25]
  // ); // Set competition tiers
  //
  // // Update for ticket buy stage
  // await CompetitionFactoryContract.updateCompetitionPeriod(1, pD.start, pD.end, (pD.start+1), (pD.end-1));
  //
  // await usdtz.approve(CompetitionFactoryContract.address, 50000_00000000); // Approve for ticket buy


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
