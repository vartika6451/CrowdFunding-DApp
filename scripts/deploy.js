const { ethers } = require("hardhat");

async function main() {
  const Contract = await ethers.getContractFactory("Crowdfunding");
  const contract = await Contract.deploy();

  await contract.waitForDeployment();

  console.log("Deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});