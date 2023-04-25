// Ethers JS: First interaction with Hardhat blockchain.
////////////////////////////////////////////////////////////

// Exercise 0. Load dependencies and network provider.
//////////////////////////////////////////////////////

// a. Require the `dotenv` and `ethers` packages.
// Hint: As you did multiple times now.

// Your code here!

require("dotenv").config();
const ethers = require("ethers");

// Exercise 1. Create a JSON RPC Provider for the Hardhat blockchain.
/////////////////////////////////////////////////////////////////////

// Hint: you will find the info printed to console after you start the hardhat
// blockchain.

// Your code here!
// console.log(ethers.version)
const network = "http://127.0.0.1:8545";
const hardhatProvider = new ethers.JsonRpcProvider(network);

// Exercise 2. Let's query the provider.
////////////////////////////////////////

// Hardhat Blockchain si too long. Let's call it NUMA.
// Print to console the network name, chain id, and block number of NUMA.

const networkInfo = async () => {
   
    // Your code here!
    let network = await hardhatProvider.getNetwork();
    let name = network.name;
    let chainId = network.chainId;
    let blockN = await hardhatProvider.getBlockNumber();
    console.log(name, chainId, blockN);
};

networkInfo();


// Exercise 3. Connect a signer to the Hardhat blockchain.
//////////////////////////////////////////////////////////

// Hint: you will find the info printed to console after you start the hardhat
// blockchain.

// let hhPrivateKey = "0x8ecdb66d6ac608dd911cd5ac595e7f4c4a92a6f3bc3353076b00ce0291f21684";
let hhPrivateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
const signer = new ethers.Wallet(hhPrivateKey, hardhatProvider);

// Your code here!

// b. Print the next nonce necessary to send a transaction.
// Hint: .getNonce()

const getNonce = async() => {

    // Your code here!
    let nonce = await signer.getNonce();
    console.log('Your nonce is ' + nonce);

};

getNonce();


// Exercise 4. Check gas.
/////////////////////////

// a. Let's get some gas from the faucet. What is the faucet's address? 
// Check the slides in ILIAS.
// Hint: only accessible within UniMa network.

// b. Check your balance on UniMa network.

const checkBalance = async () => {

    // Your code here!

    let balance = await hardhatProvider.getBalance(signer.address);

    console.log('My balance is ' + ethers.formatEther(balance) + ' ETH.');

};

checkBalance();

// Exercise 5. Send a transaction.
//////////////////////////////////

// Send some Ether from one of your accounts to another one on NUMA.

const account2 = process.env.METAMASK_1_ADDRESS;

const sendTransaction = async () => {

    // Your code here!

    let b1 = await hardhatProvider.getBalance(signer.address);
    let b2 = await hardhatProvider.getBalance(account2);
    b1 = ethers.formatEther(b1);
    b2 = ethers.formatEther(b2);
    

    tx = await signer.sendTransaction({
        to: account2,
        value: ethers.parseEther("0.01")
    });

    // console.log(tx);
    
    console.log('Transaction is in the mempool...');
    await tx.wait();

    console.log('Transaction mined!');

    let updatedB1 = await hardhatProvider.getBalance(signer.address);
    let updatedB2 = await hardhatProvider.getBalance(account2);
    updatedB1 = ethers.formatEther(updatedB1);
    updatedB2 = ethers.formatEther(updatedB2);

    console.log('Balance for', signer.address, 'changed from', b1, 'to', updatedB1);
    console.log('Balance for', account2, 'changed from', b2, 'to', updatedB2);

};

sendTransaction();

