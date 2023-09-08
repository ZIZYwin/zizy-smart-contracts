import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { TokenVesting, ZizyERC20 } from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expectError, getNodeCurrentTime } from "../scripts/helpers/TestHelpers";

describe("TokenVesting", function() {
  let token: ZizyERC20 | Contract;
  let owner: SignerWithAddress;
  let tokenVesting: TokenVesting | Contract;
  let accounts: SignerWithAddress[];
  let scheduleCounter = 0;

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

  it("initial configurations check", async function() {
    expect(await tokenVesting.getVestingSchedulesTotalAmount()).to.equal(0, "Vesting schedules total amount should be zero");
    await expectError(tokenVesting.getVestingIdAtIndex(0), "TokenVesting: index out of bounds", "Should throw index out of bounds error");
    expect(await tokenVesting.getVestingSchedulesCountByBeneficiary(owner.address)).to.equal(0, "Initial vesting schedule count should be zero");
    await expectError(tokenVesting.withdraw(6_000_000), "TokenVesting: not enough withdrawable funds", "Should throw error when try withdraw higher amount token");
  });

  it("shouldn't deploy zero token address", async function() {
    const TokenVestingFactory = await ethers.getContractFactory("TokenVesting");
    await expectError(TokenVestingFactory.deploy(ethers.constants.AddressZero), "", "Shouldn't deploy with zero token address");
  });

  it("should return the address of the ERC20 token managed by the contract", async function() {
    const contractTokenAddress = await tokenVesting.getToken();
    expect(contractTokenAddress).to.equal(token.address);
  });

  it("should return the number of vesting schedules managed by the contract", async function() {
    const contractVestingCount = await tokenVesting.getVestingSchedulesCount();
    expect(contractVestingCount).to.equal(scheduleCounter);
  });

  it("shouldn't create vesting schedule with wrong conditions", async function() {
    const beneficiary = await accounts[0].getAddress();
    const start = (await getNodeCurrentTime()) + 3600; // 1 hour from now
    const cliff = 3600; // 1 hour
    const duration = 7200; // 2 hours
    const slicePeriodSeconds = 1800; // 30 minutes
    const revocable = true;
    const amount = 1000;

    await expectError(tokenVesting.connect(accounts[2]).createVestingSchedule(beneficiary, start, cliff, duration, slicePeriodSeconds, revocable, amount),
      "Ownable: caller is not the owner", "Shouldn't create schedule un-authorized account"
    );

    await expectError(tokenVesting.createVestingSchedule(beneficiary, start, cliff, duration, slicePeriodSeconds, revocable, 6_000_000),
      "TokenVesting: cannot create vesting schedule because not sufficient tokens", "Shouldn't create schedule with higher token amount"
    );

    await expectError(tokenVesting.createVestingSchedule(beneficiary, start, cliff, 0, slicePeriodSeconds, revocable, amount),
      "TokenVesting: duration must be > 0", "Shouldn't create schedule with zero duration"
    );

    await expectError(tokenVesting.createVestingSchedule(beneficiary, start, cliff, duration, slicePeriodSeconds, revocable, 0),
      "TokenVesting: amount must be > 0", "Shouldn't create schedule with zero amount"
    );

    await expectError(tokenVesting.createVestingSchedule(beneficiary, start, cliff, duration, 0, revocable, amount),
      "TokenVesting: slicePeriodSeconds must be >= 1", "Shouldn't create schedule with low slice period seconds"
    );

    await expectError(tokenVesting.createVestingSchedule(beneficiary, start, 100, 50, slicePeriodSeconds, revocable, amount),
      "TokenVesting: duration must be >= cliff", "Shouldn't create schedule with (duration < cliff)"
    );
  });

  it("schedule revoke & release check", async function() {
    const beneficiary = await accounts[0].getAddress();
    const start = (await getNodeCurrentTime()) - 3600; // 1 hour from now
    const cliff = 3600; // 1 hour
    const duration = 7200; // 2 hours
    const slicePeriodSeconds = 1800; // 30 minutes
    const amount = 1000;

    const revocableScheduleId = await createVestingSchedule(
      beneficiary,
      start,
      cliff,
      duration,
      slicePeriodSeconds,
      true,
      amount
    );
    const scheduleId = await createVestingSchedule(
      beneficiary,
      start,
      cliff,
      duration,
      slicePeriodSeconds,
      false,
      amount
    );

    const zaStart = (await getNodeCurrentTime()) - 30;
    const zeroAmountRevokeScheduleId = await createVestingSchedule(
      beneficiary,
      zaStart,
      1,
      2,
      1,
      true,
      amount
    );

    await expectError(tokenVesting.revoke(ethers.constants.HashZero), "", "Shouldn't revoke not exist schedule id");
    await expectError(tokenVesting.connect(accounts[2]).revoke(revocableScheduleId), "Ownable: caller is not the owner", "Shouldn't revoke any schedule with un-authorized account");
    await expectError(tokenVesting.revoke(scheduleId), "TokenVesting: vesting is not revocable", "Shouldn't revoke `not-revocable` schedule id");

    const revokeTransaction = await tokenVesting.revoke(revocableScheduleId);
    expect(revokeTransaction).to.emit(tokenVesting, "ScheduleRevoked");
    await expectError(tokenVesting.computeReleasableAmount(revocableScheduleId), "", "Shouldn't calculate revoked schedule releaseable amount");

    await expectError(tokenVesting.revoke(revocableScheduleId), "", "Shouldn't revoke already revoked schedule id");
    await expectError(tokenVesting.release(revocableScheduleId, 1), "", "Shouldn't release tokens from revoked schedule");

    await tokenVesting.connect(accounts[0]).release(zeroAmountRevokeScheduleId, amount);
    const zaRevokeTransaction = await tokenVesting.revoke(zeroAmountRevokeScheduleId);
    expect(zaRevokeTransaction).to.emit(tokenVesting, "ScheduleRevoked");
  });

  it("should create a new vesting schedule & correct withdrawable amount", async function() {
    const beneficiary = await accounts[0].getAddress();
    const start = (await getNodeCurrentTime()) + 3600; // 1 hour from now
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
    expect(await tokenVesting.getVestingIdAtIndex(0)).to.equal(scheduleId, "Indexed schedule id should be same with created schedule");
    expect((await tokenVesting.getVestingScheduleByAddressAndIndex(beneficiary, 0)).beneficiary).to.equal(beneficiary, "Beneficiary should be same");
    expect((await tokenVesting.getLastVestingScheduleForHolder(beneficiary)).beneficiary).to.equal(beneficiary, "Last schedule should be match with created schedule");

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
    const start = await getNodeCurrentTime() + 3600; // 1 hour from now
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
    const start = await getNodeCurrentTime() - 3600; // 1 hour ago
    const cliff = 0;
    const duration = 2400; // 2 hours
    const slicePeriodSeconds = 1200; // 30 minutes
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

    await tokenVesting.release(scheduleId, 250);
    await tokenVesting.connect(accounts[1]).release(scheduleId, 250);
    const releaseableAmount = await tokenVesting.computeReleasableAmount(scheduleId);
    expect(releaseableAmount.toNumber()).to.equal(500, "Releasable amount should be correct");

    await expectError(tokenVesting.connect(accounts[2]).release(scheduleId, 200), "TokenVesting: only beneficiary and owner can release vested tokens", "TokenVesting: only beneficiary and owner can release vested tokens");
    await expectError(tokenVesting.release(scheduleId, 600), "TokenVesting: cannot release tokens, not enough vested tokens", "TokenVesting: cannot release tokens, not enough vested tokens");

    const schedule = await tokenVesting.getVestingSchedule(scheduleId);
    assert.equal(schedule.released.toNumber(), 500);
  });

});
