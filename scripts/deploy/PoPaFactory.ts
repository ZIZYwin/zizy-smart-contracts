import { ethers } from "hardhat";
import * as hre from "hardhat";

const { upgrades } = require("hardhat");

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");


  const signers = await ethers.getSigners();

  const signerAccount = signers[0];
  console.log(`Signer account : ${signerAccount.address}`);

  const competitionFactoryContractAddress = "0x580607F3eBf39CB9CBb1095C48B444325F315a8D";
  const ZizyPoPaFactory = await ethers.getContractFactory("ZizyPoPaFactory", {
    signer: signerAccount
  });
  const ZizyPoPaFactoryContract = await ZizyPoPaFactory.deploy(competitionFactoryContractAddress);
  await ZizyPoPaFactoryContract.deployed();
  console.log("PoPa Factory contract deployed to:", ZizyPoPaFactoryContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
