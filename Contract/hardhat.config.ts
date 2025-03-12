import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  paths: {
    sources: "./Contract", // Change this to match your folder name
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    hardhat: {},
    // Configure other networks if needed (e.g., rinkeby, mainnet)
  },
};

export default config;