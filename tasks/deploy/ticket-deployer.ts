import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { StorageService } from "../../scripts/helpers/StorageService";
import { CompetitionFactory, ZizyERC20 } from "../../typechain-types";

task("deploy:ticket-deployer", "Deploys Ticket Deployer")
  .addOptionalParam<string>("factory", "Competition factory contract address | Read from storage if not given as argument", "")
  .addFlag("verify", "Verify contract after deployment")
  .setAction(async function(taskArgs, hre: HardhatRuntimeEnvironment) {
    const storage = StorageService.getInstance(hre);

    // Compile first
    await hre.run("compile", "--quiet");

    const { ethers, upgrades } = hre;

    const signers = await ethers.getSigners();

    //region Check Competition factory address
    if (!taskArgs.factory) {
      const compFactory = storage.getData("CompetitionFactory");
      if (!compFactory || !compFactory.contractAddress) {
        throw new Error(`Competition factory information not found on storage. Please add factory address as argument`);
      }
      taskArgs.factory = compFactory.contractAddress;
    }
    //endregion

    const signerAccount = signers[0];
    console.log(`Signer account: ${signerAccount.address}`);

    // We get the contract to deploy
    const factory = await ethers.getContractFactory("TicketDeployer", signerAccount);

    // Deploy
    const contract = await factory.deploy(taskArgs.factory);
    await contract.deployed();

    console.log(`Ticket deployer deployed to: ${contract.address}`);

    // Save
    await storage.setData("TicketDeployer", {
      receiver: taskArgs.receiver,
      minter: taskArgs.minter
    }, contract.address);

    if (taskArgs.verify) {
      await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: []
      });
    }

    return contract.address;
  });
