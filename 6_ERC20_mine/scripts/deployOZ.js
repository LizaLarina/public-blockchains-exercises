const hre = require("hardhat");
const { ethers } = require("ethers");

async function main() {
  const ERC20_OZ = await hre.ethers.getContractFactory("ERC20_OZ");

  const myERC20 = await ERC20_OZ.deploy();
  await myERC20.deployed();

  const name = await myERC20.name();
  const symbol = await myERC20.symbol();
  const decimals = await myERC20.decimals();

  console.log(
    `${name} token with a symbol of ${symbol} (with ${decimals.toString()} decimals) deployed to ${myERC20.address}`
  );

  // // Send some tokens to another address
  // const signer = new ethers.Wallet(process.env.PRIVATE_KEY);
  // const recipient = "0x1234567890123456789012345678901234567890";
  // const amount = ethers.utils.parseEther("100");
  // await myERC20.connect(signer).transfer(recipient, amount);
  // console.log(`Transferred ${ethers.utils.formatEther(amount)} ${symbol} tokens to ${recipient}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });