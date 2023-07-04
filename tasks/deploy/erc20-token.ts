import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { StorageService } from "../../scripts/helpers/StorageService";

task("deploy:erc20-token", "Deploys ERC20 Token")
  .addParam<string>("name", "Token name")
  .addParam<string>("symbol", "Token symbol")
  .addFlag("verify", "Verify contract after deployment")
  .setAction(async function(taskArgs, hre: HardhatRuntimeEnvironment) {
    const storage = StorageService.getInstance(hre);

    // Compile first
    await hre.run("compile", "--quiet");

    const { ethers } = hre;

    const signers = await ethers.getSigners();

    const signerAccount = signers[0];
    console.log(`Signer account: ${signerAccount.address}`);

    // We get the contract to deploy
    const factory = await ethers.getContractFactory("ZizyERC20", signerAccount);

    const contract = await factory.deploy(taskArgs.name, taskArgs.symbol);
    await contract.deployed();

    // Save
    await storage.setData("ZizyERC20", {
      name: taskArgs.name,
      symbol: taskArgs.symbol
    }, contract.address);

    if (taskArgs.verify) {
      await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [taskArgs.name, taskArgs.symbol]
      });
    }

    console.log(`ERC20 Deployed with args[${taskArgs.name}, ${taskArgs.symbol}] to address: ${contract.address}`);

    return contract.address;
  });
