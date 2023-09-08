import { ethers } from "hardhat";
import { assert, expect } from "chai";

export async function expectError(promise: Promise<any>, expectedError: string, message?: string) {
  try {
    await promise.then(() => {
      assert.fail(`Promise expected throw error but nothing throwed`);
    });
  } catch (e: Error) {
    await expect(e.message).to.contain(expectedError, message);
  }
}

export async function getNodeCurrentTime() {
  return (await ethers.provider.getBlock("latest")).timestamp;
}
