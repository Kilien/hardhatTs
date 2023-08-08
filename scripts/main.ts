import { ethers } from "hardhat";
import deploy from "../utils/deploy";
import verify from "../utils/verify";
import upgrade from "../utils/upgrade";
import deployProxy from "../utils/deployProxy";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  // const amount = ethers.parseEther("100");

  // const addr = await deploy('Mine', ["0xA2dc8D106d09Eb63aE4eDDDE7B8de083ce49bba5","0xBe2762943E212a3aE5C9255C53ED17AEd189b5Cd", { gasPrice: ethers.parseUnits('10', 'gwei') }]);
  // await verify("contracts/stake.sol:Mine", addr, ["0xA2dc8D106d09Eb63aE4eDDDE7B8de083ce49bba5","0xBe2762943E212a3aE5C9255C53ED17AEd189b5Cd"]);
  // await verify('0xA2dc8D106d09Eb63aE4eDDDE7B8de083ce49bba5', []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});