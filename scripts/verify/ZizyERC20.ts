import * as hre from "hardhat";

async function main() {
  // Erc20 contract address
  const contractAddress = "0xf02e7885947C8E98E8DCF4cF28cC8b5A22f79435";

  // Name - Symbol of ERC20 contract
  const constructorArgs = ["ZToken", "ZTK"];

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
