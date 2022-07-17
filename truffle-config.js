const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
// private_keys = [
//   process.env.PRIVATE_KEY_OWNER,
//   process.env.PRIVATE_KEY_INTERACT,
// ];
module.exports = {
  networks: {
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          process.env.PRIVATE_KEY_OWNER,
          process.env.INFURA_API_KEY
        ),
      network_id: 4, // Rinkeby's id
      gas: 5500000, // Rinkeby has a lower block limit than mainnet
      confirmations: 2, // # of confirmations to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
    },
  },

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.14", // Fetch exact version from solc-bin (default: truffle's version)
    },
  },
};
