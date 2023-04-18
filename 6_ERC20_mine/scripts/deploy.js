// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const hre = require("hardhat");

async function main() {
  const MyERC20 = await hre.ethers.getContractFactory("MyERC20");

  const myERC20 = await MyERC20.deploy(1000000000);

  await myERC20.deployed();

  const name = await myERC20.name();
  const symbol = await myERC20.symbol();
  const decimals = await myERC20.decimals();

  console.log(
    `${name} token with a symbol of ${symbol} (with ${decimals.toString()} decimals) deployed to ${myERC20.address}`
  );

  // // Deploy the contract
  // const myERC20 = await MyERC20.deploy("TrialToken", "TRL", 18, 1000000000);

  // await myERC20.deployed();

  // console.log(`MyERC20 deployed to ${myERC20.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });