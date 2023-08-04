import 'dotenv/config';
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const PrivateKey = process.env.PRIVATE_KEY;
const endpoint = process.env.URL;

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.18',
    settings: {
        optimizer: {
          enabled: true, // 合约优化
          runs: 200,
        }
    }
  },

  networks: {
    bscTestnet: {
      url: 'https://data-seed-prebsc-2-s1.bnbchain.org:8545',
      chainId: 97,
      accounts: [`${PrivateKey}`],
      timeout: 600000000
    },
    testMatic: {
      url: 'https://rpc-mumbai.maticvigil.com',
      chainId: 80001,
      accounts: [`${PrivateKey}`]
    },
    testArb: {
      url: "https://arbitrum-goerli.publicnode.com",
      chainId: 421613,
      accounts: [`${PrivateKey}`],
      timeout: 600000000,
  },
  },
  etherscan: {
    apiKey:{
      bscTestnet: process.env.BscKey as string,
      testMatic: process.env.MaticKey as string,
      testArb: process.env.ARBKey as string,
    } 
  }
};

export default config;
