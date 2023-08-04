import { expect } from 'chai';
import { ethers } from 'hardhat';
import { BigNumberish, Contract } from 'ethers';

describe('apt.sol', () => {
  let contractFactory: any;
  let contract: Contract;
  let owner: any;
  let alice: any;
  let bob: any;
  let initialSupply: BigNumberish;
  let ownerAddress: string;
  let aliceAddress: string;
  let bobAddress: string;

  beforeEach(async () => {
    [owner, alice, bob] = await ethers.getSigners();
    initialSupply = ethers.parseEther('100000');
    contractFactory = await ethers.getContractFactory('Token');
    contract = await contractFactory.deploy(initialSupply);
    ownerAddress = await owner.getAddress();
    aliceAddress = await alice.getAddress();
    bobAddress = await bob.getAddress();
  });

  describe('Correct setup', () => {
    it("should be named 'AwesomeProject", async () => {
      const name = await contract.name();
      // console.log('owner name:', owner);
      expect(name).to.equal('AwesomeProject');
    });
    it('should have correct supply', async () => {
      const supply = await contract.getTotalSupply();
      expect(supply).to.equal(initialSupply);
    });
    it('owner should have all the supply', async () => {
      const ownerBalance = await contract.balanceOf(ownerAddress);
      expect(ownerBalance).to.equal(initialSupply);
    });
  });

  describe('Core', () => {
    it('aliceBalance is 0', async () => {
      const aliceBalance = await contract.balanceOf(aliceAddress);
      expect(aliceBalance).to.equal(0);
    });
    it('owner should transfer to Alice and update balances', async () => {
      const transferAmount = ethers.parseEther('50');
      let aliceBalance = await contract.balanceOf(aliceAddress);
      expect(aliceBalance).to.equal(0);
      await contract.transfer(transferAmount, aliceAddress);
      aliceBalance = await contract.balanceOf(aliceAddress);
      expect(aliceBalance).to.equal(transferAmount);
    });
    // it('owner should transfer to Alice and Alice to Bob', async () => {
    //   const transferAmount = ethers.parseEther('50');
    //   await contract.transfer(transferAmount, aliceAddress); // contract is connected to the owner.
    //   let bobBalance = await contract.balanceOf(bobAddress);
    //   expect(bobBalance).to.equal(0);
    //   await contract.connect(alice).transfer(transferAmount, bobAddress);
    //   bobBalance = await contract.balanceOf(bobAddress);
    //   expect(bobBalance).to.equal(transferAmount);
    // });
    it('should fail by depositing more than current balance', async () => {
      const txFailure = initialSupply;
      await expect(contract.transfer(txFailure, aliceAddress)).to.be.revertedWith(
        'Not enough funds'
      );
    });
  });

  // describe('Transactions', function () {
  //   it('Should transfer tokens between accounts', async function () {
  //     // Transfer 50 tokens from owner to addr1
  //     await contract.transfer(50, aliceAddress);
  //     let aliceBalance = await contract.balanceOf(aliceAddress);
  //     expect(aliceBalance).to.equal(50);
  //     await expect(
  //       contract.connect(aliceAddress).transfer(10, bobAddress)
  //     ).to.be.revertedWith("Not enough tokens");

  //     console.log('aliceAddress balance..',aliceBalance, await contract.balanceOf(bobAddress));
  //   });
  // });
});
