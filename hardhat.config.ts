import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "@openzeppelin/hardhat-upgrades";

dotenv.config();

const web3Accounts: string[] = [process.env.WEB3_ACCOUNT || ""];

const hardhatAccounts = [
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",   // #0 - Main Deployer
  "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",   // #1 - Competititon Factory Deployer
  "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a",   // #2 - Staking Contract Deployer
  "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",   // #3 - Rewards Hub Deployer
  "0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a",   // #4 - Zizy ERC20 Deployer
  "0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba",   // #5 - PoPa Factory Deployer
  "0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e",   // #6 - Dummy Tokens Deployer
  "0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356"    // #7 - Ticket Deployer - Deployer
];

const testnetProxyAccs = [process.env.TESTNET_PROXY_ACCOUNT || ""];

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    local: {
      url: "http://127.0.0.1:7545",
      accounts: web3Accounts,
      chainId: 5777
    },
    hardhatLocal: {
      url: "http://127.0.0.1:8545",
      accounts: hardhatAccounts,
      chainId: 31337
    },
    ethMainnet: {
      url: "https://mainnet.infura.io/v3/",
      accounts: web3Accounts,
      chainId: 1
    },
    bscMainnet: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: web3Accounts,
      chainId: 56
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: web3Accounts,
      chainId: 97
    },
    avaxCMainnet: {
      url: "https://api.avax.network/ext/bc/C/rpc",
      accounts: web3Accounts,
      chainId: 43114
    },
    avaxCTestnet: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      accounts: testnetProxyAccs,
      chainId: 43113
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD"
  },
  etherscan: {
    apiKey: process.env.SNOWTRACE_API_KEY
  }
};

export default config;
