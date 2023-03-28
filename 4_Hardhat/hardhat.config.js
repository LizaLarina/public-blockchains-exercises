// require("@nomicfoundation/hardhat-toolbox");
// require('dotenv').config();

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.18",
//   // defaultNetwork: "localhost",
//   networks: {
//     goerli: {
//       // url: process.env.INFURA_GOERLI_API_URL + process.env.INFURA_KEY,
//       url: "https://goerli.infura.io/v3/1f0f872b8f2a403088141b7e7f473679",
//       accounts: process.env.METAMASK_1_PRIVATE_KEY
//     }
//   },
// };

require("@nomicfoundation/hardhat-toolbox");

const path = require('path')
const res = require('dotenv')
  .config({ path: path.resolve(__dirname, '..', '.env') });


// You may also use Alchemy.
const INFURA_KEY = process.env.INFURA_KEY;
const INFURA_URL = process.env.INFURA_GOERLI_API_URL;
const GOERLI_RPC_URL = `${INFURA_URL}${INFURA_KEY}`;

console.log(GOERLI_RPC_URL);
console.log('------------------------')

// Beware: NEVER put real Ether into testing accounts.
const MM_PRIVATE_KEY = process.env.METAMASK_1_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "goerli",
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY
  },
  networks: {
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [ MM_PRIVATE_KEY ],
    },
    unima1: {
      url: process.env.NOT_UNIMA_URL_1,
      accounts: [ MM_PRIVATE_KEY ],
    },
    unima2: {
      url: process.env.NOT_UNIMA_URL_2,
      accounts: [ MM_PRIVATE_KEY ],
    },
  },
};
