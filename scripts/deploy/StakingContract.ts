import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const signers = await ethers.getSigners();

  const signerAccount = signers[2];
  console.log(`Signer account : ${signerAccount.address}`);

  const zizyTokenContract = "0xbdEd0D2bf404bdcBa897a74E6657f1f12e5C6fb6";
  const feeReceiver = process.env.FEE_RECEIVER || "";

  // We get the contract to deploy
  const ZizyCompetitionStaking = await ethers.getContractFactory("ZizyCompetitionStaking", {
    signer: signerAccount
  });

  // Deploy the contract
  const ZizyCompetitionStakingContract = await upgrades.deployProxy(ZizyCompetitionStaking, [zizyTokenContract, feeReceiver], {
    initializer: "initialize"
  });

  // Wait contract deploy process for complete
  await ZizyCompetitionStakingContract.deployed();

  console.log("Staking contract deployed to:", ZizyCompetitionStakingContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
