import fs from "fs-extra";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import _ from "lodash";

const STORAGE_PATH = "./storage.json";

interface IContractStorage {
  contractAddress?: string,
  bytecode?: string,
  arguments?: any,
  lastUpdate?: Date,
}

export class StorageService {
  private static instance: StorageService;
  private data: { [key: number]: { [key: string]: IContractStorage } };
  private readonly chainId: number;
  private readonly hre: HardhatRuntimeEnvironment;

  private constructor(hre: HardhatRuntimeEnvironment) {
    this.hre = hre;
    this.chainId = hre.network.config.chainId || 0;
    if (!fs.existsSync(STORAGE_PATH)) {
      fs.createFileSync(STORAGE_PATH);
    }
    this.loadStorageData();
  }

  public static getInstance(hre: HardhatRuntimeEnvironment): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService(hre);
    }
    return StorageService.instance;
  }

  private loadStorageData(): any {
    try {
      this.data = fs.readJSONSync(STORAGE_PATH);
    } catch (err) {
      this.data = {};
    }
  }

  public async setData(contractName: string, _args: any, newContractAddress?: string, save: boolean = true) {
    const factory = await this.hre.ethers.getContractFactory(contractName);
    if (!_.has(this.data, this.chainId)) {
      this.data[this.chainId] = {};
    }
    if (!_.has(this.data[this.chainId], contractName)) {
      this.data[this.chainId][contractName] = {};
    }

    const currentData = this.data[this.chainId][contractName];
    const oldContract = _.get(currentData, "contractAddress") as string | undefined;
    this.data[this.chainId][contractName] = {
      contractAddress: (newContractAddress ? newContractAddress : (oldContract)),
      bytecode: factory.bytecode,
      arguments: _args,
      lastUpdate: (new Date())
    };

    if (save) {
      await this.save();
    }
  }

  public getData(contractName: string, chainId?: number) {
    const chainSelector = (chainId ? chainId : this.chainId);
    return (_.get(this.data, `${chainSelector}.${contractName}`, null) as IContractStorage | null);
  }

  public async save(): Promise<void> {
    await fs.writeJSON(STORAGE_PATH, this.data);
  }
}
