/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('dotenv').config();
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-etherscan');
require('hardhat-contract-sizer');
require('hardhat-gas-reporter');
const {PRIVATE_KEY, INFURA_KEY, ETHERSCAN_API} = process.env;
module.exports = {
  solidity: '0.8.0',
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ETHERSCAN_API,
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  gasReporter: {
    currency: 'USD',
  },
  defaultNetwork: 'mainnet',
  networks: {
    hardhat: {
      chainId: 137,
    },
    mainnet: {
      url: 'https://mainnet.infura.io/v3/' + INFURA_KEY,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    ropsten: {
      url: 'https://ropsten.infura.io/v3/' + INFURA_KEY,
      // url: 'https://polygon-mainnet.g.alchemy.com/v2/5XVWv4P5pthhxbxWAeqgRJ-QpIU9C2uv',
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mumbai: {
      url: 'https://polygon-mumbai.infura.io/v3/' + INFURA_KEY,
      accounts: [`0x${PRIVATE_KEY}`],
      gasPrice: 8000000000,
    },
  },
};
