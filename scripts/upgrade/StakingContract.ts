import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const PROXY = '0xE6E340D132b5f46d1e472DebcD681B2aBc16e57E';

  const CompetitionStaking = await ethers.getContractFactory("ZizyCompetitionStaking");
  console.log(`Upgrading staking contract...`);

  await upgrades.upgradeProxy(PROXY, CompetitionStaking);
  console.log(`Staking contract is upgraded !`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
