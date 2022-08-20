import { ethers } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  const signers = await ethers.getSigners();

  const signerAccount = signers[0];
  console.log(`Signer account : ${signerAccount.address}`);

  // We get the contract to deploy
  const zizyErc20 = await ethers.getContractFactory("ZizyERC20", {
    signer: signerAccount
  });

  // Constructor arguments
  const tokenName = "ZToken";
  const tokenSymbol = "ZTK";

  // Deploy the contract
  const zizyErc20Contract = await zizyErc20.deploy(tokenName, tokenSymbol);

  // Wait contract deploy process for complete
  await zizyErc20Contract.deployed();

  console.log("Zizy ERC20 deployed to:", zizyErc20Contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
