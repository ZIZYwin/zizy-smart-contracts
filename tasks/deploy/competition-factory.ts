import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { StorageService } from "../../scripts/helpers/StorageService";

task("deploy:competition-factory", "Deploys Competition Factory")
  .addParam<string>("receiver", "Fee/Payment receiver address")
  .addParam<string>("minter", "Ticket minter address")
  .addFlag("verify", "Verify contract after deployment")
  .setAction(async function(taskArgs, hre: HardhatRuntimeEnvironment) {
    const storage = StorageService.getInstance(hre);

    // Compile first
    await hre.run("compile", "--quiet");

    const { ethers, upgrades } = hre;

    const signers = await ethers.getSigners();

    const signerAccount = signers[0];
    console.log(`Signer account: ${signerAccount.address}`);

    // We get the contract to deploy
    const factory = await ethers.getContractFactory("CompetitionFactory", signerAccount);

    // Deploy as a proxy
    const contract = await upgrades.deployProxy(factory, [taskArgs.receiver, taskArgs.minter], {
      initializer: "initialize"
    });
    await contract.deployed();
    const implementation = await upgrades.erc1967.getImplementationAddress(contract.address);

    console.log(`Competition Factory deployed to: ${contract.address}`);
    console.log(`Competition Factory implementation: ${implementation}`);

    // Save
    await storage.setData("CompetitionFactory", {
      receiver: taskArgs.receiver,
      minter: taskArgs.minter,
      _implementation: implementation
    }, contract.address);

    if (taskArgs.verify) {
      await hre.run("verify:verify", {
        address: implementation,
        constructorArguments: []
      });
    }

    return contract.address;
  });
