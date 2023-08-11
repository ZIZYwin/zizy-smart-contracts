import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { TokenVesting, ZizyERC20 } from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("TokenVesting", function() {
  let token: ZizyERC20 | Contract;
  let owner: SignerWithAddress;
  let tokenVesting: TokenVesting | Contract;
  let accounts: SignerWithAddress[];
  let scheduleCounter = 0;

  const getCurrentTime = async () => {
    return (await ethers.provider.getBlock("latest")).timestamp;
  };

  const createVestingSchedule = async (
    beneficiary: string,
    start: number,
    cliff: number,
    duration: number,
    slicePeriodSeconds: number,
    revocable: boolean,
    amount: number
  ) => {
    const scheduleId = await tokenVesting
      .computeNextVestingScheduleIdForHolder(beneficiary);

    await tokenVesting.createVestingSchedule(
      beneficiary,
      start,
      cliff,
      duration,
      slicePeriodSeconds,
      revocable,
      amount
    );

    scheduleCounter++;

    return scheduleId;
  };

  beforeEach(async function() {
    [owner, ...accounts] = await ethers.getSigners();

    const ERC20Factory = await ethers.getContractFactory("ZizyERC20");
    token = (await ERC20Factory.deploy("ZIZY", "ZIZY") as ZizyERC20);
    await token.deployed();

    const TokenVestingFactory = await ethers.getContractFactory("TokenVesting");
    tokenVesting = await TokenVestingFactory.deploy(token.address);
    await tokenVesting.deployed();

    await token.transfer(tokenVesting.address, 5_000_000); // Send 5M token into vesting contract
  });

  it("should return the address of the ERC20 token managed by the contract", async function() {
    const contractTokenAddress = await tokenVesting.getToken();
    expect(contractTokenAddress).to.equal(token.address);
  });

  it("should return the number of vesting schedules managed by the contract", async function() {
    const contractVestingCount = await tokenVesting.getVestingSchedulesCount();
    expect(contractVestingCount).to.equal(scheduleCounter);
  });

  it("should create a new vesting schedule & correct withdrawable amount", async function() {
    const beneficiary = await accounts[0].getAddress();
    const start = (await getCurrentTime()) + 3600; // 1 hour from now
    const cliff = 3600; // 1 hour
    const duration = 7200; // 2 hours
    const slicePeriodSeconds = 1800; // 30 minutes
    const revocable = true;
    const amount = 1000;
    const initialWithdrawableAmount = await tokenVesting.getWithdrawableAmount();

    const scheduleId = await createVestingSchedule(
      beneficiary,
      start,
      cliff,
      duration,
      slicePeriodSeconds,
      revocable,
      amount
    );

    const lastWithdrawableAmount = await tokenVesting.getWithdrawableAmount();

    expect(initialWithdrawableAmount.sub(amount).toString(), "Withdrawable amount should correct after schedule create").to.equal(lastWithdrawableAmount.toString());

    const schedule = await tokenVesting.getVestingSchedule(scheduleId);

    expect(schedule.initialized, "Initialized flag should be true").to.equal(true);
    expect(schedule.beneficiary, "Beneficiary address should match").to.equal(beneficiary);
    expect(schedule.cliff, "Cliff time should match").to.equal(start + cliff);
    expect(schedule.start, "Start time should match").to.equal(start);
    expect(schedule.duration, "Vesting duration should match").to.equal(duration);
    expect(schedule.slicePeriodSeconds, "Slice period should match").to.equal(slicePeriodSeconds);
    expect(schedule.revocable, "Revocable flag should match").to.equal(revocable);
    expect(schedule.amountTotal.toString(), "Total amount should match").to.equal(amount.toString());
    expect(schedule.released, "Released tokens should be 0").to.equal(ethers.BigNumber.from(0));
    expect(schedule.revoked, "Revoked flag should be false").to.equal(false);

  });

  it("should revoke a vesting schedule", async function() {
    const beneficiary = accounts[1];
    const start = await getCurrentTime() + 3600; // 1 hour from now
    const cliff = 3600; // 1 hour
    const duration = 7200; // 2 hours
    const slicePeriodSeconds = 1800; // 30 minutes
    const revocable = true;
    const amount = 1000;

    const scheduleId = await createVestingSchedule(
      beneficiary.address,
      start,
      cliff,
      duration,
      slicePeriodSeconds,
      revocable,
      amount
    );

    await tokenVesting.revoke(scheduleId);

    const schedule = await tokenVesting.getVestingSchedule(scheduleId);
    assert.equal(schedule.revoked, true);
  });

  it("should withdraw tokens", async function() {
    const amount = 500;

    const initialContractBalance = await token.balanceOf(tokenVesting.address);
    const initialOwnerBalance = await token.balanceOf(owner.address);

    await tokenVesting.withdraw(amount);

    const finalContractBalance = await token.balanceOf(tokenVesting.address);
    const finalOwnerBalance = await token.balanceOf(owner.address);

    assert.equal(
      finalContractBalance.toString(),
      initialContractBalance.sub(amount).toString()
    );
    assert.equal(
      finalOwnerBalance.toString(),
      initialOwnerBalance.add(amount).toString()
    );
  });

  it("should release vested tokens", async function() {
    const beneficiary = accounts[1];
    const start = await getCurrentTime() - 3600; // 1 hour ago
    const cliff = 0;
    const duration = 7200; // 2 hours
    const slicePeriodSeconds = 1800; // 30 minutes
    const revocable = true;
    const amount = 1000;

    const scheduleId = await createVestingSchedule(
      beneficiary.address,
      start,
      cliff,
      duration,
      slicePeriodSeconds,
      revocable,
      amount
    );

    await tokenVesting.release(scheduleId, 500);

    const schedule = await tokenVesting.getVestingSchedule(scheduleId);
    assert.equal(schedule.released.toNumber(), 500);
  });

});
