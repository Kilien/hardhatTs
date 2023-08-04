import { ethers } from "hardhat";

export default async function deploy(contractName:string, args:any) {
  let contract: any;
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);

  // console.log('Account balance:', (await deployer.getBalance()).toString());

  try {
    // deploy
    const contractFactory = await ethers.getContractFactory(contractName);
    // 部署普通合约
    contract = await contractFactory.deploy(...args);

    await contract.waitForDeployment();

    console.log('contract address:', contract.target);
    console.log('deployer:', deployer.address);
    // console.log('ACCOUNT BALANCE', await contract.balanceOf(deployer.address));
    console.log('Deployer Successful');
  } catch (e:any) {
    if (e.message.toLowerCase().includes('connect timeout')) {
      console.log('Connect Timeout');
    } else {
      console.log(e);
    }
  }
  return contract?.target
}