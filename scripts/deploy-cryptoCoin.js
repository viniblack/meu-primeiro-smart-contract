const hre = require("hardhat");

async function main() {
  const CryptoCoin = await hre.ethers.getContractFactory("CryptoCoin");
  const cryptoCoin = await CryptoCoin.deploy(1000)
  await cryptoCoin.deployed();
  console.log("Endereço do CryptoCoin", cryptoCoin.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
