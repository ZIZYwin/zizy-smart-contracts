import { assert, expect } from "chai";
import {
  CompetitionFactory,
  StakeRewards,
  TicketDeployer,
  ZizyCompetitionStaking,
  ZizyCompetitionTicket,
  ZizyERC20,
  ZizyPoPa,
  ZizyPoPaFactory,
  ZizyRewardsHub
} from "../typechain-types";
import { BigNumber, Contract, ContractTransaction } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { upgrades, ethers } = require("hardhat");

//region Interfaces
interface IContracts {
  zizy: ZizyERC20 | Contract,
  usdt: ZizyERC20 | Contract,
  nft: ZizyPoPa | Contract,
  compFactory: CompetitionFactory | Contract,
  stakeRewards: StakeRewards | Contract,
  ticketDeployer: TicketDeployer | Contract,
  staking: ZizyCompetitionStaking | Contract,
  popaFactory: ZizyPoPaFactory | Contract,
  rewardsHub: ZizyRewardsHub | Contract,
}

interface ISigners {
  owner: SignerWithAddress,
  rewardDefiner: SignerWithAddress,
  ticketMinter: SignerWithAddress,
  popaMinter: SignerWithAddress,
  feeReceiver: SignerWithAddress,
  paymentReceiver: SignerWithAddress,
  user1: SignerWithAddress,
  user2: SignerWithAddress,
  user3: SignerWithAddress,
}

//endregion

//region Helpers
const getEthereumBalance = async (address: string): Promise<BigNumber> => {
  return await ethers.provider.getBalance(address);
};

const getRandomInteger = (minimum: number, maximum: number) => {
  return Math.round(Math.random() * (maximum - minimum) + minimum);
};

const getTimestamp = () => {
  return Math.floor((new Date()).getTime() / 1000);
};

const day = (dayCount: number) => {
  return (dayCount * 24 * 60 * 60);
};

const generateRandomTickets = (ticketCount: number): number[] => {
  const tickets = [];
  do {
    // Generate random ticket number between 0-999999
    const ticketNumber = getRandomInteger(0, 999999);

    if (!tickets.includes(ticketNumber)) {
      tickets.push(ticketNumber);
    }

  } while (tickets.length < ticketCount);

  return tickets;
};

const sumArray = (arr: number[]): number => {
  return arr.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
};

const generateSingleTicket = (existTickets: number[]): number => {
  let ticketNumber;
  do {
    ticketNumber = getRandomInteger(0, 999999);
    if (!existTickets.includes(ticketNumber)) {
      return ticketNumber;
    }
  } while (existTickets.includes(ticketNumber));
};
//endregion

//region Test globals
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

// noinspection TypeScriptValidateTypes
const signers: ISigners = {};

const token = {
  initialSupply: ethers.BigNumber.from(150000000).mul(ethers.BigNumber.from(10).pow(8)),
  decimals: 8,
  name: "ZIZY",
  symbol: "ZIZY"
};

// noinspection TypeScriptValidateTypes
const contracts: IContracts = {};

enum RewardType {
  Token = 0,
  NFT = 1,
  Native = 2,
}

//endregion

