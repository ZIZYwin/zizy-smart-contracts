import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const PROXY = "0xc3e53F4d16Ae77Db1c982e75a937B9f60FE63690";

  const TicketDeployer = await ethers.getContractFactory("TicketDeployer");
  console.log(`Upgrading ticket deployer contract...`);

  await upgrades.upgradeProxy(PROXY, TicketDeployer);
  console.log(`Ticket deployer contract is upgraded !`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
