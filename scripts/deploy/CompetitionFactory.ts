import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const signers = await ethers.getSigners();

  const signerAccount = signers[1];
  console.log(`Signer account : ${signerAccount.address}`);

  const paymentReceiver = process.env.PAYMENT_RECEIVER || "";
  const minter = process.env.TICKET_MINTER || "";

  // We get the contract to deploy
  const CompetitionFactory = await ethers.getContractFactory("CompetitionFactory", {
    signer: signerAccount
  });

  // Deploy the contract
  const CompetitionFactoryContract = await upgrades.deployProxy(CompetitionFactory, [paymentReceiver, minter], {
    initializer: "initialize"
  });

  // Wait contract deploy process for complete
  await CompetitionFactoryContract.deployed();

  console.log("Competition factory deployed to:", CompetitionFactoryContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
