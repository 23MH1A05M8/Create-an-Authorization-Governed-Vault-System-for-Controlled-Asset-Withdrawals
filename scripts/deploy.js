const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const Auth = await hre.ethers.getContractFactory("AuthorizationManager");
  const auth = await Auth.deploy(deployer.address);
  await auth.waitForDeployment();

  const Vault = await hre.ethers.getContractFactory("SecureVault");
  const vault = await Vault.deploy(await auth.getAddress());
  await vault.waitForDeployment();

  console.log("AuthorizationManager:", await auth.getAddress());
  console.log("SecureVault:", await vault.getAddress());
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});