import { run } from "hardhat";

async function main() {
  try {
    await run("verify:verify", {
      contract: "contracts/ptx.sol:PTX",
      address: '0xfCC4788A4Fd00A4aEa8BC43cB472Ce0a7f7a3917',
      constructorArguments: [],
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
