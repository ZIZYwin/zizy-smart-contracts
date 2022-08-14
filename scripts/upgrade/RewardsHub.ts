import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const PROXY = '0x851356ae760d987E095750cCeb3bC6014560891C';

  const ZizyRewardsHub = await ethers.getContractFactory("ZizyRewardsHub");
  console.log(`Upgrading rewards-hub contract...`);

  await upgrades.upgradeProxy(PROXY, ZizyRewardsHub);
  console.log(`RewardsHub contract is upgraded !`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
