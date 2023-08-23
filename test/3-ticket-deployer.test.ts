import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { TicketDeployer, ZizyCompetitionTicket } from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("TicketDeployer", function() {
  let ticketDeployer: TicketDeployer | Contract;
  let owner: SignerWithAddress;
  let account1: SignerWithAddress;

  beforeEach(async function() {
    const TicketDeployerFactory = await ethers.getContractFactory("TicketDeployer");
    [owner, account1] = await ethers.getSigners();

    ticketDeployer = await TicketDeployerFactory.deploy(owner.address);
    await ticketDeployer.deployed();
  });

  it("should have correct initial state variables", async function() {
    expect(await ticketDeployer.getDeployedContractCount()).to.equal(0, "Deployed ticket count should be zero");
    expect(await ticketDeployer.owner()).to.equal(owner.address, "Wrong owner account");
  });

  it("shouldn't deploy ticket with an un-authorized account", async function() {
    try {
      await ticketDeployer.connect(account1).deploy("Random", "Random");
      assert.fail("Shouldn't deploy any ticket contract an un-authorized account");
    } catch (e: Error) {
      expect(e.message).to.contain("Ownable: caller is not the owner", "Shouldn't deploy any ticket contract an un-authorized account");
    }
  });

  it("should deploy ticket without error", async function() {
    expect(await ticketDeployer.deploy("Random", "Random"), "Should emit TicketDeployed event on deploy succeeded").to.emit(ticketDeployer, "TicketDeployed");
    expect(await ticketDeployer.getDeployedContractCount()).to.equal(1, "Deployed ticket count should be zero");
  });

  describe("TicketDeployer::Ticket", function() {
    let ticket: ZizyCompetitionTicket | Contract;
    const ticketInfo = {
      name: "Zizy Ticket",
      symbol: "ZTK"
    };

    beforeEach(async function() {
      await ticketDeployer.deploy(ticketInfo.name, ticketInfo.symbol);
      const TicketFactory = await ethers.getContractFactory("ZizyCompetitionTicket");
      const ticketContract = await ticketDeployer.tickets(0);
      ticket = await TicketFactory.attach(ticketContract);
    });

    it("should pass initial configurations check", async function() {
      expect(await ticket.owner()).to.equal(owner.address, "Wrong owner address");
      expect(await ticket.paused()).to.equal(false, "Should not paused on deploy");
      expect(await ticket.totalSupply()).to.equal(0, "Total supply should be zero");
      expect(await ticket.baseUri()).to.equal('', "Base URI should be empty");

      try {
        await ticket.tokenURI(236617);
        assert.fail("Shouldn't get token uri of un existent token");
      } catch (e: Error) {
        expect(e.message).to.contain("ERC721: invalid token ID", "Shouldn't get token uri of un existent token");
      }

      try {
        await ticket.connect(account1).mint(account1.address, 1000);
        assert.fail("Shouldn't mint ticket with un-authorized account");
      } catch (e: Error) {
        expect(e.message).to.contain("Ownable: caller is not the owner", "Shouldn't mint ticket with un-authorized account");
      }
    });

    it("support interface validations", async function() {
      expect(await ticket.supportsInterface('0x780e9d63')).to.equal(true, "Should support ERC721Enumerable interface id");
      expect(await ticket.supportsInterface('0x80ac58cd')).to.equal(true, "Should support ERC721 interface id");
      expect(await ticket.supportsInterface('0x00110011')).to.equal(false, "Shouldn't support not existed interface id");
    });


  });


});
