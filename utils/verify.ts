import { run } from "hardhat";

export default async function verify(contractAddress: string | undefined, args: any) {
  try {
    await run("verify:verify", {
      // contract: "contracts/yuri_minter.sol:Yuri_Minter",
      address: contractAddress,
      constructorArguments: args,
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