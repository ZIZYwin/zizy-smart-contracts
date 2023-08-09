import { expect } from "chai";

const { upgrades, ethers } = require("hardhat");

import {
  CompetitionFactory,
  StakeRewards,
  TicketDeployer,
  ZizyCompetitionStaking, ZizyCompetitionTicket,
  ZizyERC20, ZizyPoPaFactory, ZizyRewardsHub
} from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

//region Interfaces
interface IContracts {
  zizy: ZizyERC20 | Contract,
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

describe("Full System Test", function() {
  //region Test globals
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

  const getTimestamp = () => {
    return Math.floor((new Date()).getTime() / 1000);
  };
  const day = (dayCount: number) => {
    return (dayCount * 24 * 60 * 60);
  };
  //endregion

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
    //endregion

    //region Transfer ZIZY
    await contracts.zizy.transfer(signers.user1.address, 20_000); // Transfer zizy token to user1
    await contracts.zizy.connect(signers.user1).approve(contracts.staking.address, 20_000); // Give allowance to staking contract
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

  });

});
