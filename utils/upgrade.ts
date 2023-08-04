import { ethers, network, upgrades, run } from "hardhat";

export default async function upgrade(proxyContract:string, contractAddress: string, args: any) {
  console.log('Deploying Contract on the chainId ' + network.config.chainId);

  const logicContract = await ethers.getContractFactory(contractAddress);
  // console.log(1);

  console.log('代理合约地址: ', proxyContract);
  const contract = await upgrades.upgradeProxy(proxyContract, logicContract);
  // console.log(1);
  await contract.deployed();

  console.log('contract deployed to: ', contract.address);

  const storeImpl = await upgrades.erc1967.getImplementationAddress(contract.address);

  console.log('实现合约: ', storeImpl);

  console.log('Verifying contract...');
  try {
    await run('verify:verify', {
      // contract: "contracts/yuri_minter.sol:Yuri_Minter",
      address: storeImpl,
      constructorArguments: args
    });
    console.log('Verifying Successful');
  } catch (e:any) {
    if (e.message.toLowerCase().includes('already verified')) {
      console.log('Already verified!');
    } else {
      console.log(e);
    }
  }
}