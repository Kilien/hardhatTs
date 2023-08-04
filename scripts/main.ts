import { ethers } from "hardhat";
import deploy from "../utils/deploy";
import verify from "../utils/verify";
import upgrade from "../utils/upgrade";
import deployProxy from "../utils/deployProxy";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  // const amount = ethers.parseEther("100");

  const addr = await deploy('PTX', [{ gasPrice: ethers.parseUnits('10', 'gwei') }]);
  await verify(addr, []);
  // await verify('0x4b48A26363093Be2539F9b63d07a87d6e96e1216', []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});