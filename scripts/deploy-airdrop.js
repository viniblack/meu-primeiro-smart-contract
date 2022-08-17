const hre = require("hardhat");

async function main() {
  const CryptoToken = await hre.ethers.getContractFactory("CryptoToken");
  const cryptoToken = await CryptoToken.deploy(1000)
  await cryptoToken.deployed();
  console.log("Endereço do CryptoToken", cryptoToken.address);

  const Airdrop = await hre.ethers.getContractFactory("Airdrop");
  const airdrop = await Airdrop.deploy(cryptoToken.address);
  await airdrop.deployed();
  console.log("Endereço do Airdrop", airdrop.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
