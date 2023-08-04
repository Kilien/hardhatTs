import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumberish, Contract, formatEther } from "ethers";

describe('MechaCat.sol', () => {
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
    contractFactory = await ethers.getContractFactory('MechaCat');
    contract = await contractFactory.deploy();
    ownerAddress = await owner.getAddress();
    aliceAddress = await alice.getAddress();
    bobAddress = await bob.getAddress();
  });

  describe('Correct setup', () => {
    it("should be named 'MechaCat", async () => {
      const name = await contract.name();
      expect(name).to.equal('MechaCat');
    });
    it('owner should have all the supply', async () => {
      const ownerBalance = await contract.balanceOf(ownerAddress);
      expect(ownerBalance).to.equal(0);
    });
    it('tokenID-168 info', async () => {
      const card = await contract.cardInfo(168);
      expect(card.name).to.equal("Origin Cat");
      console.log('card token uri...', card.tokenURI);
    });
  });

  describe('Core...', () => {
    it("mint owner origin cat", async () => {
      const res = await contract.freeMint();
      const ownerBalance = await contract.balanceOf(ownerAddress);
      console.log('balance...',ethers.toNumber(ownerBalance));
      const card = await contract.checkUserCardIds(ownerAddress);
      console.log('card token id...', card);
      expect(card.length).to.equal(1);
    });
  });
});