describe("Full System Test", function() {

  beforeEach(async function() {
    //region Prepare accounts
    const [owner, rewardDefiner, ticketMinter, popaMinter, feeReceiver, paymentReceiver, user1, user2, user3] = await ethers.getSigners();
    signers.owner = owner;
    signers.rewardDefiner = rewardDefiner;
    signers.ticketMinter = ticketMinter;
    signers.popaMinter = popaMinter;
    signers.feeReceiver = feeReceiver;
    signers.paymentReceiver = paymentReceiver;
    signers.user1 = user1;
    signers.user2 = user2;
    signers.user3 = user3;
    //endregion

    //region Deploy - Contracts
    const ZizyERC20Factory = await ethers.getContractFactory("ZizyERC20");
    contracts.zizy = (await ZizyERC20Factory.deploy(token.name, token.symbol) as ZizyERC20);
    await contracts.zizy.deployed();

    const CompFactory = await ethers.getContractFactory("CompetitionFactory");
    contracts.compFactory = (await upgrades.deployProxy(CompFactory, [signers.paymentReceiver.address, signers.ticketMinter.address], {
      initializer: "initialize"
    }) as CompetitionFactory);
    await contracts.compFactory.deployed();

    const StakingFactory = await ethers.getContractFactory("ZizyCompetitionStaking");
    contracts.staking = (await upgrades.deployProxy(StakingFactory, [contracts.zizy.address, signers.feeReceiver.address], {
      initializer: "initialize"
    }) as ZizyCompetitionStaking);
    await contracts.staking.deployed();

    const TicketDeployer = await ethers.getContractFactory("TicketDeployer");
    contracts.ticketDeployer = (await TicketDeployer.deploy(contracts.compFactory.address) as TicketDeployer);
    await contracts.ticketDeployer.deployed();

    const PopaFactory = await ethers.getContractFactory("ZizyPoPaFactory");
    contracts.popaFactory = (await upgrades.deployProxy(PopaFactory, [contracts.compFactory.address], {
      initializer: "initialize"
    }) as ZizyPoPaFactory);
    await contracts.popaFactory.deployed();

    const RewardsHubFactory = await ethers.getContractFactory("ZizyRewardsHub");
    contracts.rewardsHub = (await upgrades.deployProxy(RewardsHubFactory, [signers.rewardDefiner.address], {
      initializer: "initialize"
    }) as ZizyRewardsHub);
    await contracts.rewardsHub.deployed();

    const StakeRewardsFactory = await ethers.getContractFactory("StakeRewards");
    contracts.stakeRewards = (await upgrades.deployProxy(StakeRewardsFactory, [contracts.staking.address, signers.rewardDefiner.address], {
      initializer: "initialize"
    }) as StakeRewards);
    await contracts.stakeRewards.deployed();
    //endregion

    //region Initial setup for contracts
    await contracts.staking.setCompetitionFactory(contracts.compFactory.address);
    await contracts.staking.setLockModerator(contracts.stakeRewards.address);
    await contracts.compFactory.setStakingContract(contracts.staking.address);
    await contracts.compFactory.setTicketDeployer(contracts.ticketDeployer.address);
    await contracts.popaFactory.setPopaMinter(signers.popaMinter.address);
    //endregion

    //region Deploy dummy token & Dummy NFT
    const USDTFactory = await ethers.getContractFactory("ZizyERC20");
    contracts.usdt = (await USDTFactory.deploy("Tether", "USDT") as ZizyERC20);
    await contracts.usdt.deployed();

    const NFTFactory = await ethers.getContractFactory("ZizyPoPa");
    contracts.nft = (await NFTFactory.deploy("TestNFT", "TNFT", owner.address) as ZizyPoPa);
    await contracts.nft.deployed();
    //endregion

    //region Transfer ZIZY & USDT & Test NFT & Native coin
    await contracts.zizy.transfer(signers.user1.address, 20_000); // Transfer zizy token to user1
    await contracts.zizy.connect(signers.user1).approve(contracts.staking.address, 20_000); // Give allowance to staking contract

    await contracts.usdt.transfer(signers.user1.address, 50_000); // Transfer usdt token to user1
    await contracts.usdt.transfer(contracts.rewardsHub.address, 50_000); // Transfer USDT to rewards hub contract
    await contracts.usdt.transfer(contracts.stakeRewards.address, 50_000); // Transfer USDT to stake rewards contract
    await contracts.usdt.connect(signers.user1).approve(contracts.compFactory.address, 50_000); // Give allowance to `CompetitionFactory` contract for buy tickets

    await contracts.zizy.transfer(contracts.stakeRewards.address, 50_000); // Transfer ZIZY to stake rewards contract
    await contracts.rewardsHub.deposit({ value: 5000 }); // Send 5000 unit ethereum into rewards hub contract

    await contracts.nft.mint(contracts.rewardsHub.address, 333); // Mint & Transfer test NFT to rewards hub contract
    await contracts.nft.mint(contracts.rewardsHub.address, 334); // Mint & Transfer test NFT to rewards hub contract
    await contracts.nft.mint(contracts.rewardsHub.address, 335); // Mint & Transfer test NFT to rewards hub contract
    //endregion
  });

  it("should have correct initial configurations", async function() {
    // Contract address definitions
    expect(await contracts.staking.competitionFactory()).to.be.equal(contracts.compFactory.address, "Incorrect competition factory address");
    expect(await contracts.compFactory.stakingContract()).to.be.equal(contracts.staking.address, "Incorrect staking contract address");
    expect(await contracts.compFactory.ticketDeployer()).to.be.equal(contracts.ticketDeployer.address, "Incorrect ticket deployer address");
    expect(await contracts.popaFactory.competitionFactory()).to.be.equal(contracts.compFactory.address, "Incorrect POPA competition factory address");
    expect(await contracts.stakeRewards.stakingContract()).to.be.equal(contracts.staking.address, "Incorrect stake rewards staking contract address");
    expect(await contracts.staking.lockModerator()).to.be.equal(contracts.stakeRewards.address, "Incorrect lock moderator on staking contract");

    // Roled accounts
    expect(await contracts.compFactory.ticketMinter()).to.be.equal(signers.ticketMinter.address, "Incorrect ticket minter address");
    expect(await contracts.compFactory.paymentReceiver()).to.be.equal(signers.paymentReceiver.address, "Incorrect payment receiver address");
    expect(await contracts.staking.feeAddress()).to.be.equal(signers.feeReceiver.address, "Incorrect fee address");
    expect(await contracts.rewardsHub.rewardDefiner()).to.be.equal(signers.rewardDefiner.address, "Incorrect reward definer address");
    expect(await contracts.stakeRewards.rewardDefiner()).to.be.equal(signers.rewardDefiner.address, "Incorrect stake rewards reward definer address");

    // ZIZY token address
    expect(await contracts.staking.stakeToken()).to.be.equal(contracts.zizy.address, "Incorrect ZIZY token address");
  });

  it("should have correct period & competition states", async function() {
    const timestamp = getTimestamp();
    const initials = {
      activePeriod: (await contracts.compFactory.activePeriod()),
      totalPeriodCount: (await contracts.compFactory.totalPeriodCount()),
      totalCompetitionCount: (await contracts.compFactory.totalCompetitionCount()),
      deployedTicketContractCount: (await contracts.ticketDeployer.getDeployedContractCount())
    };
    const period = {
      id: 1,
      startTime: timestamp,
      tBuyStart: timestamp + 5,
      tBuyEnd: timestamp + 10,
      endTime: timestamp + 60
    };
    const competition = {
      id: 1,
      name: "Zizy Competition 1",
      symbol: "ZTIC"
    };

    expect(initials.activePeriod.toNumber()).to.be.equal(0, "Incorrect initial active period number");
    expect(initials.totalCompetitionCount.toNumber()).to.be.equal(0, "Incorrect initial total competition count");
    expect(initials.totalPeriodCount.toNumber()).to.be.equal(0, "Incorrect initial total period count");
    expect(initials.deployedTicketContractCount.toNumber()).to.be.equal(0, "Incorrect initial deployed ticket contract count");

    // Create new period
    await contracts.compFactory.createPeriod(period.id, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd);

    expect((await contracts.compFactory.totalPeriodCount()).toNumber()).to.be.equal(initials.totalPeriodCount.toNumber() + 1, "Incorrect total period count");

    // Fetch period data from smart contract
    const cPeriod = await contracts.compFactory.getPeriod(period.id);

    // Check period configuration
    expect(cPeriod.startTime.toNumber()).to.be.equal(period.startTime, "Incorrect start time");
    expect(cPeriod.endTime.toNumber()).to.be.equal(period.endTime, "Incorrect end time");
    expect(cPeriod.ticketBuyStartTime.toNumber()).to.be.equal(period.tBuyStart, "Incorrect ticket buy start time");
    expect(cPeriod.ticketBuyEndTime.toNumber()).to.be.equal(period.tBuyEnd, "Incorrect ticket buy end time");
    expect(cPeriod.competitionCount.toNumber()).to.be.equal(0, "Incorrect competition count");
    expect(cPeriod.isOver).to.be.equal(false, "Period should not be over");
    expect(cPeriod._exist).to.be.equal(true, "Period should exist");

    await contracts.compFactory.updatePeriod(period.id, (period.startTime + 5), (period.endTime + 5), (period.tBuyStart + 5), (period.tBuyEnd + 5));

    // Fetch updated period data from smart contract
    const cPeriod2 = await contracts.compFactory.getPeriod(period.id);

    // Check updated period configuration
    expect(cPeriod2.startTime.toNumber()).to.be.equal((period.startTime + 5), "Incorrect updated start time");
    expect(cPeriod2.endTime.toNumber()).to.be.equal((period.endTime + 5), "Incorrect updated end time");
    expect(cPeriod2.ticketBuyStartTime.toNumber()).to.be.equal((period.tBuyStart + 5), "Incorrect updated ticket buy start time");
    expect(cPeriod2.ticketBuyEndTime.toNumber()).to.be.equal((period.tBuyEnd + 5), "Incorrect updated ticket buy end time");

    // Create competition
    await contracts.compFactory.createCompetition(period.id, competition.id, competition.name, competition.symbol);

    // Check competition ticket & competition count
    expect(await contracts.ticketDeployer.getDeployedContractCount()).to.be.equal((initials.deployedTicketContractCount + 1), "Incorrect deployed ticket contract count");
    expect(await contracts.compFactory.getPeriodCompetitionCount(period.id)).to.be.equal(1, "Incorrect competition count on period");

    // Fetch competition data from smart contract
    const cCompetition = await contracts.compFactory.getPeriodCompetition(period.id, competition.id);
    const ticketFactory = await ethers.getContractFactory("ZizyCompetitionTicket");
    const ticketContract = (await ticketFactory.attach(cCompetition.ticket) as ZizyCompetitionTicket);

    // Check ticket contract metadata
    expect(await ticketContract.name()).to.be.equal(competition.name, "Incorrect ticket nft name");
    expect(await ticketContract.symbol()).to.be.equal(competition.symbol, "Incorrect ticket nft symbol");
    expect((await ticketContract.totalSupply()).toNumber()).to.be.equal(0, "Incorrect ticket total supply");
  });

  it("staking cooling-off settings / stake fee settings / calculate un-stake amount", async function() {
    const ts = getTimestamp();
    const stakeAmount = 5000;

    //region Cooling off
    await contracts.staking.updateCoolingOffSettings(10, 3, 5);
    expect(await contracts.staking.coolingPercentage()).to.be.equal(10, "Incorrect unstake fee percentage");
    expect(await contracts.staking.coolingDelay()).to.be.equal(day(3), "Incorrect cooling day");
    expect(await contracts.staking.coolestDelay()).to.be.equal(day(5), "Incorrect coolest day");
    //endregion

    //region Stake fee percentage check & Stake fee transfer check
    await contracts.staking.setStakeFeePercentage(3); // Set initial stake percentage = 3%
    const initialStakeFee = await contracts.staking.stakeFeePercentage();
    await contracts.staking.setStakeFeePercentage(initialStakeFee - 1); // Updated stake fee = 2%
    const updatedStakeFee = await contracts.staking.stakeFeePercentage();
    expect(updatedStakeFee).to.be.equal(initialStakeFee - 1, "Incorrect updated stake fee");
    //endregion

    //region Unstake calculation when active period does not exist
    let [fee, amount] = await contracts.staking.calculateUnStakeAmounts(stakeAmount);
    expect(fee.toNumber()).to.be.equal(0, "Should equal zero when active period does not exist");
    expect(amount.toNumber()).to.be.equal(stakeAmount, "Should equal given amount when active period does not exist");
    //endregion

    //region Unstake calculation on coolest days
    await contracts.compFactory.createPeriod(1, ts - 1, ts + day(8), ts, ts + 50); // Create dummy period for test first day calculation
    await contracts.compFactory.setActivePeriod(1); // Set period active
    [fee, amount] = await contracts.staking.calculateUnStakeAmounts(stakeAmount);
    expect(fee.toNumber()).to.be.equal(stakeAmount * .1, "Incorrect unstake fee on coolest days");
    expect(amount.toNumber()).to.be.equal(stakeAmount * .9, "Incorrect unstake receiveable amount on coolest days");
    //endregion

    //region Stake
    expect((await contracts.zizy.balanceOf(signers.feeReceiver.address)).toNumber()).to.be.equal(0, "Incorrect initial fee receiver zizy balance");

    await contracts.staking.connect(signers.user1).stake(stakeAmount); // Stake
    expect((await contracts.zizy.balanceOf(signers.feeReceiver.address)).toNumber()).to.be.equal(stakeAmount * .02, "Incorrect stake fee transfer amount");
    expect((await contracts.staking.totalStaked()).toNumber()).to.be.equal(stakeAmount * .98, "Incorrect total staked amount");
    //endregion

    //region Un-stake
    const initialFeeReceiverBalance = await contracts.zizy.balanceOf(signers.feeReceiver.address);

    const initialBalance = await contracts.zizy.balanceOf(signers.user1.address);
    const stakeBalance = await contracts.staking.balanceOf(signers.user1.address);
    await contracts.staking.connect(signers.user1).unStake(stakeBalance);
    const stakeBalanceAfterUnstake = await contracts.staking.balanceOf(signers.user1.address);
    expect(stakeBalanceAfterUnstake.toNumber()).to.equal(0, "Stake balance should be zero after fully unstake");
    const lastBalance = await contracts.zizy.balanceOf(signers.user1.address);

    const lastFeeReceiverBalance = await contracts.zizy.balanceOf(signers.feeReceiver.address);

    const unstakeFee = (initialBalance.add(stakeBalance).sub(lastBalance));

    expect(initialFeeReceiverBalance.add(unstakeFee).toString()).to.equal(lastFeeReceiverBalance.toString(), "Incorrect fee receiver balance after un-stake");
    //end
  });

  it("should set and get booster correctly", async function() {
    const boosterId = 1;
    const boosterType = 0; // BoosterType.HoldingPOPA
    const contractAddress = "0x1234567890123456789012345678901234567890";
    const amount = 0;
    const boostPercentage = 10;

    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, contractAddress, amount, boostPercentage);

    const booster = await contracts.stakeRewards.getBooster(boosterId);
    expect(booster.boosterType).to.equal(boosterType);
    expect(booster.contractAddress).to.equal(contractAddress);
    expect(booster.amount).to.equal(amount);
    expect(booster.boostPercentage).to.equal(boostPercentage);
  });

  it("should remove booster correctly", async function() {
    const boosterId = 1;
    const boosterType = 0; // BoosterType.HoldingPOPA
    const amount = 0;
    const boostPercentage = 10;

    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, contracts.nft.address, amount, boostPercentage); // Remove test & doesn't require real popa contract address
    await contracts.stakeRewards.connect(signers.rewardDefiner).removeBooster(boosterId);

    const booster = await contracts.stakeRewards.getBooster(boosterId);
    expect(booster._exist).to.be.false;
  });

  it("should calculate account boost percentage correctly", async function() {
    await contracts.compFactory.createPeriod(1, 0, 4, 1, 2); // Just create useless period
    await contracts.compFactory.setActivePeriod(1);

    const boosterId = 1;
    const boosterType = 1; // BoosterType.StakingBalance
    const contractAddress = ethers.constants.AddressZero;
    const amount = 100;
    const boostPercentage = 10;

    await contracts.staking.connect(signers.user1).stake(5000);
    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, contractAddress, amount, boostPercentage);

    const rewardId = 1;
    const vestingIndex = 0;

    const calculatedPercentage = await contracts.stakeRewards.getAccountBoostPercentage(signers.user1.address, rewardId, vestingIndex);
    expect(calculatedPercentage).to.equal(boostPercentage);
  });

  it("deposit native coin on stake rewards", async function() {
    const initialBalance = await getEthereumBalance(contracts.stakeRewards.address);
    const amount = ethers.utils.parseEther("1.0");

    await contracts.stakeRewards.deposit({ value: amount });

    const newBalance = await getEthereumBalance(contracts.stakeRewards.address);
    expect(newBalance).to.equal(initialBalance.add(amount), "Deposit native coin should work correctly");
  });

  it("withdraw native coin from stake rewards", async function() {
    const initialBalance = await getEthereumBalance(contracts.stakeRewards.address);
    const amount = ethers.utils.parseEther('1.0');
    await contracts.stakeRewards.deposit({ value: amount });

    await contracts.stakeRewards.withdrawTo(signers.user3.address, amount);

    const newBalance = await getEthereumBalance(contracts.stakeRewards.address);
    expect(newBalance).to.equal(initialBalance, "Incorrect native coin balance after withdraw");
  });

  it("system functionality", async function() {
    const chainId = await contracts.rewardsHub.chainId();
    const timestamp = getTimestamp();
    const period = {
      id: 1,
      startTime: timestamp,
      tBuyStart: timestamp,
      tBuyEnd: timestamp + 300,
      endTime: timestamp + 600
    };
    const competition = {
      id: 1,
      name: "Zizy Competition 1",
      symbol: "ZTIC",
      tiers: {
        mins: [100, 4001, 10001],
        maxs: [4000, 10000, 50000],
        allocations: [50, 100, 150]
      }
    };
    const stakeAmount = 5000;
    const initialSnapshotId = (await contracts.staking.getSnapshotId()).toNumber();

    //region Create period
    await contracts.compFactory.createPeriod(period.id, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd);
    expect((await contracts.compFactory.totalPeriodCount()).toNumber()).to.equal(1, "Period count should be correct");
    //endregion

    //region Create competition
    await contracts.compFactory.createCompetition(period.id, competition.id, competition.name, competition.symbol);
    expect((await contracts.compFactory.getPeriodCompetitionCount(period.id)).toNumber()).to.equal(1, "Period competition count should be correct");
    //endregion

    //region Set active period
    const initialPeriodId = ((await contracts.compFactory.activePeriod()).toNumber());
    await contracts.compFactory.setActivePeriod(period.id);
    const activePeriodId = ((await contracts.compFactory.activePeriod()).toNumber());
    const periodInitialSnapshot = (await contracts.staking.getSnapshotId()).toNumber();

    expect(initialPeriodId).to.equal(0, "Initial period ID should be zero");
    expect(activePeriodId).to.equal(period.id, "Active period ID should be correct");
    expect(initialSnapshotId + 1).to.equal(periodInitialSnapshot, "Period first snapshot should higher than initial snapshot id");
    //endregion

    //region Stake for competition
    await contracts.staking.connect(signers.user1).stake(stakeAmount); // Stake
    //endregion

    //region Take snapshot
    await contracts.staking.snapshot();
    const newSnapshotId = (await contracts.staking.getSnapshotId()).toNumber();
    expect(initialSnapshotId + 2).to.equal(newSnapshotId, "New snapshot id should be equal initial snapshot + 2");
    //endregion

    //region Set competition config (Payment, Allocation tiers, Snapshot range)
    const ticketPrice = 2;

    // Set competition snapshot range for calculate allocation tiers
    await contracts.compFactory.setCompetitionSnapshotRange(period.id, competition.id, newSnapshotId, newSnapshotId);

    // Set competition payment config & price (1 Ticket = 2 unit USDT)
    await contracts.compFactory.setCompetitionPayment(period.id, competition.id, contracts.usdt.address, ticketPrice);

    // Set competition allocation tiers
    await contracts.compFactory.setCompetitionTiers(period.id, competition.id, competition.tiers.mins, competition.tiers.maxs, competition.tiers.allocations);

    const cComp = await contracts.compFactory.getPeriodCompetition(period.id, competition.id);

    //region Get (on-chain deployed) competition ticket contract
    const CompetitionTicketContractFactory = await ethers.getContractFactory("ZizyCompetitionTicket");
    const competitionTicket = (await CompetitionTicketContractFactory.attach(cComp.ticket) as ZizyCompetitionTicket);

    expect((await competitionTicket.totalSupply()).toNumber()).to.equal(0, "Competition ticket total supply should be zero");
    expect(await competitionTicket.name()).to.equal(competition.name, "Competition ticket NFT name should be correct");
    expect(await competitionTicket.symbol()).to.equal(competition.symbol, "Competition ticket NFT symbol should be correct");
    //endregion

    expect(cComp._exist).to.equal(true, "Competition should exist");
    expect(cComp.ticketSold).to.equal(0, "Competition sold ticket count should be zero");
    expect(cComp.sellToken).to.equal(contracts.usdt.address, "Competition ticket payment token should be correct");
    expect(cComp.ticketPrice.toNumber()).to.equal(ticketPrice, "Ticket price should be correct");
    expect(cComp.snapshotMin).to.equal(newSnapshotId, "Competition snapshotMin should be correct");
    expect(cComp.snapshotMax).to.equal(newSnapshotId, "Competition snapshotMax should be correct");
    expect(cComp.snapshotMax).to.equal(newSnapshotId, "Competition snapshotMax should be correct");

    const [initialStakeAverage, isCalculated] = await contracts.staking.getPeriodSnapshotsAverage(signers.user1.address, period.id, newSnapshotId, newSnapshotId);
    expect(initialStakeAverage.toNumber()).to.equal(0, "Stake average should be zero before range calculation");
    expect(isCalculated).to.equal(false, "Is calculated should be false");

    // Calculate snapshot averages for user
    await contracts.staking.connect(signers.user1).calculatePeriodStakeAverage();

    const userAllocation1 = await contracts.compFactory.getAllocation(signers.user1.address, period.id, competition.id);

    expect(userAllocation1.hasAllocation).to.equal(true, "Has allocation should be true after calculate method trigger");
    expect(userAllocation1.max).to.equal(100, "User max allocation should be correct");
    expect(userAllocation1.bought).to.equal(0, "User bought ticket count should be correct");
    //endregion

    //region Buy ticket
    const paymentReceiverInitialBalance = await contracts.usdt.balanceOf(signers.paymentReceiver.address);
    const buyCounts = [5, 10];

    // Try overbuy
    try {
      await contracts.compFactory.connect(signers.user1).buyTicket(period.id, competition.id, (userAllocation1.max + 1));
      assert.fail("Shouldn't buy ticket over maximum limit");
    } catch (e: Error) {
      expect(e.message).to.contain("Max allocation limit exceeded", "Shouldn't buy ticket over maximum limit");
    }

    // Buy 5 ticket first
    await contracts.compFactory.connect(signers.user1).buyTicket(period.id, competition.id, buyCounts[0]);
    const userAllocation2 = await contracts.compFactory.getAllocation(signers.user1.address, period.id, competition.id);

    expect(userAllocation2.bought).to.equal(buyCounts[0], "Bought ticket count should be correct after first buy");
    expect((await contracts.popaFactory.claimableCheck(signers.user1.address, period.id))).to.equal(false, "User shouldnt be available for claim popa. Required participation rate doesn't match");

    const paymentReceiverBalanceAfterBuyTicket = await contracts.usdt.balanceOf(signers.paymentReceiver.address);
    const expectedBalance = (buyCounts[0] * ticketPrice);
    expect(paymentReceiverInitialBalance.toNumber()).to.equal(0, "Payment receiver initial balance should be zero");
    expect(expectedBalance).to.equal(paymentReceiverBalanceAfterBuyTicket.toNumber(), "Payment receiver current balance should be correct");

    // Buy 10 ticket
    await contracts.compFactory.connect(signers.user1).buyTicket(period.id, competition.id, buyCounts[1]);
    const userAllocation3 = await contracts.compFactory.getAllocation(signers.user1.address, period.id, competition.id);
    expect(userAllocation3.bought).to.equal((buyCounts[0] + buyCounts[1]), "User allocations should correct");
    //endregion

    //region Generate & Send tickets
    const boughtTicketCount = sumArray(buyCounts);
    let tickets = generateRandomTickets(boughtTicketCount);
    let singleTicket = tickets.pop();

    //region Mint Batch
    // Try to mint unauthorized account
    try {
      await contracts.compFactory.connect(signers.user2).mintBatchTicket(period.id, competition.id, signers.user1.address, tickets);
      assert.fail("Should throw error when try to mint tickets with unauthorized account");
    } catch (e: Error) {
      expect(e.message).to.contain("Only call from minter");
    }

    // Mint authorized account
    await contracts.compFactory.connect(signers.ticketMinter).mintBatchTicket(period.id, competition.id, signers.user1.address, tickets);
    //endregion

    //region Mint single
    // Try to mint unauthorized account
    try {
      await contracts.compFactory.connect(signers.user2).mintTicket(period.id, competition.id, signers.user1.address, singleTicket);
      assert.fail("Should throw error when try to mint single ticket with unauthorized account");
    } catch (e: Error) {
      expect(e.message).to.contain("Only call from minter");
    }

    // Mint authorized account
    await contracts.compFactory.connect(signers.ticketMinter).mintTicket(period.id, competition.id, signers.user1.address, singleTicket);
    //endregion

    //region Test ticket overmint
    const randomTicket = generateSingleTicket(tickets);

    try {
      await contracts.compFactory.connect(signers.ticketMinter).mintTicket(period.id, competition.id, signers.user1.address, randomTicket);
      assert.fail("Shouldn't overmint");
    } catch (e: Error) {
      expect(e.message).to.contain("Maximum ticket allocation bought", "Ticket mint count should be equal or lower than bought limit");
    }
    //endregion

    //endregion

    //region Send rewards for winner tickets
    const rewards = [
      {
        winnerTicketId: tickets[0],
        rewardType: RewardType.Native,
        rewardAddress: ZERO_ADDRESS,
        amount: 500,
        tokenId: 0
      }, // 500 unit native coin reward
      {
        winnerTicketId: tickets[1],
        rewardType: RewardType.Token,
        rewardAddress: contracts.usdt.address,
        amount: 500,
        tokenId: 0
      }, // 500 unit usdt token reward
      {
        winnerTicketId: tickets[2],
        rewardType: RewardType.NFT,
        rewardAddress: contracts.nft.address,
        amount: 0,
        tokenId: 334
      } // NFT reward
    ];

    // Send selected rewards
    for (const rew of rewards) {
      await contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionReward(period.id, competition.id, competitionTicket.address, rew.winnerTicketId, chainId, rew.rewardType, rew.rewardAddress, rew.amount, rew.tokenId);
    }

    const rew1 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[0].winnerTicketId);
    const rew2 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[1].winnerTicketId);
    const rew3 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[2].winnerTicketId);

    //region Defined reward expectations
    expect(rew1._exist).to.equal(true, "Reward #1 should exist");
    expect(rew1.chainId.toNumber()).to.equal(chainId.toNumber(), "Reward #1 chain id should be correct");
    expect(rew1.rewardType).to.equal(rewards[0].rewardType, "Reward #1 reward type should be correct");
    expect(rew1.rewardAddress).to.equal(rewards[0].rewardAddress, "Reward #1 reward address should be correct");
    expect(rew1.amount.toNumber()).to.equal(rewards[0].amount, "Reward #1 amount should be correct");
    expect(rew1.tokenId).to.equal(rewards[0].tokenId, "Reward #1 token id should be correct");
    expect(rew1.isClaimed).to.equal(false, "Reward #1 shouldn't be claimed");

    expect(rew2._exist).to.equal(true, "Reward #2 should exist");
    expect(rew2.chainId.toNumber()).to.equal(chainId.toNumber(), "Reward #2 chain id should be correct");
    expect(rew2.rewardType).to.equal(rewards[1].rewardType, "Reward #2 reward type should be correct");
    expect(rew2.rewardAddress).to.equal(rewards[1].rewardAddress, "Reward #2 reward address should be correct");
    expect(rew2.amount.toNumber()).to.equal(rewards[1].amount, "Reward #2 amount should be correct");
    expect(rew2.tokenId).to.equal(rewards[1].tokenId, "Reward #2 token id should be correct");
    expect(rew2.isClaimed).to.equal(false, "Reward #2 shouldn't be claimed");

    expect(rew3._exist).to.equal(true, "Reward #3 should exist");
    expect(rew3.chainId.toNumber()).to.equal(chainId.toNumber(), "Reward #3 chain id should be correct");
    expect(rew3.rewardType).to.equal(rewards[2].rewardType, "Reward #3 reward type should be correct");
    expect(rew3.rewardAddress).to.equal(rewards[2].rewardAddress, "Reward #3 reward address should be correct");
    expect(rew3.amount.toNumber()).to.equal(rewards[2].amount, "Reward #3 amount should be correct");
    expect(rew3.tokenId).to.equal(rewards[2].tokenId, "Reward #3 token id should be correct");
    expect(rew3.isClaimed).to.equal(false, "Reward #3 shouldn't be claimed");
    //endregion
    //endregion

    //region Claim competition rewards

    //region Reward #1 - Native coin reward claim test
    const hubBeforeClaimBalance = await getEthereumBalance(contracts.rewardsHub.address);
    const userBeforeClaimBalance = await getEthereumBalance(signers.user1.address);
    const claimTransaction: ContractTransaction = await contracts.rewardsHub.connect(signers.user1).claimCompetitionReward(competitionTicket.address, rewards[0].winnerTicketId);
    const claimTransactionReceipt = await ethers.provider.getTransactionReceipt(claimTransaction.hash);
    const claimCost = claimTransactionReceipt.gasUsed.mul(claimTransactionReceipt.effectiveGasPrice);
    const afterClaimBalance = await getEthereumBalance(signers.user1.address);
    const hubAfterClaimBalance = await getEthereumBalance(contracts.rewardsHub.address);
    expect(userBeforeClaimBalance.add(rewards[0].amount).sub(claimCost).toString()).to.equal(afterClaimBalance.toString(), "Incorrect user native coin balance after reward claim");
    expect(hubBeforeClaimBalance.sub(rewards[0].amount).toString()).to.equal(hubAfterClaimBalance.toString(), "Incorrect contract native coin balance after reward claim");
    //endregion

    //region Reward #2 - Token reward claim test
    const userBeforeUsdtBalance = await contracts.usdt.balanceOf(signers.user1.address);
    const rewardsHubBeforeUsdtBalance = await contracts.usdt.balanceOf(contracts.rewardsHub.address);
    await contracts.rewardsHub.connect(signers.user1).claimCompetitionReward(competitionTicket.address, rewards[1].winnerTicketId);
    const afterUsdtBalance = await contracts.usdt.balanceOf(signers.user1.address);
    const rewardsHubAfterUsdtBalance = await contracts.usdt.balanceOf(contracts.rewardsHub.address);
    expect(userBeforeUsdtBalance.add(rewards[1].amount).toString()).to.equal(afterUsdtBalance.toString(), "Incorrect user token balance after claim reward");
    expect(rewardsHubBeforeUsdtBalance.sub(rewards[1].amount).toString()).to.equal(rewardsHubAfterUsdtBalance.toString(), "Incorrect contract token balance after claim reward");
    //endregion

    //region Reward #3 - NFT reward claim test
    const userBeforeNftBalance = await contracts.nft.balanceOf(signers.user1.address);
    const rewardsHubBeforeNftBalance = await contracts.nft.balanceOf(contracts.rewardsHub.address);
    await contracts.rewardsHub.connect(signers.user1).claimCompetitionReward(competitionTicket.address, rewards[2].winnerTicketId);
    const afterNftBalance = await contracts.nft.balanceOf(signers.user1.address);
    const rewardsHubAfterNftBalance = await contracts.nft.balanceOf(contracts.rewardsHub.address);
    expect(userBeforeNftBalance.add(1).toString()).to.equal(afterNftBalance.toString(), "Incorrect user NFT balance after claim reward");
    expect(rewardsHubBeforeNftBalance.sub(1).toString()).to.equal(rewardsHubAfterNftBalance.toString(), "Incorrect contract NFT balance after claim reward");
    //endregion

    //region Competition rewards claim state check
    const afterClaimRewards = {
      first: (await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[0].winnerTicketId)),
      second: (await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[1].winnerTicketId)),
      third: (await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[2].winnerTicketId))
    };
    expect(afterClaimRewards.first.isClaimed).to.equal(true, "Competition reward #1 should be claimed");
    expect(afterClaimRewards.second.isClaimed).to.equal(true, "Competition reward #2 should be claimed");
    expect(afterClaimRewards.third.isClaimed).to.equal(true, "Competition reward #3 should be claimed");
    //endregion

    //endregion

    //region Set airdrop reward
    const multipleRewardAirdropId = 25;
    const singleRewardAirdropId = 26;
    const removeAirdropId = 27;
    const airdropRewards = [
      {
        rewardType: RewardType.Native,
        rewardAddress: ZERO_ADDRESS,
        amount: 500,
        tokenId: 0
      }, // 500 unit native coin reward
      {
        rewardType: RewardType.Token,
        rewardAddress: contracts.usdt.address,
        amount: 500,
        tokenId: 0
      }, // 500 unit usdt token reward
      {
        rewardType: RewardType.NFT,
        rewardAddress: contracts.nft.address,
        amount: 0,
        tokenId: 333
      } // NFT reward
    ];
    const singleAirdropReward = {
      rewardType: RewardType.Token,
      rewardAddress: contracts.usdt.address,
      amount: 250,
      tokenId: 0
    };

    // Send rewards
    for (const rew of airdropRewards) {
      await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, multipleRewardAirdropId, chainId, rew.rewardType, rew.rewardAddress, rew.amount, rew.tokenId);
    }
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, singleRewardAirdropId, chainId, singleAirdropReward.rewardType, singleAirdropReward.rewardAddress, singleAirdropReward.amount, singleAirdropReward.tokenId);

    //region Airdrop reward remove test
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, removeAirdropId, chainId, singleAirdropReward.rewardType, singleAirdropReward.rewardAddress, singleAirdropReward.amount, singleAirdropReward.tokenId);
    const rReward1 = await contracts.rewardsHub.getAirdropReward(signers.user2.address, removeAirdropId, 0);
    await contracts.rewardsHub.connect(signers.rewardDefiner).removeAirdropReward(signers.user2.address, removeAirdropId, 0);

    try {
      await contracts.rewardsHub.getAirdropReward(signers.user2.address, removeAirdropId, 0);
      assert.fail("Reward shouldn't be exist after remove");
    } catch (e: Error) {
      expect(e.message).to.contain("Reward index out of boundaries");
    }

    expect(rReward1._exist).to.equal(true);
    expect(rReward1.rewardType).to.equal(singleAirdropReward.rewardType);
    expect(rReward1.rewardAddress).to.equal(singleAirdropReward.rewardAddress);
    expect(rReward1.amount.toNumber()).to.equal(singleAirdropReward.amount);
    expect(rReward1.isClaimed).to.equal(false);
    expect(rReward1.tokenId).to.equal(singleAirdropReward.tokenId);
    expect(rReward1.chainId).to.equal(chainId);

    //endregion


    //region Claim single airdrop reward test
    const singleAirdropBeforeBalance = await contracts.usdt.balanceOf(signers.user2.address);
    await contracts.rewardsHub.connect(signers.user2).claimAirdropReward(singleRewardAirdropId, 0); // Claim single airdrop reward
    const singleAirdropAfterBalance = await contracts.usdt.balanceOf(signers.user2.address);
    expect(singleAirdropBeforeBalance.add(singleAirdropReward.amount).toString()).to.equal(singleAirdropAfterBalance.toString(), "Incorrect token balance after single airdrop reward claim");
    //endregion

    //region Claim multiple airdrop rewards test
    const bbMultiClaim = {
      native: (await getEthereumBalance(signers.user2.address)),
      token: (await contracts.usdt.balanceOf(signers.user2.address)),
      nft: (await contracts.nft.balanceOf(signers.user2.address))
    };
    const claimMultiAirdropTransaction: ContractTransaction = await contracts.rewardsHub.connect(signers.user2).claimAllAirdropRewards(multipleRewardAirdropId); // Claim multiple airdrop reward
    const multiClaimReceipt = await ethers.provider.getTransactionReceipt(claimMultiAirdropTransaction.hash);
    const multiClaimCost = multiClaimReceipt.gasUsed.mul(multiClaimReceipt.effectiveGasPrice);
    const baMultiClaim = {
      native: (await getEthereumBalance(signers.user2.address)),
      token: (await contracts.usdt.balanceOf(signers.user2.address)),
      nft: (await contracts.nft.balanceOf(signers.user2.address))
    };

    expect(bbMultiClaim.native.add(airdropRewards[0].amount).sub(multiClaimCost).toString()).to.equal(baMultiClaim.native.toString(), "Incorrect native coin balance after multiple airdrop reward claim");
    expect(bbMultiClaim.token.add(airdropRewards[1].amount).toString()).to.equal(baMultiClaim.token.toString(), "Incorrect token balance after multiple airdrop reward claim");
    expect(bbMultiClaim.nft.add(1).toNumber()).to.equal(baMultiClaim.nft.toNumber(), "Incorrect NFT balance after multiple airdrop reward claim");
    //endregion

    //endregion

    //region PoPA Deploy & Claim & Mint
    const popa = {
      name: "Zizy POPA",
      symbol: "ZPOP"
    };

    const initialPopaCounter = await contracts.popaFactory.getDeployedContractCount();
    expect(initialPopaCounter.toNumber()).to.equal(0, "Initial popa counter should be zero");

    //region Deploy & Checks
    await contracts.popaFactory.deploy(popa.name, popa.symbol, period.id);
    const newPopaCounter = await contracts.popaFactory.getDeployedContractCount();
    expect(newPopaCounter.toNumber()).to.equal(1, "New popa counter should be 1 after first deployment");

    const popaContractAddr = await contracts.popaFactory.getPopaContract(period.id);
    const ZizyPopa = await ethers.getContractFactory("ZizyPoPa");
    const popaContract = (ZizyPopa.attach(popaContractAddr) as ZizyPoPa);
    expect(await popaContract.name()).to.equal(popa.name, "Incorrect popa name");
    expect(await popaContract.symbol()).to.equal(popa.symbol, "Incorrect popa symbol");
    expect((await popaContract.totalSupply()).toNumber()).to.equal(0, "Popa total supply should be zero");
    //endregion

    //region Allocation percentage
    const initalPopaAllocationPercentage = await contracts.popaFactory.allocationPercentage();
    await contracts.popaFactory.setPopaClaimAllocationPercentage((initalPopaAllocationPercentage.toNumber() + 1)); // Update temporary
    const updatedPopaAllocationPercentage = await contracts.popaFactory.allocationPercentage();
    expect(initalPopaAllocationPercentage.toNumber() + 1).to.equal(updatedPopaAllocationPercentage.toNumber(), "Incorrect popa allocation percentage after update");
    await contracts.popaFactory.setPopaClaimAllocationPercentage(initalPopaAllocationPercentage); // Set as default
    //endregion

    //region Claim payment amount update test
    const initialPopaClaimPaymentAmount = await contracts.popaFactory.claimPayment();
    await contracts.popaFactory.setClaimPaymentAmount((initialPopaClaimPaymentAmount.add(1))); // Update temporary
    const updatedPopaClaimPaymentAmount = await contracts.popaFactory.claimPayment();
    expect(initialPopaClaimPaymentAmount.add(1).toString()).to.equal(updatedPopaClaimPaymentAmount.toString(), "Incorrect popa claim payment amount after update");
    await contracts.popaFactory.setClaimPaymentAmount(initialPopaClaimPaymentAmount); // Set as default
    //endregion

    // Claim & Mint PoPA
    const requiredPopaPayment = await contracts.popaFactory.claimPayment();
    expect(await contracts.popaFactory.claimableCheck(signers.user1.address, period.id)).to.equal(true, "User1 should eligible to claim popa with default %10 participation limit");

    const initialPopaMinterBalance = await getEthereumBalance(signers.popaMinter.address);
    await contracts.popaFactory.connect(signers.user1).claim(period.id, { value: requiredPopaPayment });
    const popaBalanceBeforeMint = await popaContract.balanceOf(signers.user1.address);
    expect(popaBalanceBeforeMint.toNumber()).to.equal(0, "User popa balance should be zero before mint. Claim completed & Not minted yet");

    const randomPopaID = 33552;
    const mintTransaction: ContractTransaction = await contracts.popaFactory.connect(signers.popaMinter).mintClaimedPopa(signers.user1.address, period.id, randomPopaID); // Mint PoPA with {Random} id
    const mintTransactionReceipt = await ethers.provider.getTransactionReceipt(mintTransaction.hash);
    const mintTransactionCost = mintTransactionReceipt.gasUsed.mul(mintTransactionReceipt.effectiveGasPrice);
    const newPopaMinterBalance = await getEthereumBalance(signers.popaMinter.address);

    expect(initialPopaMinterBalance.add(requiredPopaPayment).sub(mintTransactionCost).toString()).to.equal(newPopaMinterBalance.toString(), "Popa claim payment is not transferred correctly");
    expect((await popaContract.balanceOf(signers.user1.address)).toNumber()).to.equal(1, "User popa balance should be correct after mint");
    expect((await popaContract.tokenOfOwnerByIndex(signers.user1.address, 0)).toNumber()).to.equal(randomPopaID, "User popa id is not correct");
    //endregion

    //region Stake percentage reward
    const currentSnapshotId = await contracts.staking.getSnapshotId();
    await contracts.staking.snapshot(); // Take snapshot
    const stakeBalance = await contracts.staking.balanceOf(signers.user1.address);
    await contracts.stakeRewards.connect(signers.rewardDefiner).setRewardConfig(5001, false, 0, 0, 0, currentSnapshotId, currentSnapshotId); // Set reward snapshot range & Other options
    await contracts.stakeRewards.connect(signers.rewardDefiner).setZizyStakePercentageReward(5001, contracts.zizy.address, 50000, 10); // Set %10 stake reward
    const userZizyBalanceBeforeStakeRewardClaim = await contracts.zizy.balanceOf(signers.user1.address);
    const reward = await contracts.stakeRewards.getReward(5001);

    expect(reward.contractAddress).to.equal(contracts.zizy.address, "Incorrect reward contract address");
    expect(reward.chainId.toNumber()).to.equal(chainId.toNumber(), "Incorrect reward chain id");
    expect(reward.percentage.toNumber()).to.equal(10, "Incorrect reward percentage");

    await contracts.stakeRewards.connect(signers.user1).claimReward(5001, 0);
    const userZizyBalanceAfterStakeRewardClaim = await contracts.zizy.balanceOf(signers.user1.address);
    expect(userZizyBalanceBeforeStakeRewardClaim.add(stakeBalance.mul(10).div(100)).toString()).to.equal(userZizyBalanceAfterStakeRewardClaim.toString(), "Incorrect zizy balance after stake reward claim");
    //endregion

    //region Stake reward with tiers & vesting
    const startTime = (getTimestamp() - 1);
    await contracts.stakeRewards.connect(signers.rewardDefiner).setRewardConfig(8001, true, startTime, 1, 5, currentSnapshotId, currentSnapshotId); // Set reward config with vesting 1 day interval (5 day total)
    await contracts.stakeRewards.connect(signers.rewardDefiner).setRewardTiers(8001, [
      { stakeMin: 0, stakeMax: 4000, rewardAmount: 5000 },
      { stakeMin: 4001, stakeMax: 9000, rewardAmount: 10000 },
      { stakeMin: 9001, stakeMax: 20000, rewardAmount: 15000 }
    ]); // Set reward tiers (User1 should be in middle tier [10_000 unit reward])
    await contracts.stakeRewards.connect(signers.rewardDefiner).setTokenReward(8001, chainId, contracts.usdt.address, 20_000); // Set USDT reward with 20_000 Upper limit

    expect((await contracts.stakeRewards.isRewardClaimable(signers.user1.address, 8001, 0))).to.equal(true, "First reward should claimable. Vesting start date is lower than current date");
    expect((await contracts.stakeRewards.isRewardClaimable(signers.user1.address, 8001, 1))).to.equal(false, "Second or higher rewards shouldn't be claimable. Vesting date is not came");
    expect((await contracts.stakeRewards.getAccountReward(signers.user1.address, 8001, 0))._exist).to.equal(false, "Account reward shouldn't exist before first part claim");

    const initialUSDTBalance = await contracts.usdt.balanceOf(signers.user1.address);
    await contracts.stakeRewards.connect(signers.user1).claimReward(8001, 0);
    const accountReward = await contracts.stakeRewards.getAccountReward(signers.user1.address, 8001, 0); // Get #0 indexed reward part

    expect(accountReward._exist).to.equal(true, "#0 indexed reward token address should exist");
    expect(accountReward.rewardType).to.equal(RewardType.Token, "#0 indexed reward type should be correct");
    expect(accountReward.chainId.toNumber()).to.equal(chainId.toNumber(), "#0 indexed reward should be contain correct chain id");
    expect(accountReward.isClaimed).to.equal(true, "#0 indexed reward should be claimed state");
    expect(accountReward.amount.toNumber()).to.equal(2000, "#0 indexed reward should splitted correctly");
    expect(accountReward.contractAddress).to.equal(contracts.usdt.address, "#0 indexed reward token address should be correct");

    expect((await contracts.usdt.balanceOf(signers.user1.address)).toString()).to.equal(initialUSDTBalance.add(accountReward.amount), "Incorrect claimed token reward amount");

    const secondPartOfReward = await contracts.stakeRewards.getAccountReward(signers.user1.address, 8001, 1); // Get #1 indexed reward part
    expect(secondPartOfReward._exist).to.equal(true, "Vesting parts should be created after first claim");
    expect(secondPartOfReward.isClaimed).to.equal(false, "Vesting part 2 shouldn't be claimed. Unlock date is not came");
    //endregion
  });

});
