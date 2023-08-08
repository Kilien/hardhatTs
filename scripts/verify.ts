import { run } from "hardhat";

async function main() {
  try {
    await run("verify:verify", {
      contract: "contracts/stake.sol:Mine",
      address: '0x3F428cD8C976293377290980f5d58B958EDEc467',
      constructorArguments: ["0xA2dc8D106d09Eb63aE4eDDDE7B8de083ce49bba5","0xBe2762943E212a3aE5C9255C53ED17AEd189b5Cd"],
    })
    console.log('Verifying Successful');
  } catch (e: any) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already verified!")
    } else {
      console.log(e)
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
