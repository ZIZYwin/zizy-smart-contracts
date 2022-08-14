import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("ZizyERC20", function() {
  // Constructor arguments
  const tokenName = "Zizy";
  const tokenSymbol = "ZIZY";

  let erc20: Contract;
  let erc20Factory: ContractFactory;
  let owner: SignerWithAddress;
  let acc1: SignerWithAddress;
  let acc2: SignerWithAddress;
  let acc3: SignerWithAddress;

  beforeEach(async function() {
    [owner, acc1, acc2, acc3] = await ethers.getSigners();

    // We get the contract to deploy
    erc20Factory = await ethers.getContractFactory("ZizyERC20");

    // Deploy the contract
    erc20 = await erc20Factory.deploy(tokenName, tokenSymbol);

    // Wait contract deploy process for complete
    await erc20.deployed();
  });

  it("Basic ERC20 Parameters", async function() {
    expect(await erc20.decimals(), "Token decimals").to.equal(8);
    expect(await erc20.name(), "Token name").to.equal(tokenName);
    expect(await erc20.symbol(), "Token symbol").to.equal(tokenSymbol);
  });

  it("Owner Balance / Total Supply / Update balances after transfers", async function() {
    const ownerBalance = await erc20.balanceOf(owner.address);
    expect(await erc20.totalSupply(), "Total supply").to.equal(ownerBalance);

    // Transfer to acc1
    await erc20.transfer(acc1.address, 200);

    // Transfer to acc2
    await erc20.transfer(acc2.address, 100);

    // Balance checks
    const finalOwnerBalance = await erc20.balanceOf(owner.address);
    expect(finalOwnerBalance).to.equal(ownerBalance.sub(300));

    const acc1Balance = await erc20.balanceOf(acc1.address);
    expect(acc1Balance).to.equal(200);

    const acc2Balance = await erc20.balanceOf(acc2.address);
    expect(acc2Balance).to.equal(100);
  });

  it("Pause Functionality", async function() {
    // Pause
    await erc20.pause();

    // TODO: Can't catch reverted transaction
    //expect(await erc20.transfer(acc1.address, 100, {gasLimit: 100000})).to.be.reverted;

    // Is paused ?
    expect(await erc20.paused()).to.equal(true);

    // Un-pause
    await erc20.unpause();

    // Transfer
    await erc20.transfer(acc1.address, 50);
    expect(await erc20.balanceOf(acc1.address)).to.equal(50);

    // Is paused ?
    expect(await erc20.paused()).to.equal(false);
  });

  it("Mint / Burn Functionality", async function() {
    const ownerBalance = await erc20.balanceOf(owner.address);

    await erc20.burn(500);
    expect(await erc20.balanceOf(owner.address), "Burn").to.equal(ownerBalance.sub(500));

    await erc20.mint(owner.address, 500);
    expect(await erc20.balanceOf(owner.address), "Mint").to.equal(ownerBalance);
  });

});
