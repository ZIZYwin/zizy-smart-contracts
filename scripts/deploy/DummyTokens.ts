import { ethers } from "hardhat";
import * as hre from "hardhat";

async function main() {
  // Compile if contracts is not compiled
  await hre.run("compile");

  // We get the contract to deploy
  const ERC20Def = await ethers.getContractFactory("ERC20Def");

  const wBtc = await ERC20Def.deploy("wBTC", "Wrapped BTC");
  await wBtc.deployed();
  console.log(`wBTC Deployed to: ${wBtc.address}`);

  const usdtz = await ERC20Def.deploy("USDT.z", "USDT Z");
  await usdtz.deployed();
  console.log(`USDT.z Deployed to: ${usdtz.address}`);

  const ERC721Def = await ethers.getContractFactory("ERC721Def");

  const testNFT = await ERC721Def.deploy("Test NFT", "tNFT.z");
  await testNFT.deployed();
  console.log(`tNFT.z Deployed to: ${testNFT.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
