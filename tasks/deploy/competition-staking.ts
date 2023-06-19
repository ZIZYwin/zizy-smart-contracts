import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { StorageService } from "../../scripts/helpers/StorageService";
import { ZizyERC20 } from "../../typechain-types";

task("deploy:competition-staking", "Deploys Competition Factory")
  .addParam<string>("receiver", "Fee/Payment receiver address")
  .addOptionalParam<string>("token", "ZIZY Token address | Read from storage if not given as argument", "")
  .addFlag("verify", "Verify contract after deployment")
  .setAction(async function(taskArgs, hre: HardhatRuntimeEnvironment) {
    const storage = StorageService.getInstance(hre);

    // Compile first
    await hre.run("compile", "--quiet");

    const { ethers, upgrades } = hre;

    const signers = await ethers.getSigners();

    //region Check ZIZY Token
    if (!taskArgs.token) {
      const tokenData = storage.getData("ZizyERC20");
      if (!tokenData || !tokenData.contractAddress) {
        throw new Error(`ZIZY Token information not found on storage. Please add zizy token address as argument`);
      }
      taskArgs.token = tokenData.contractAddress;
    }

    const tokenFactory = await ethers.getContractFactory("ZizyERC20");
    const tokenContract = (await tokenFactory.attach(taskArgs.token) as ZizyERC20);
    const tokenName = await tokenContract.name();
    const tokenSymbol = await tokenContract.symbol();

    if (tokenName != "ZIZY" && tokenSymbol != "ZIZY") {
      throw new Error(`Given token address is not ZIZY token. Please check address`);
    }
    //endregion

    const signerAccount = signers[0];
    console.log(`Signer account: ${signerAccount.address}`);

    // We get the contract to deploy
    const factory = await ethers.getContractFactory("ZizyCompetitionStaking", signerAccount);

    // Deploy as a proxy
    const contract = await upgrades.deployProxy(factory, [taskArgs.token, taskArgs.receiver], {
      initializer: "initialize"
    });
    await contract.deployed();
    const implementation = await upgrades.erc1967.getImplementationAddress(contract.address);

    console.log(`Competition Staking deployed to: ${contract.address}`);
    console.log(`Competition Staking implementation: ${implementation}`);

    // Save
    await storage.setData("ZizyCompetitionStaking", {
      receiver: taskArgs.receiver,
      token: taskArgs.token,
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
