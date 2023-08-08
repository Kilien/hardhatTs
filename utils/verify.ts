import { run } from "hardhat";

export default async function verify(fileName:string, contractAddress: string | undefined, args: any) {
  try {
    // contract: "contracts/simpleToken.sol:simpleToken",
    await run("verify:verify", {
      contract: fileName,
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