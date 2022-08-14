import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const signers = await ethers.getSigners();

  const signerAccount = signers[0];
  console.log(`Signer account : ${signerAccount.address}`);

  const rewardDefiner = process.env.REWARD_DEFINER || "";

  // We get the contract to deploy
  const ZizyRewardsHub = await ethers.getContractFactory("ZizyRewardsHub", {
    signer: signerAccount
  });

  // Deploy the contract
  const ZizyRewardsHubContract = await ZizyRewardsHub.deploy();
  // const ZizyRewardsHubContract = await upgrades.deployProxy(ZizyRewardsHub, [rewardDefiner], {
  //   initializer: "initialize"
  // });

  // Wait contract deploy process for complete
  await ZizyRewardsHubContract.deployed();

  console.log("RewardsHub deployed to:", ZizyRewardsHubContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
