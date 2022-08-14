import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const PROXY = '0x367761085BF3C12e5DA2Df99AC6E1a824612b8fb';

  const CompetitionFactory = await ethers.getContractFactory("CompetitionFactory");
  console.log(`Upgrading competition factory contract...`);

  await upgrades.upgradeProxy(PROXY, CompetitionFactory);
  console.log(`Competition factory contract is upgraded !`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
