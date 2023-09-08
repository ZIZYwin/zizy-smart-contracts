import { ethers, upgrades } from "hardhat";
import {
  CompetitionFactory,
  DepositWithdraw,
  DepositWithdrawTest,
  ZizyCompetitionTicket,
  ZizyERC20,
  ZizyPoPa
} from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { expectError } from "../scripts/helpers/TestHelpers";

describe("DepositWithdraw", function() {
  let owner: SignerWithAddress;
  let accounts: SignerWithAddress[];
  let dw: DepositWithdrawTest | Contract;
  let erc20: ZizyERC20 | Contract;
  let erc721: ZizyPoPa | Contract;

  beforeEach(async function() {
    [owner, ...accounts] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("DepositWithdrawTest");
    dw = (await upgrades.deployProxy(Factory, [], {
      initializer: "initialize"
    }) as DepositWithdrawTest);
    await dw.deployed();

    const ZizyERC20Factory = await ethers.getContractFactory("ZizyERC20");
    erc20 = (await ZizyERC20Factory.deploy("Test Token", "TTK") as ZizyERC20);
    await erc20.deployed();

    const NFTFactory = await ethers.getContractFactory("ZizyPoPa");
    erc721 = (await NFTFactory.deploy("TestNFT", "TNFT", owner.address) as ZizyPoPa);
    await erc721.deployed();
  });

  it("only initializer method checks", async function() {
    await expectError(dw.__DepositWithdraw_init_Test(), "Initializable: contract is not initializing", "Should throw error onlyInitializing methods after initialization");
    await expectError(dw.__DepositWithdraw_init_unchained_Test(), "Initializable: contract is not initializing", "Should throw error onlyInitializing methods after initialization");
  });

  it("native coin deposit check", async function() {
    await expectError(dw.connect(accounts[0]).deposit({ value: 5000 }), "Ownable: caller is not the owner", "User's shouldn't be deposit into this contract");
    expect(await dw.deposit({ value: 5000 }), "Owner should deposit into this contract").to.emit(dw, "Deposit");
  });

  it("native coin withdraw check", async function() {
    await expectError(dw.connect(accounts[0]).withdraw(5000), "Ownable: caller is not the owner", "Un-authorized account shouldn't be call withdraw method");
    await expectError(dw.connect(accounts[0]).withdrawTo(accounts[0].address, 5000), "Ownable: caller is not the owner", "Un-authorized account shouldn't be call withdraw method");
    await expectError(dw.withdraw(5000), "Insufficient native balance", "Should throw insufficient native balance exception");

    await dw.deposit({ value: 5000 });
    const withdrawTransaction = await dw.withdraw(4000);
    expect(withdrawTransaction, "Should emit `Withdraw` event after transfer completed").to.emit(dw, "Withdraw");
  });

  it("should throw an error if native coin transfer failed", async function() {
    const Factory = await ethers.getContractFactory("DepositWithdrawTest");
    const anotherContract = (await upgrades.deployProxy(Factory, [], {
      initializer: "initialize"
    }) as DepositWithdrawTest);
    await anotherContract.deployed();

    await dw.deposit({ value: 5000 });
    await expectError(dw.withdrawTo(anotherContract.address, 5000), "Native coin transfer failed", "Should throw an error if native coin transfer failed");
  });

  it("withdraw erc20 token methods check", async function() {
    await expectError(dw.connect(accounts[1]).withdrawToken(erc20.address, 100), "Ownable: caller is not the owner", "Un-authorized account shouldn't be call withdrawToken method");
    await expectError(dw.connect(accounts[1]).withdrawTokenTo(accounts[1].address, erc20.address, 100), "Ownable: caller is not the owner", "Un-authorized account shouldn't be call withdrawTokenTo method");

    const firstBalance = await erc20.balanceOf(dw.address);
    expect(firstBalance.toNumber()).to.equal(0, "Shouldn't have token balance");

    // Transfer ERC20 to deposit withdraw contract
    await erc20.transfer(dw.address, 10_000);

    const withdrawTokenTransaction = await dw.withdrawToken(erc20.address, 5_000);
    expect(withdrawTokenTransaction, "WithdrawToken call should be emit `Withdraw` event").to.emit(dw, "Withdraw");
    const secondBalance = await erc20.balanceOf(dw.address);
    expect(secondBalance.toNumber()).to.equal(5_000, "Token balance should be correct after withdrawToken method call");

    const withdrawTokenToTransaction = await dw.withdrawTokenTo(accounts[1].address, erc20.address, 5_000);
    expect(withdrawTokenToTransaction, "WithdrawTokenTo call should be emit `Withdraw` event").to.emit(dw, "Withdraw");
    const lastBalance = await erc20.balanceOf(dw.address);
    expect(lastBalance.toNumber()).to.equal(0, "Token balance should be correct after withdrawTokenTo method call");
  });

  it("withdraw erc721 token methods check", async function() {
    await expectError(dw.connect(accounts[1]).withdrawNFT(erc721.address, 55), "Ownable: caller is not the owner", "Un-authorized account shouldn't be call withdrawNFT method");
    await expectError(dw.connect(accounts[1]).withdrawNFTTo(accounts[1].address, erc721.address, 55), "Ownable: caller is not the owner", "Un-authorized account shouldn't be call withdrawNFTTo method");

    await erc721.mint(owner.address, 55); // Mint 55 ID token for owner account
    await erc721.mint(owner.address, 56); // Mint 56 ID token for owner account
    await expectError(dw.withdrawNFT(erc721.address, 55), "This contract is not owner of given tokenId", "Should throw error when trying to transfer un-owned erc721 token");
    await expectError(dw.withdrawNFTTo(owner.address, erc721.address, 56), "This contract is not owner of given tokenId", "Should throw error when trying to transfer un-owned erc721 token");

    await erc721.transferFrom(owner.address, dw.address, 55); // Transfer NFT into DW contract
    await erc721.transferFrom(owner.address, dw.address, 56); // Transfer NFT into DW contract
    expect(await erc721.ownerOf(55)).to.equal(dw.address, "Deposit withdraw contract should be owner of transferred token");
    expect(await erc721.ownerOf(56)).to.equal(dw.address, "Deposit withdraw contract should be owner of transferred token");

    expect(await dw.withdrawNFT(erc721.address, 55), "Should emit `Withdraw` event after NFT withdraw call").to.emit(dw, "Withdraw");
    expect(await dw.withdrawNFTTo(accounts[0].address, erc721.address, 56), "Should emit `Withdraw` event after NFT withdraw call").to.emit(dw, "Withdraw");
    expect(await erc721.ownerOf(55)).to.equal(owner.address, "NFT owner should be transferred address");
    expect(await erc721.ownerOf(56)).to.equal(accounts[0].address, "NFT owner should be transferred address");
  });

});
