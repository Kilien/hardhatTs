import { ethers, upgrades } from "hardhat";

export default async function deployProxy(contractName:string, args:any) {
  let contract;
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  try {
    // deploy
    const contractFactory = await ethers.getContractFactory(contractName);
    // 部署代理合约
    contract = await upgrades.deployProxy(contractFactory, args, {
        initializer: "initialize",
    });
    await contract.deployed();

    console.log('contract address:', contract.address);
    console.log('deployer:', deployer.address);
    console.log('ACCOUNT BALANCE', await contract.balanceOf(deployer.address));
    console.log('Deployer Successful');
  } catch (e:any) {
    if (e.message.toLowerCase().includes('connect timeout')) {
      console.log('Connect Timeout');
    } else {
      console.log(e);
    }
  }
  return contract?.address
}