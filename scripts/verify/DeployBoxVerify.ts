import * as hre from "hardhat";

async function main() {
  // Erc20 contract address
  const contractAddress = "0xefD25D2533CE08b62bd67261181764db29AEe1A8";

  // Name - Symbol of ERC20 contract
  const constructorArgs: [] = [];

  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: constructorArgs
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
