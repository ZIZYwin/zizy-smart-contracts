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
import { expectError, getNodeCurrentTime } from "../scripts/helpers/TestHelpers";

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

const day = (dayCount: number) => {
  return (dayCount * 24 * 60 * 60);
};

const generateRandomTickets = (ticketCount: number): number[] => {
  const tickets = [];
  do {
    // Generate random ticket number between 0-999999
    const ticketNumber = getRandomInteger(100000, 999999);

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

  it("initializers check", async function() {
    try {
      const PopaFactory = await ethers.getContractFactory("ZizyPoPaFactory");
      const newPopaFactory = (await upgrades.deployProxy(PopaFactory, [ethers.constants.AddressZero], {
        initializer: "initialize"
      }) as ZizyPoPaFactory);
      await newPopaFactory.deployed();
    } catch (e: Error) {
      expect(e.message).to.contain("Contract address can not be zero", "Contract address can not be zero");
    }

    try {
      const ZizyCompStakingFactory = await ethers.getContractFactory("ZizyCompetitionStaking");
      const newZizyCompStakingFactory = (await upgrades.deployProxy(ZizyCompStakingFactory, [ethers.constants.AddressZero, ethers.constants.AddressZero], {
        initializer: "initialize"
      }) as ZizyCompetitionStaking);
      await newZizyCompStakingFactory.deployed();
    } catch (e: Error) {
      expect(e.message).to.contain("Params cant be zero address", "Stake token can't be zero address");
    }

    try {
      const ZizyCompStakingFactory = await ethers.getContractFactory("ZizyCompetitionStaking");
      const newZizyCompStakingFactory = (await upgrades.deployProxy(ZizyCompStakingFactory, [contracts.zizy.address, ethers.constants.AddressZero], {
        initializer: "initialize"
      }) as ZizyCompetitionStaking);
      await newZizyCompStakingFactory.deployed();
    } catch (e: Error) {
      expect(e.message).to.contain("Params cant be zero address", "Fee receiver can't be zero address");
    }

    try {
      const ZizyCompFactoryFactory = await ethers.getContractFactory("CompetitionFactory");
      const newZizyCompFactoryFactory = (await upgrades.deployProxy(ZizyCompFactoryFactory, [ethers.constants.AddressZero, contracts.zizy.address], {
        initializer: "initialize"
      }) as ZizyCompetitionStaking);
      await newZizyCompFactoryFactory.deployed();
    } catch (e: Error) {
      expect(e.message).to.contain("Params cant be zero address", "Receiver can't be zero address");
    }

    try {
      const ZizyCompFactoryFactory = await ethers.getContractFactory("CompetitionFactory");
      const newZizyCompFactoryFactory = (await upgrades.deployProxy(ZizyCompFactoryFactory, [contracts.zizy.address, ethers.constants.AddressZero], {
        initializer: "initialize"
      }) as ZizyCompetitionStaking);
      await newZizyCompFactoryFactory.deployed();
    } catch (e: Error) {
      expect(e.message).to.contain("Params cant be zero address", "Minter can't be zero address");
    }
  });

  it("configurations & throw checks", async function() {
    await expectError(contracts.popaFactory.setCompetitionFactory(ethers.constants.AddressZero), "Competition factory cant be zero address");
    expect(await contracts.popaFactory.setCompetitionFactory(contracts.compFactory.address)).to.emit(contracts.popaFactory, "CompFactoryUpdated");

    await expectError(contracts.popaFactory.setPopaMinter(ethers.constants.AddressZero), "Minter account can not be zero", "Minter account shouldn't be set zero");
    await expectError(contracts.popaFactory.getPopaContractWithIndex(0), "Out of index", "Should throw error if there is no popa contract");


    await expectError(contracts.rewardsHub.setRewardDefiner(ethers.constants.AddressZero), "Reward definer address can not be zero", "Reward definer address can not be zero");
    await contracts.rewardsHub.setRewardDefiner(signers.rewardDefiner.address);

    await expectError(
      contracts.staking.getPeriodSnapshotsAverage(ethers.constants.AddressZero, 50, 20, 10),
      "Min should be higher",
      "Should throw error if min > max on getPeriodSnapshotsAverage call"
    );

    await expectError(
      contracts.staking.setLockModerator(ethers.constants.AddressZero),
      "Lock moderator cant be zero address",
      "Should throw error when try to set moderator address zero"
    );

    await contracts.staking.setLockModerator(contracts.stakeRewards.address);

    await expectError(
      contracts.staking.getPeriodSnapshotRange(999999),
      "Period does not exist",
      "Should throw error if period does not exist"
    );

    await expectError(
      contracts.staking.snapshot(),
      "No active period exist",
      "Should throw error on `snapshot` if no active period exist"
    );

    await expectError(
      contracts.staking.setPeriodId(999999),
      "Only call from factory",
      "Should throw error if `onlyCallFromFactory` modifier requirements not met"
    );

    await expectError(
      contracts.staking.setFeeAddress(ethers.constants.AddressZero),
      "Fee address can not be zero",
      "Should throw error when try to set fee address is zero address"
    );
    expect(await contracts.staking.setFeeAddress(signers.feeReceiver.address)).to.emit(contracts.staking, "FeeReceiverUpdated");

    await expectError(
      contracts.staking.setStakeFeePercentage(6),
      "Fee percentage is not within limits",
      "Should throw error if stake fee percentage is not withing limits"
    );

    await expectError(
      contracts.staking.setCompetitionFactory(ethers.constants.AddressZero),
      "Competition factory address can not be zero",
      "Should throw error if when try to set competition factory address as zero address"
    );

    await expectError(
      contracts.compFactory.getCompetitionIdWithIndex(0, 555),
      "Out of boundaries",
      "Out of boundaries"
    );

    await expectError(
      contracts.compFactory.setPaymentReceiver(ethers.constants.AddressZero),
      "Payment receiver can not be zero address",
      "Should throw error when try to set payment receiver as zero address"
    );

    await expect(await contracts.compFactory.setPaymentReceiver(signers.paymentReceiver.address)).to.emit(contracts.compFactory, "PaymentReceiverUpdate");

    await expectError(
      contracts.compFactory.setTicketMinter(ethers.constants.AddressZero),
      "Minter address can not be zero",
      "Should throw error when try to set ticket minter as zero address"
    );

    await expect(await contracts.compFactory.setTicketMinter(signers.user3.address)).to.emit(contracts.compFactory, "TicketMinterUpdate");

    await expectError(
      contracts.compFactory.setStakingContract(ethers.constants.AddressZero),
      "Staking contract address can not be zero",
      "Should throw error when try to set staking contract as zero address"
    );

    await expectError(
      contracts.compFactory.setTicketDeployer(ethers.constants.AddressZero),
      "Ticket deployer contract address can not be zero",
      "Should throw error when try to set staking contract as zero address"
    );

    await expectError(
      contracts.stakeRewards.setStakingContract(ethers.constants.AddressZero),
      "Contract address cant be zero address",
      "Should throw error when try to set staking contract as address zero"
    );

    await expectError(
      contracts.stakeRewards.setRewardDefiner(ethers.constants.AddressZero),
      "Reward definer address cant be zero address",
      "Should throw error when try to set reward definer as address zero"
    );
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
    const timestamp = (await getNodeCurrentTime());
    const initials = {
      activePeriod: (await contracts.compFactory.activePeriod()),
      totalPeriodCount: (await contracts.compFactory.totalPeriodCount()),
      totalCompetitionCount: (await contracts.compFactory.totalCompetitionCount()),
      deployedTicketContractCount: (await contracts.ticketDeployer.getDeployedContractCount())
    };
    const period = {
      id: 1,
      startTime: timestamp - 5,
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

    await expectError(
      contracts.compFactory.createPeriod(0, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd),
      "New period id should be higher than zero",
      "Should throw error when try to create 0 id period"
    );

    // Create new period
    await contracts.compFactory.createPeriod(period.id, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd);
    await expectError(
      contracts.compFactory.createPeriod(period.id, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd),
      "Period id already exist",
      "Should throw error when try to create already exist period"
    );
    await expectError(
      contracts.compFactory.updatePeriod(1238912893, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd),
      "There is no period exist",
      "Should throw error when try to update not exist period"
    );

    const initialStakingSnapshotId = await contracts.staking.getSnapshotId();
    await contracts.compFactory.setActivePeriod(period.id);

    await expectError(
      contracts.compFactory.setActivePeriod(period.id),
      "already active",
      "Should throw error when try to set active, current active period"
    );

    await expectError(
      contracts.compFactory.setActivePeriod(18217381237),
      "Period does not exist",
      "Should throw error when try to set active not exist period"
    );

    const afterStakingSnapshotId = await contracts.staking.getSnapshotId();
    expect(initialStakingSnapshotId.toNumber() + 1).to.equal(afterStakingSnapshotId.toNumber(), "Snapshot ID should be increased after active period change");

    const sPeriod = await contracts.staking.getPeriod(period.id);
    expect(sPeriod._exist).to.equal(true, "Should update period information on staking contract");

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

    await contracts.compFactory.updatePeriod(period.id, (period.startTime + 60), (period.endTime + 60), (period.tBuyStart + 60), (period.tBuyEnd + 60));

    // Fetch updated period data from smart contract
    const cPeriod2 = await contracts.compFactory.getPeriod(period.id);

    // Check updated period configuration
    expect(cPeriod2.startTime.toNumber()).to.be.equal((period.startTime + 60), "Incorrect updated start time");
    expect(cPeriod2.endTime.toNumber()).to.be.equal((period.endTime + 60), "Incorrect updated end time");
    expect(cPeriod2.ticketBuyStartTime.toNumber()).to.be.equal((period.tBuyStart + 60), "Incorrect updated ticket buy start time");
    expect(cPeriod2.ticketBuyEndTime.toNumber()).to.be.equal((period.tBuyEnd + 60), "Incorrect updated ticket buy end time");

    await expectError(
      contracts.compFactory.createCompetition(18237981237, competition.id, competition.name, competition.symbol),
      "Period does not exist",
      "Should throw error when try to create competition on not-exist period"
    );

    // Create competition
    await contracts.compFactory.createCompetition(period.id, competition.id, competition.name, competition.symbol);

    await expectError(
      contracts.compFactory.createCompetition(period.id, competition.id, competition.name, competition.symbol),
      "Competition already exist",
      "Should throw error when try to create already exist competition"
    );

    expect(await contracts.compFactory.canTicketBuy(period.id, competition.id)).to.equal(false, "Shouldn't buy ticket before competition settings defined");

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

    const newPeriodId = (period.id + 1);
    await contracts.compFactory.createPeriod(newPeriodId, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd);

    await contracts.compFactory.updatePeriod(period.id, period.startTime, period.startTime + 1, period.startTime + 2, period.startTime + 3); // For manipulate old period is over
    await contracts.compFactory.setActivePeriod(newPeriodId);

    await expectError(
      contracts.compFactory.setActivePeriod(period.id),
      "This period is over",
      "Should throw error when try to active already closed period"
    );

    await expectError(
      contracts.compFactory.createCompetition(period.id, competition.id, competition.name, competition.symbol),
      "This period is over",
      "Should throw error when try to create competition on closed period"
    );
  });

  it("staking cooling-off settings / stake fee settings / calculate un-stake amount", async function() {
    const ts = (await getNodeCurrentTime());
    const stakeAmount = 5000;

    //region Cooling off
    await contracts.staking.updateCoolingOffSettings(10, 3, 5);
    expect(await contracts.staking.coolingPercentage()).to.be.equal(10, "Incorrect unstake fee percentage");
    expect(await contracts.staking.coolingDelay()).to.be.equal(day(3), "Incorrect cooling day");
    expect(await contracts.staking.coolestDelay()).to.be.equal(day(5), "Incorrect coolest day");
    await expectError(
      contracts.staking.updateCoolingOffSettings(30, 3, 5),
      "Percentage should be in",
      "Should throw error when try to set cooling off percentage outer limits"
    );
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
    await expectError(
      contracts.stakeRewards.getBoosterIndex(1),
      "Booster is not exist",
      "Should throw error when try to get not-exist booster"
    );

    const boosterId = 1;
    const boosterType = 0; // BoosterType.HoldingPOPA
    const contractAddress = "0x1234567890123456789012345678901234567890";
    const amount = 0;
    const boostPercentage = 10;

    await expectError(
      contracts.stakeRewards.setBooster(boosterId, boosterType, contractAddress, amount, boostPercentage),
      "Only call from reward definer address",
      "Should throw error when try to call `onlyRewardDefiner` modifier method from un-authorized account"
    );

    await expectError(
      contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, ethers.constants.AddressZero, amount, boostPercentage),
      "Contract address cant be zero address",
      "Should throw error when try to set zero address booster as holding popa type"
    );
    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, contractAddress, amount, boostPercentage);

    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, contractAddress, amount, boostPercentage);

    const boosterIndex = await contracts.stakeRewards.getBoosterIndex(boosterId);
    expect(boosterIndex.toNumber()).to.greaterThanOrEqual(0, "Should returned booster index with correct value");

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
    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster((boosterId + 1), boosterType, contracts.nft.address, amount, boostPercentage); // Remove test & doesn't require real popa contract address
    await contracts.stakeRewards.connect(signers.rewardDefiner).removeBooster(boosterId);

    const booster = await contracts.stakeRewards.getBooster(boosterId);
    expect(booster._exist).to.be.false;

    await expectError(
      contracts.stakeRewards.connect(signers.rewardDefiner).removeBooster(8888),
      "Booster does not exist",
      "Should throw error when try to remove not-exist booster"
    );
  });

  it("should calculate account boost percentage correctly & activity details check", async function() {
    await contracts.compFactory.createPeriod(1, 0, 4, 1, 2); // Just create useless period
    await contracts.compFactory.setActivePeriod(1);

    await contracts.nft.mint(signers.user1.address, 500); // Mint POPA (NFT)

    const boosterId = 1;
    const boosterType = 0; // BoosterType.HoldingPOPA
    const contractAddress = contracts.nft.address;
    const boostPercentage = 10;

    const beforeActivity = await contracts.staking.getActivityDetails(signers.user1.address);
    await contracts.staking.connect(signers.user1).stake(5000);
    const afterActivity = await contracts.staking.getActivityDetails(signers.user1.address);
    expect(beforeActivity._exist).to.equal(false, "Shouldn't exist any activity");
    expect(afterActivity._exist).to.equal(true, "Should activity exist after stake");
    expect(afterActivity.lastSnapshotId.toNumber()).to.greaterThan(0, "Last snapshot id should be correct");
    expect(afterActivity.lastActivityBalance.toNumber()).to.greaterThan(0, "Last activity balance should be correct");

    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(boosterId, boosterType, contractAddress, 0, boostPercentage);

    const rewardId = 1;
    const vestingIndex = 0;

    const calculatedPercentage = await contracts.stakeRewards.getAccountBoostPercentage(signers.user1.address, rewardId, vestingIndex);
    expect(calculatedPercentage.toNumber()).to.equal(boostPercentage);
    const anotherUserPercentage = await contracts.stakeRewards.getAccountBoostPercentage(signers.user2.address, rewardId, vestingIndex);
    expect(anotherUserPercentage.toNumber()).to.equal(0, "Booster percentage should be correct if user doesnt have any booster popa");
  });

  it("snapshot average calculations check", async function() {
    await expectError(
      contracts.staking.connect(signers.user1).stake(100),
      "There is no period exist",
      "Should throw error if `whenPeriodExist` modifier requirements not met"
    );

    let ts = (await getNodeCurrentTime());
    await expectError(
      contracts.staking.calculatePeriodStakeAverage(),
      "There is no period exist",
      "Should throw error if no period exist"
    );

    await expectError(
      contracts.staking.snapshot(),
      "No active period exist",
      "Should throw error when try to take snapshot without any period exist"
    );
    await contracts.compFactory.createPeriod(1, (ts - 5), (ts + 200), (ts + 100), (ts + 150)); // Just create simple period
    await contracts.compFactory.setActivePeriod(1);

    await contracts.staking.snapshot(); // Take snapshot [#1]
    await contracts.staking.snapshot(); // Take snapshot [#2]
    await contracts.staking.connect(signers.user1).stake(100);
    await contracts.staking.snapshot(); // Take snapshot [#3]

    const checkSnapshotId = (await contracts.staking.getSnapshotId()).toNumber();
    const checkAverage = await contracts.staking.getSnapshotAverage(signers.user1.address, 0, (checkSnapshotId - 1));
    // expect().to.greaterThan(0, "Period snapshot average should be correct");

    await contracts.staking.snapshot(); // Take snapshot [#4]
    await contracts.staking.connect(signers.user1).stake(100);

    await expectError(
      contracts.staking.connect(signers.user1).calculatePeriodStakeAverage(),
      "Currently not in the range that can be calculated",
      "Should throw error when try to calculate period stake average if current time is not in buy range"
    );

    ts = (await getNodeCurrentTime());
    await contracts.compFactory.updatePeriod(1, (ts - 5), (ts + 200), (ts - 4), (ts + 150)); // Update period for trigger calculatePeriodStakeAverage
    await contracts.staking.connect(signers.user1).calculatePeriodStakeAverage();

    //region Calculate un-stake amount checks
    await contracts.staking.updateCoolingOffSettings(0, 0, 0);
    const [unStakeFee] = await contracts.staking.calculateUnStakeAmounts(1000);
    expect(unStakeFee.toNumber()).to.equal(0, "Unstake fee should be zero if percentage = 0");


    await contracts.staking.updateCoolingOffSettings(1, 1, 1);
    await contracts.compFactory.updatePeriod(1, (ts - day(2)), (ts + day(2)), (ts - 4), (ts + 150));
    const [unStakeFeeInCoolingPeriod] = await contracts.staking.calculateUnStakeAmounts(1000);
    //endregion


    // ### Set New Period
    await contracts.compFactory.createPeriod(2, (ts - 5), (ts + 200), (ts + -4), (ts + 150)); // Just create simple period (In Buy Stage)
    await contracts.compFactory.setActivePeriod(2); // Snapshot #5
    const currentSnapshotId = (await contracts.staking.getSnapshotId()).toNumber();
    await contracts.staking.snapshot(); // Take snapshot [#6]

  });

  it("system functionality", async function() {
    const chainId = await contracts.rewardsHub.chainId();
    const diffChainId = chainId.add(1);
    const timestamp = (await getNodeCurrentTime());
    const period = {
      id: 1,
      startTime: timestamp - 20,
      tBuyStart: timestamp - 20,
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

    const checkSnapshotId = (await contracts.staking.getSnapshotId()).toNumber();

    //region Take snapshot
    await contracts.staking.snapshot();
    const newSnapshotId = (await contracts.staking.getSnapshotId()).toNumber();
    expect(initialSnapshotId + 2).to.equal(newSnapshotId, "New snapshot id should be equal initial snapshot + 2");
    //endregion

    //region Check user snapshot data
    const snapshotData = await contracts.staking.getSnapshot(signers.user1.address, checkSnapshotId);
    expect(snapshotData.balance.toNumber()).to.greaterThan(0, "Snapshot balance should be higher after stake & snapshot process call");
    //endregion

    //region Set competition config (Payment, Allocation tiers, Snapshot range)
    const ticketPrice = 2;

    //region Set competition snapshot range
    await expectError(
      contracts.compFactory.setCompetitionSnapshotRange(period.id, competition.id, 5, 1),
      "Min should be higher",
      "Should throw error when try to set min > max on set competition snapshot range"
    );

    await expectError(
      contracts.compFactory.setCompetitionSnapshotRange(period.id, competition.id, checkSnapshotId, 999999999),
      "Range should between period snapshot ranges",
      "Should throw error when try to set snapshot max is higher than period max snapshot id"
    );

    await expectError(
      contracts.compFactory.setCompetitionSnapshotRange(period.id, 999999999, newSnapshotId, newSnapshotId),
      "There is no competition",
      "Should throw error when try to set snapshot range for not-exist competition"
    );

    // Set competition snapshot range for calculate allocation tiers
    await contracts.compFactory.setCompetitionSnapshotRange(period.id, competition.id, newSnapshotId, newSnapshotId);
    //endregion

    //region Set competition payment
    await expectError(
      contracts.compFactory.setCompetitionPayment(period.id, competition.id, ethers.constants.AddressZero, ticketPrice),
      "Payment token can not be zero address",
      "Should throw error when try to set payment token is zero address"
    );

    await expectError(
      contracts.compFactory.setCompetitionPayment(period.id, competition.id, contracts.usdt.address, 0),
      "Ticket price can not be zero",
      "Should throw error when try to set payment amount as 0"
    );

    // Set competition payment config & price (1 Ticket = 2 unit USDT)
    await contracts.compFactory.setCompetitionPayment(period.id, competition.id, contracts.usdt.address, ticketPrice);
    //endregion


    await expectError(
      contracts.compFactory.setCompetitionTiers(period.id, competition.id, [], competition.tiers.maxs, competition.tiers.allocations),
      "Tiers should be higher than 1",
      "Tiers should be higher than 1"
    );

    await expectError(
      contracts.compFactory.setCompetitionTiers(period.id, competition.id, [1, 2, 3], [4, 5, 6], [7, 8, 9, 10]),
      "Should be same length",
      "Should throw error when try to set competition tiers with un-matched parameter lengths"
    );

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
    await expectError(
      contracts.staking.connect(signers.user1).calculatePeriodStakeAverage(),
      "Already calculated",
      "Should throw error if try to calculate stake average again"
    );
    const [stakeAverage, stakeAverageIsCalculated] = await contracts.staking.getPeriodStakeAverage(signers.user1.address, period.id);
    expect(stakeAverageIsCalculated).to.equal(true, "Period stake average should be calculated");
    expect(stakeAverage.toNumber()).to.greaterThan(0, "Period stake average should be correct");

    await expectError(
      (contracts.staking.getPeriodSnapshotsAverage(signers.user1.address, period.id, newSnapshotId, 999999)),
      "Range max should be lower than current snapshot or period last snapshot",
      "Should throw error when try to get high snapshot stake average"
    );

    const userAllocation1 = await contracts.compFactory.getAllocation(signers.user1.address, period.id, competition.id);

    expect(userAllocation1.hasAllocation).to.equal(true, "Has allocation should be true after calculate method trigger");
    expect(userAllocation1.max).to.equal(100, "User max allocation should be correct");
    expect(userAllocation1.bought).to.equal(0, "User bought ticket count should be correct");

    await expectError(
      contracts.staking.getSnapshotAverage(signers.user1.address, 5, 3),
      "Max should be equal or higher than max",
      "Max should be equal or higher than max"
    );

    await expectError(
      contracts.staking.getSnapshotAverage(signers.user1.address, checkSnapshotId, 999999),
      "Max should be equal or lower than current snapshot",
      "Max should be equal or higher than max"
    );
    //endregion

    //region Check ticket buy when period not in buy stage
    await contracts.compFactory.updatePeriod(period.id, period.startTime, period.endTime, period.endTime - 2, period.endTime - 1);
    expect(await contracts.compFactory.canTicketBuy(period.id, competition.id)).to.equal(false, "Shouldn't buy tickets when period is not in buy stage (ts < ticketBuyStart)");
    await contracts.compFactory.updatePeriod(period.id, period.startTime, period.endTime, period.startTime + 1, period.startTime + 2);
    expect(await contracts.compFactory.canTicketBuy(period.id, competition.id)).to.equal(false, "Shouldn't buy tickets when period is not in buy stage (ts > ticketBuyEnd)");
    await expectError(
      contracts.compFactory.connect(signers.user1).buyTicket(period.id, competition.id, 1),
      "Period is not in buy stage",
      "Should throw error when try to buy tickets when period is not in buy-stage"
    );
    await contracts.compFactory.updatePeriod(period.id, period.startTime, period.endTime, period.tBuyStart, period.tBuyEnd);
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

    expect(await contracts.compFactory.canTicketBuy(period.id, competition.id)).to.equal(true, "Should ticket buy when comp settings is defined & period is in buy stage");

    await expectError(
      contracts.compFactory.connect(signers.user1).buyTicket(period.id, competition.id, 0),
      "Requested ticket count should be higher than zero",
      "Should throw error when try to buy zero ticket"
    );

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

    await expectError(
      contracts.compFactory.connect(signers.ticketMinter).mintBatchTicket(period.id, competition.id, signers.user1.address, []),
      "Ticket ids length should be higher than zero",
      "Should throw error when try to mintBatchTickets with zero length array"
    );

    await expectError(
      contracts.compFactory.connect(signers.ticketMinter).mintBatchTicket(period.id, 999999, signers.user1.address, tickets),
      "Competition does not exist",
      "Should throw error when try to mintBatchTickets for not-exist competition"
    );

    // Mint authorized account
    await contracts.compFactory.connect(signers.ticketMinter).mintBatchTicket(period.id, competition.id, signers.user1.address, tickets);

    const supplyOfCompetition = await contracts.compFactory.totalSupplyOfCompetition(period.id, competition.id);
    expect(supplyOfCompetition.toNumber()).to.equal(tickets.length, "Total supply of competition ticket should be correct");

    await contracts.compFactory.unpauseCompetitionTransfer(period.id, competition.id); // Should un-pause competition transfer without error
    await contracts.compFactory.pauseCompetitionTransfer(period.id, competition.id); // Should pause competition transfer without error
    await contracts.compFactory.setCompetitionBaseURI(period.id, competition.id, "https://random.host/"); // Should set base-uri of competition without error

    await expectError(
      contracts.compFactory.connect(signers.ticketMinter).mintBatchTicket(period.id, competition.id, signers.user1.address, tickets),
      "Maximum ticket allocation bought",
      "Should throw error when try to over-mint ticket"
    );
    //endregion

    //region Mint single
    // Try to mint unauthorized account
    try {
      await contracts.compFactory.connect(signers.user2).mintTicket(period.id, competition.id, signers.user1.address, singleTicket);
      assert.fail("Should throw error when try to mint single ticket with unauthorized account");
    } catch (e: Error) {
      expect(e.message).to.contain("Only call from minter");
    }

    await expectError(
      contracts.compFactory.connect(signers.ticketMinter).mintTicket(period.id, 999999, signers.user1.address, singleTicket),
      "Competition does not exist",
      "Should throw error when try to mint ticket on not-exist competition"
    );

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
        tokenId: 0,
        chainId: chainId
      }, // 500 unit native coin reward
      {
        winnerTicketId: tickets[1],
        rewardType: RewardType.Token,
        rewardAddress: contracts.usdt.address,
        amount: 500,
        tokenId: 0,
        chainId: chainId
      }, // 500 unit usdt token reward
      {
        winnerTicketId: tickets[2],
        rewardType: RewardType.NFT,
        rewardAddress: contracts.nft.address,
        amount: 0,
        tokenId: 334,
        chainId: chainId
      }, // NFT reward
      {
        winnerTicketId: tickets[3],
        rewardType: RewardType.Token,
        rewardAddress: contracts.usdt.address,
        amount: 500,
        tokenId: 0,
        chainId: diffChainId
      } // 500 unit native coin reward on Different chain
    ];

    // Send selected rewards
    for (const rew of rewards) {
      await contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionReward(period.id, competition.id, competitionTicket.address, rew.winnerTicketId, rew.chainId, rew.rewardType, rew.rewardAddress, rew.amount, rew.tokenId);
    }

    const rew1 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[0].winnerTicketId);
    const rew2 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[1].winnerTicketId);
    const rew3 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[2].winnerTicketId);
    const rew4 = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, rewards[3].winnerTicketId);

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

    //region Update & Claim different chain reward
    const updateDiffChainRewardTx = await contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionReward(period.id, competition.id, competitionTicket.address, rewards[3].winnerTicketId, rew4.chainId, rew4.rewardType, rew4.rewardAddress, rew4.amount, rew4.tokenId);
    expect(updateDiffChainRewardTx).to.emit(contracts.rewardsHub, "CompRewardUpdated");
    await expectError(contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionReward(period.id, competition.id, competitionTicket.address, rewards[3].winnerTicketId, rew4.chainId, rew4.rewardType, ethers.constants.AddressZero, rew4.amount, rew4.tokenId),
      "Token or NFT reward must has contract address", "Should throw error when reward address is not correct"
    );
    await expectError(contracts.rewardsHub.claimCompetitionReward(competitionTicket.address, tickets[4]), "Reward does not exist", "Should throw error when reward does not exist");
    await expectError(contracts.rewardsHub.claimCompetitionReward(competitionTicket.address, rewards[3].winnerTicketId), "You are not owner of this ticket", "Should throw error when anyone try to claim another users ticket reward");
    const claimDiffChainCompReward = await contracts.rewardsHub.connect(signers.user1).claimCompetitionReward(competitionTicket.address, rewards[3].winnerTicketId);
    expect(claimDiffChainCompReward).to.emit(contracts.rewardsHub, "CompRewardClaimedOnDiffChain");
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionReward(period.id, competition.id, competitionTicket.address, rewards[3].winnerTicketId, rewards[3].chainId, RewardType.NFT, contracts.nft.address, 0, 250),
      "Cant update claimed reward",
      "Shouldn't update competition reward after claim state change"
    );

    await expectError(contracts.rewardsHub.connect(signers.user1).claimCompetitionReward(competitionTicket.address, rewards[3].winnerTicketId), "Reward already claimed", "Shouldn't claim same reward multiple times");
    //endregion

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

    //region Batch airdrop reward define checks
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropNativeRewardBatch(7000, 1, [], []),
      "Rewards is not filled",
      "Should throw error when receivers array is empty"
    );
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropNativeRewardBatch(7000, 1, [signers.user1.address], []),
      "Rewards length does not match",
      "Should throw error when receivers & rewards array length is not match"
    );
    const batchNativeRewAmount = 2500;
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropNativeRewardBatch(7000, 1, [signers.user1.address], [batchNativeRewAmount]);
    const nativeRewardCheck = await contracts.rewardsHub.getAirdropReward(signers.user1.address, 7000, 0);
    expect(nativeRewardCheck.amount.toNumber()).to.equal(batchNativeRewAmount, "Defined native reward amount does not match");
    expect(nativeRewardCheck.rewardAddress).to.equal(ethers.constants.AddressZero, "Defined native reward address should be address zero");
    expect(nativeRewardCheck.chainId.toNumber()).to.equal(1, "Defined native reward chainId should be correct");


    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropTokenRewardBatch(8000, contracts.usdt.address, 1, [], []),
      "Rewards is not filled",
      "Should throw error when receivers array is empty"
    );
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropTokenRewardBatch(8000, contracts.usdt.address, 1, [signers.user1.address], []),
      "Rewards length does not match",
      "Should throw error when receivers & rewards array length is not match"
    );
    const batchTokenRewAmount = 2500;
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropTokenRewardBatch(8000, contracts.usdt.address, 1, [signers.user1.address], [batchTokenRewAmount]);
    const tokenRewardCheck = await contracts.rewardsHub.getAirdropReward(signers.user1.address, 8000, 0);
    expect(tokenRewardCheck.amount.toNumber()).to.equal(batchTokenRewAmount, "Defined token reward amount does not match");
    expect(tokenRewardCheck.rewardAddress).to.equal(contracts.usdt.address, "Defined token reward address should be correct");
    expect(tokenRewardCheck.chainId.toNumber()).to.equal(1, "Defined token reward chainId should be correct");
    //endregion

    //region Batch competition reward define checks
    const randTicketId = 10; // This ticket can't mint with helper method. (100_000 - 999_999)
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionNativeRewardBatch(88, 90, competitionTicket.address, 1, [], []),
      "Rewards is not filled",
      "Should throw error when receivers array is empty"
    );
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionNativeRewardBatch(88, 90, competitionTicket.address, 1, [randTicketId], []),
      "Rewards length does not match",
      "Should throw error when receivers & rewards array length is not match"
    );
    const batchCompNativeRewAmount = 2500;
    await contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionNativeRewardBatch(88, 90, competitionTicket.address, 1, [randTicketId], [batchCompNativeRewAmount]);
    const batchCompNativeRewardCheck = await contracts.rewardsHub.getCompetitionReward(competitionTicket.address, randTicketId);
    expect(batchCompNativeRewardCheck.amount.toNumber()).to.equal(batchCompNativeRewAmount, "Defined native reward amount does not match");
    expect(batchCompNativeRewardCheck.rewardAddress).to.equal(ethers.constants.AddressZero, "Defined native reward address should be address zero");
    expect(batchCompNativeRewardCheck.chainId.toNumber()).to.equal(1, "Defined native reward chainId should be correct");

    const randTicketId2 = 11;
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionTokenRewardBatch(88, 90, competitionTicket.address, 1, contracts.usdt.address, [], []),
      "Rewards is not filled",
      "Should throw error when receivers array is empty"
    );
    await expectError(
      contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionTokenRewardBatch(88, 90, competitionTicket.address, 1, contracts.usdt.address, [randTicketId2], []),
      "Rewards length does not match",
      "Should throw error when receivers & rewards array length is not match"
    );
    const batchCompTokenRewAmount = 2500;
    await contracts.rewardsHub.connect(signers.rewardDefiner).setCompetitionTokenRewardBatch(88, 90, competitionTicket.address, 1, contracts.usdt.address, [randTicketId2], [batchCompTokenRewAmount]);
    const batchCompTokenRewardCheck = await contracts.rewardsHub.getAirdropReward(signers.user1.address, 8000, 0);
    expect(batchCompTokenRewardCheck.amount.toNumber()).to.equal(batchCompTokenRewAmount, "Defined token reward amount does not match");
    expect(batchCompTokenRewardCheck.rewardAddress).to.equal(contracts.usdt.address, "Defined token reward address should be correct");
    expect(batchCompTokenRewardCheck.chainId.toNumber()).to.equal(1, "Defined token reward chainId should be correct");
    //endregion

    //region Set airdrop reward
    const multipleRewardAirdropId = 25;
    const singleRewardAirdropId = 26;
    const removeAirdropId = 27;
    const diffChainRewardAirdropId = 28;
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
    expect((await contracts.rewardsHub.getUnClaimedAirdropRewardCount(signers.user2.address, multipleRewardAirdropId)).toNumber()).to.equal(airdropRewards.length, "Un-claimed airdrop rewards count should be correct");
    await expectError(contracts.rewardsHub.connect(signers.user3).setAirdropReward(signers.user2.address, singleRewardAirdropId, chainId, singleAirdropReward.rewardType, singleAirdropReward.rewardAddress, singleAirdropReward.amount, singleAirdropReward.tokenId),
      "Only call from reward definer", "Should throw error when try to add or update reward with un-authorized account"
    );
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, singleRewardAirdropId, chainId, singleAirdropReward.rewardType, singleAirdropReward.rewardAddress, singleAirdropReward.amount, singleAirdropReward.tokenId);
    await expectError(contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, diffChainRewardAirdropId, diffChainId, singleAirdropReward.rewardType, ethers.constants.AddressZero, singleAirdropReward.amount, singleAirdropReward.tokenId),
      "Token or NFT reward must has contract address", "Should throw error when reward address is not correct [Airdrop]"
    );
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, diffChainRewardAirdropId, diffChainId, singleAirdropReward.rewardType, singleAirdropReward.rewardAddress, singleAirdropReward.amount, singleAirdropReward.tokenId);

    //region Airdrop reward remove test
    await contracts.rewardsHub.connect(signers.rewardDefiner).setAirdropReward(signers.user2.address, removeAirdropId, chainId, singleAirdropReward.rewardType, singleAirdropReward.rewardAddress, singleAirdropReward.amount, singleAirdropReward.tokenId);
    const rReward1 = await contracts.rewardsHub.getAirdropReward(signers.user2.address, removeAirdropId, 0);
    await expectError(contracts.rewardsHub.connect(signers.rewardDefiner).removeAirdropReward(signers.user2.address, removeAirdropId, 25), "Reward index out of boundaries", "Should throw reward index out of boundaries error");
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
    await expectError(contracts.rewardsHub.connect(signers.user2).claimAirdropReward(diffChainRewardAirdropId, 5), "Reward index out of boundaries", "Throw error if reward index out of boundaries");
    expect(await contracts.rewardsHub.connect(signers.user2).claimAirdropReward(diffChainRewardAirdropId, 0)).to.emit(contracts.rewardsHub, "AirdropRewardClaimedOnDiffChain");
    await expectError(contracts.rewardsHub.connect(signers.user2).claimAirdropReward(diffChainRewardAirdropId, 0), "Reward already claimed", "Shouldn't claim already claimed reward & index");

    const singleAirdropBeforeBalance = await contracts.usdt.balanceOf(signers.user2.address);
    await contracts.rewardsHub.connect(signers.user2).claimAirdropReward(singleRewardAirdropId, 0); // Claim single airdrop reward
    const singleAirdropAfterBalance = await contracts.usdt.balanceOf(signers.user2.address);
    expect(singleAirdropBeforeBalance.add(singleAirdropReward.amount).toString()).to.equal(singleAirdropAfterBalance.toString(), "Incorrect token balance after single airdrop reward claim");
    await expectError(contracts.rewardsHub.connect(signers.rewardDefiner).removeAirdropReward(signers.user2.address, singleRewardAirdropId, 0), "Can not remove claimed reward", "Should throw error when try to remove claimed reward");
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
    await contracts.rewardsHub.connect(signers.user2).claimAllAirdropRewards(multipleRewardAirdropId);

    expect(bbMultiClaim.native.add(airdropRewards[0].amount).sub(multiClaimCost).toString()).to.equal(baMultiClaim.native.toString(), "Incorrect native coin balance after multiple airdrop reward claim");
    expect(bbMultiClaim.token.add(airdropRewards[1].amount).toString()).to.equal(baMultiClaim.token.toString(), "Incorrect token balance after multiple airdrop reward claim");
    expect(bbMultiClaim.nft.add(1).toNumber()).to.equal(baMultiClaim.nft.toNumber(), "Incorrect NFT balance after multiple airdrop reward claim");
    expect((await contracts.rewardsHub.getUnClaimedAirdropRewardCount(signers.user2.address, multipleRewardAirdropId)).toNumber()).to.equal(0, "Un-claimed airdrop rewards count should be correct after claim");
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
    await expectError(contracts.popaFactory.deploy(popa.name, popa.symbol, period.id), "Period popa already deployed", "Shouldn't be deploy multiple popa for single period");

    const newPopaCounter = await contracts.popaFactory.getDeployedContractCount();
    expect(newPopaCounter.toNumber()).to.equal(1, "New popa counter should be 1 after first deployment");

    const popaContractAddr = await contracts.popaFactory.getPopaContract(period.id);
    const popaContractAddrWithIndex = await contracts.popaFactory.getPopaContractWithIndex(0);
    expect(popaContractAddr).to.equal(popaContractAddrWithIndex, "Index & Mapping result should be same on popa contract address");

    const ZizyPopa = await ethers.getContractFactory("ZizyPoPa");
    const popaContract = (ZizyPopa.attach(popaContractAddr) as ZizyPoPa);
    expect(await popaContract.name()).to.equal(popa.name, "Incorrect popa name");
    expect(await popaContract.symbol()).to.equal(popa.symbol, "Incorrect popa symbol");
    expect((await popaContract.totalSupply()).toNumber()).to.equal(0, "Popa total supply should be zero");
    //endregion

    //region Allocation percentage
    await expectError(contracts.popaFactory.setPopaClaimAllocationPercentage(200), "Allocation percentage should between 0-100", "Allocation percentage should between 0-100");
    const initalPopaAllocationPercentage = await contracts.popaFactory.allocationPercentage();
    await contracts.popaFactory.setPopaClaimAllocationPercentage((initalPopaAllocationPercentage.toNumber() + 1)); // Update temporary
    const updatedPopaAllocationPercentage = await contracts.popaFactory.allocationPercentage();
    expect(initalPopaAllocationPercentage.toNumber() + 1).to.equal(updatedPopaAllocationPercentage.toNumber(), "Incorrect popa allocation percentage after update");

    await contracts.popaFactory.setPopaClaimAllocationPercentage(0);
    expect(await contracts.popaFactory.claimableCheck(signers.user1.address, period.id)).to.equal(true, "Popa should claimable if user has participation & percentage = 0");
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

    await expectError(contracts.popaFactory.connect(signers.user1).claim(period.id, { value: requiredPopaPayment.sub(1) }), "Insufficient claim payment", "Shouldn't claim with insufficient payment amount");
    await expectError(contracts.popaFactory.connect(signers.user1).claim(period.id, { value: requiredPopaPayment.mul(2) }), "Overpayment. Please reduce your payment amount", "Shouldn't claim with over payment amount");
    await expectError(contracts.popaFactory.connect(signers.user1).claim(2651623, { value: requiredPopaPayment }), "Unknown period id", "Shouldn't claim with wrong period id");

    //region Claim payment transfer failed test
    await contracts.popaFactory.setPopaMinter(contracts.stakeRewards.address); // Set minter as stake rewards because stake rewards does not accept payment un-authorized accounts
    await expectError(contracts.popaFactory.connect(signers.user1).claim(period.id, { value: requiredPopaPayment }), "Transfer failed", "Should throw error claim payment transfer failed");
    await contracts.popaFactory.setPopaMinter(signers.popaMinter.address);
    //endregion

    expect(await contracts.popaFactory.popaClaimed(signers.user1.address, period.id)).to.equal(false);
    await contracts.popaFactory.connect(signers.user1).claim(period.id, { value: requiredPopaPayment }); // Claim period popa
    expect(await contracts.popaFactory.popaClaimed(signers.user1.address, period.id)).to.equal(true);
    expect(await contracts.popaFactory.claimableCheck(signers.user1.address, period.id)).to.equal(false);

    await expectError(contracts.popaFactory.connect(signers.user1).claim(period.id, { value: requiredPopaPayment }), "You already claimed this popa nft", "Shouldn't multiple claim same period popa");
    await expectError(contracts.popaFactory.connect(signers.user3).claim(period.id, { value: requiredPopaPayment }), "Claim conditions not met", "Shouldn't claim if claim conditions not met");

    const popaBalanceBeforeMint = await popaContract.balanceOf(signers.user1.address);
    expect(popaBalanceBeforeMint.toNumber()).to.equal(0, "User popa balance should be zero before mint. Claim completed & Not minted yet");

    //region Mint claimed popa test block
    const randomPopaID = 33552;

    await expectError(contracts.popaFactory.connect(signers.user2).mintClaimedPopa(signers.user1.address, period.id, randomPopaID), "Only call from minter", "Only call from minter");
    await expectError(contracts.popaFactory.connect(signers.popaMinter).mintClaimedPopa(signers.user1.address, 12837123, randomPopaID), "Unknown period id", "Should throw error when wrong period id given");
    await expectError(contracts.popaFactory.connect(signers.popaMinter).mintClaimedPopa(signers.user3.address, period.id, randomPopaID), "Not claimed by claimer", "Not claimed by claimer");

    expect(await contracts.popaFactory.popaMinted(signers.user1.address, period.id)).to.equal(false);
    await contracts.popaFactory.connect(signers.popaMinter).mintClaimedPopa(signers.user1.address, period.id, randomPopaID); // Mint PoPA with {Random} id
    expect(await contracts.popaFactory.popaMinted(signers.user1.address, period.id)).to.equal(true);

    await expectError(contracts.popaFactory.connect(signers.popaMinter).mintClaimedPopa(signers.user1.address, period.id, randomPopaID), "Already minted", "Shouldn't multiple mint already minted popa");
    //endregion

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

    const [snapshotAverageCalculation] = await contracts.stakeRewards.getSnapshotsAverageCalculation(signers.user1.address, currentSnapshotId, currentSnapshotId);
    expect(snapshotAverageCalculation.toNumber()).to.greaterThan(0, "Snapshot average calculation should be correct");
    //endregion

    //region Stake native reward with booster & Different chain
    expect(await contracts.stakeRewards.isRewardConfigsCompleted(6001)).to.equal(false, "Reward configs should be not completed on not-exist reward");

    const stakeRewardDiffChainId = 56;
    await contracts.stakeRewards.connect(signers.rewardDefiner).setRewardConfig(6001, false, 0, 0, 0, currentSnapshotId, currentSnapshotId); // Set reward snapshot range & Other options
    expect(await contracts.stakeRewards.isRewardClaimable(signers.user1.address, 6001, 0)).to.equal(false, "Reward shouldn't be claimable before configurations not completed");
    await contracts.stakeRewards.connect(signers.rewardDefiner).setRewardTiers(6001, [
      { stakeMin: 0, stakeMax: 4000, rewardAmount: 5000 },
      { stakeMin: 4001, stakeMax: 9000, rewardAmount: 10000 },
      { stakeMin: 9001, stakeMax: 20000, rewardAmount: 15000 }
    ]); // Set reward tiers (User1 should be in middle tier [10_000 unit reward])

    await expectError(
      contracts.stakeRewards.getRewardTier(6001, 55),
      "Tier index out of boundaries",
      "Should throw error when try to get not-exist reward tier index"
    );
    const rewardTier = await contracts.stakeRewards.getRewardTier(6001, 0);
    expect(rewardTier.rewardAmount.toNumber()).to.equal(5000, "Reward tier data should be correct");

    expect(await contracts.stakeRewards.getRewardTierCount(6001)).to.equal(3, "Reward tier count should be correct");

    await contracts.stakeRewards.connect(signers.rewardDefiner).setBooster(6001, 0, contracts.nft.address, 0, 10); // Set temporary booster
    await contracts.nft.mint(signers.user1.address, 6001); // Mint NFT as Booster

    await expectError(
      contracts.stakeRewards.connect(signers.rewardDefiner).setNativeReward(6001, stakeRewardDiffChainId, 0),
      "Reward data is not correct",
      "Should throw error when reward amount is zero"
    );

    await contracts.stakeRewards.connect(signers.rewardDefiner).setNativeReward(6001, stakeRewardDiffChainId, 50_000); // Set total 50_000 unit native reward on different chain
    const stakeNativeReward = await contracts.stakeRewards.getReward(6001);

    expect(stakeNativeReward.contractAddress).to.equal(ethers.constants.AddressZero, "Native reward contract address should be zero address");
    expect(stakeNativeReward.chainId.toNumber()).to.equal(stakeRewardDiffChainId, "Incorrect reward chain id");

    const claimNativeRewardDiffChainTx = await contracts.stakeRewards.connect(signers.user1).claimReward(6001, 0);
    expect(claimNativeRewardDiffChainTx).to.emit(contracts.stakeRewards, "RewardClaimDiffChain");

    const claimNativeRewardDiffChainTxUser2 = await contracts.stakeRewards.connect(signers.user2).claimReward(6001, 0);
    expect(claimNativeRewardDiffChainTxUser2).to.emit(contracts.stakeRewards, "RewardClaimDiffChain");

    const popaBoosterUsedPercentage = await contracts.stakeRewards.getAccountBoostPercentage(signers.user1.address, 6001, 0);
    expect(popaBoosterUsedPercentage.toNumber()).to.equal(0, "Popa booster percentage should be correct after used one-time");

    await contracts.stakeRewards.connect(signers.rewardDefiner).removeBooster(6001); // Remove temporary booster

    await expectError(
      contracts.stakeRewards.connect(signers.rewardDefiner).setNativeReward(6001, stakeRewardDiffChainId, 40_000),
      "This rewardId has claimed reward. Cant update",
      "Should throw error when try to update claimed reward"
    );
    //endregion

    //region Stake reward with tiers & vesting
    const startTime = ((await getNodeCurrentTime()) - 1);
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
