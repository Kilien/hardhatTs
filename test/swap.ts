import { expect } from 'chai';
import { ethers } from 'hardhat';
import { MaxUint256 } from 'ethers';
import { BigNumberish, Contract } from 'ethers';

describe('factory', () => {
  let contractFactory: any;
  let contract: Contract;
  let owner: any;
  let alice: any;
  let bob: any;
  let initialSupply: BigNumberish;
  let ownerAddress: string;
  let aliceAddress: string;
  let bobAddress: string;
  let APT: any;
  let PTX:any;
  let WBNB: any;
  let router: any;
  let pair: any;

  beforeEach(async () => {
    [owner, alice, bob] = await ethers.getSigners();
    initialSupply = ethers.parseEther('1000000');
    ownerAddress = await owner.getAddress();
    aliceAddress = await alice.getAddress();
    bobAddress = await bob.getAddress();

    const aptFactory = await ethers.getContractFactory('APT');
    APT = await aptFactory.deploy(initialSupply);

    const ptxFactory = await ethers.getContractFactory('PTX');
    PTX = await ptxFactory.deploy();

    const wbnbFactory = await ethers.getContractFactory('WBNB');
    WBNB = await wbnbFactory.deploy();

    contractFactory = await ethers.getContractFactory('UniswapV2Factory');
    contract = await contractFactory.deploy(owner);
    await contract.createPair(APT.target, PTX.target);
    pair = await contract.getPair(APT.target, PTX.target);

    const routerFactory = await ethers.getContractFactory('UniswapV2Router02');
    router = await routerFactory.deploy(contract.target, WBNB.target);

  });

  describe('Correct setup', () => {
    it("获取Pair地址", async () => { 
      PTX.approve(router.target, MaxUint256);
      APT.approve(router.target, MaxUint256);

      const pairHash = await contract.INIT_CODE_PAIR_HASH();
      console.log('pair0...', pair);
      console.log('INIT_CODE_PAIR_HASH...', pairHash);
      
      
      const add = await router.addLiquidity(APT.target, PTX.target, ethers.parseEther('100'), ethers.parseEther('100'), 0, 0, ownerAddress, MaxUint256, {
        gasLimit: 9999999
      });
      console.log('addLiquidity:', add);
      // expect(add).to.equal('0x0000000000000000000000000000000000000000');
    });
    
  });
});
