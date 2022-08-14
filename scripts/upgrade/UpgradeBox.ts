import { ethers, upgrades } from "hardhat";
import * as hre from "hardhat";

async function main() {
  const signers = await ethers.getSigners();

  const signerAccount = signers[0];
  console.log(`Signer account : ${signerAccount.address}`);

  // We get the contract to deploy
  const Box = await ethers.getContractFactory("TextBoxV2", {
    signer: signerAccount
  });

  const PROXY = '0xd2a3032911fec444b2837b4f7896294ece407346';

  // Deploy the contract
  const BoxContract = await upgrades.upgradeProxy(PROXY, Box);

  // Wait contract deploy process for complete
  await BoxContract.deployed();

  console.log("Box Contract upgrades to:", BoxContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
