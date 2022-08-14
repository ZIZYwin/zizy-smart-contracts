import { ethers } from "hardhat";
import * as hre from "hardhat";

const { upgrades } = require("hardhat");

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");


  const signers = await ethers.getSigners();

  const signerAccount = signers[7];
  console.log(`Signer account : ${signerAccount.address}`);

  const competitionFactoryContractAddress = "0x2E983A1Ba5e8b38AAAeC4B440B9dDcFBf72E15d1";
  const TicketDeployer = await ethers.getContractFactory("TicketDeployer", {
    signer: signerAccount
  });
  const TicketDeployerContract = await TicketDeployer.deploy(competitionFactoryContractAddress);
  await TicketDeployerContract.deployed();
  console.log("Ticket deployer contract deployed to:", TicketDeployerContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
