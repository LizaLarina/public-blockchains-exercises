// First exercises with the Open Zeppelin contracts.
////////////////////////////////////////////////////

// Resources:

// https://docs.openzeppelin.com/

// https://docs.openzeppelin.com/contracts/4.x/erc20

// Exercise 1. Open Zeppelin library.
/////////////////////////////////////

// Implement an ERC-20 token using the Open Zeppelin library of contracts.

// A basic example is in contracts/ERC20_OZ, but feel free to go free style!

// Hint: do not forget to install the openzeppelin package.

require('dotenv').config();
const ethers = require("ethers");
console.log(ethers.version);

// Update info to match your contract.
const cAddress = "0x3B1519b2DAF3443058486e34fbC2bfC8565a04e5";
const cName = "ERC20_OZ";

// V5 Syntax for executing within an Hardhat project.
const notUniMaUrl = process.env.NOT_UNIMA_URL_1;
const notUniMaProvider = new ethers.providers.JsonRpcProvider(notUniMaUrl);

// The deployer is the first address in the `accounts` field inside a 
// network declaration in hardhat.config.js. 

// For instance, if this the declation of the unima network:

// unima: {
//     url: ...,
//     accounts: [ "0x1...", "0x2..." ],
// }

// The deployer is the address beginning with "0x1...", unless otherwise
// specified by in the deploy script.

let deployer = new ethers.Wallet(process.env.METAMASK_1_PRIVATE_KEY, notUniMaProvider);
console.log(deployer.address);

let signer = new ethers.Wallet(process.env.METAMASK_2_PRIVATE_KEY, notUniMaProvider);
console.log(signer.address);

const getContract = async(signer) => {

    // Adjust path as needed.
    // Fetch the ABI from the artifacts.
    const cABI = require("../artifacts/contracts/" + cName + 
                           ".sol/" + cName + ".json").abi;

    // Create the contract and print the address.
    const c = new ethers.Contract(cAddress, cABI, signer);

    console.log(cName + " address: ", c.address);

    return c;
};

const waitForTx = async (tx, verbose) => {
    console.log('Transaction in mempool!');
    if (verbose) console.log(tx);
    else console.log(tx.nonce, tx.hash);
    await tx.wait();
    console.log('Transaction mined!');
};

const transfer = async () => {
    // Get contract.
    const contract = await getContract(deployer);

    // Check balances.
    let balance = await contract.balanceOf(deployer.address);
    console.log("Current sender balance: ", Number(balance));
    let balanceReceiver = await contract.balanceOf(signer.address);
    console.log("Current receiver balance: ", Number(balanceReceiver));
    
    // Transfer.
    let amountToTransfer = 10;
    console.log("Tokens to send: ", amountToTransfer);
    let tx = await contract.transfer(signer.address, amountToTransfer);
    await waitForTx(tx);
    
    // Check balances.
    let balance2 = await contract.balanceOf(deployer.address);
    console.log("Updated sender balance: ", Number(balance2));
    let balanceReceiver2 = await contract.balanceOf(signer.address);
    console.log("Current receiver balance: ", Number(balanceReceiver2));
};

transfer();