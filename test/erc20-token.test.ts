import { expect } from "chai";
import { ethers } from "hardhat";
import { ZizyERC20 } from "../typechain-types";
import { Contract } from "ethers";

describe("ZizyERC20", function() {
  let token: ZizyERC20 | Contract;
  let owner: any;
  const name = "ZIZY";
  const symbol = "ZIZY";
  const decimals = 8;
  const initialSupply = ethers.BigNumber.from(150000000).mul(ethers.BigNumber.from(10).pow(decimals));

  beforeEach(async function() {
    const ZizyERC20Factory = await ethers.getContractFactory("ZizyERC20");
    [owner] = await ethers.getSigners();

    token = await ZizyERC20Factory.deploy(name, symbol);
    await token.deployed();
  });

  it("should have correct name, symbol, and decimals", async function() {
    expect(await token.name()).to.equal(name);
    expect(await token.symbol()).to.equal(symbol);
    expect(await token.decimals()).to.equal(decimals);
  });

  it("should mint initial supply to the deployer", async function() {
    const balance = await token.balanceOf(owner.address);
    expect(balance).to.equal(initialSupply);
  });

  it("should allow burning tokens", async function() {
    const amount = ethers.utils.parseUnits("100", decimals);

    await token.burn(amount);
    const balance = await token.balanceOf(owner.address);
    expect(balance).to.equal(initialSupply.sub(amount));
  });
});
