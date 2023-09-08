import { ethers } from "hardhat";
import { ZizyCompetitionTicket } from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { expectError } from "../scripts/helpers/TestHelpers";

describe("ZizyCompetitionTicket", function() {
  let owner: SignerWithAddress;
  let account1: SignerWithAddress;
  let minter: SignerWithAddress;
  let ticket: ZizyCompetitionTicket | Contract;

  beforeEach(async function() {
    [owner, account1, minter] = await ethers.getSigners();

    const ticketInfo = {
      name: "Ticket",
      symbol: "TCK"
    };

    const Factory = await ethers.getContractFactory("ZizyCompetitionTicket");

    ticket = await Factory.deploy(ticketInfo.name, ticketInfo.symbol);
    await ticket.deployed();
  });

  it("should pass initial configurations check", async function() {
    await expect(await ticket.owner()).to.equal(owner.address, "Wrong owner address");
    await expect(await ticket.paused()).to.equal(false, "Should not paused on deploy");
    await expect(await ticket.totalSupply()).to.equal(0, "Total supply should be zero");
    await expect(await ticket.baseUri()).to.equal("", "Base URI should be empty");

    await expectError(ticket.tokenURI(236617), "ERC721: invalid token ID", "Shouldn't get token uri of un existent token");
    await expectError(ticket.connect(account1).mint(account1.address, 1000), "Ownable: caller is not the owner", "Shouldn't mint ticket with un-authorized account");
  });

  it("support interface validations", async function() {
    await expect(await ticket.supportsInterface("0x780e9d63")).to.equal(true, "Should support ERC721Enumerable interface id");
    await expect(await ticket.supportsInterface("0x80ac58cd")).to.equal(true, "Should support ERC721 interface id");
    await expect(await ticket.supportsInterface("0x00110011")).to.equal(false, "Shouldn't support not existed interface id");
  });

  it("base uri validation", async function() {
    await expect(await ticket.baseUri()).to.equal("", "Initial base uri should be empty");
    const newBaseUri = "https://random.host/base-uri/";
    const baseUriUpdate = await ticket.setBaseURI(newBaseUri);

    await expect(baseUriUpdate, "Should emit BaseURIUpdated event after base uri changed").to.emit(ticket, "BaseURIUpdated");
    await expect(await ticket.baseUri()).to.equal(newBaseUri, "Wrong base uri");

    await expectError(ticket.connect(account1).setBaseURI(newBaseUri), "Ownable: caller is not the owner", "Shouldn't change base uri from un-authorized account");
  });

  it("pausable extension checks", async function() {
    expect(await ticket.paused()).to.equal(false, "Shouldn't be paused on initial deployment");
    expect(await ticket.isPaused()).to.equal(false, "Shouldn't be paused on initial deployment");
    await expectError(ticket.connect(account1).pause(), "Ownable: caller is not the owner", "Shouldn't pause with un-authorized account");
    await expectError(ticket.connect(account1).unpause(), "Ownable: caller is not the owner", "Shouldn't pause with un-authorized account");

    await expectError(ticket.unpause(), "Pausable: not paused", "Shouldn't un-pause already un-paused");

    const pauseTransaction = await ticket.pause();
    expect(pauseTransaction, "Should emit `Paused` event after pause call").to.emit(ticket, "Paused");
    expect(await ticket.paused()).to.equal(true, "Should pause correctly");
    await expectError(ticket.pause(), "Pausable: paused", "Shouldn't pause when already paused");

    const unPauseTransaction = await ticket.unpause();
    expect(unPauseTransaction, "Should emit `Unpaused` event after unpause call").to.emit(ticket, "Unpaused");
  });

  it("internal _baseUri & external tokenUri validation", async function() {
    await ticket.mint(account1.address, 500); // Mint token with 500 ID

    const tokenUriBeforeBaseUriSet = await ticket.tokenURI(500);
    await ticket.setBaseURI(`https://random.host/`);
    const tokenUriAfterBaseUriSet = await ticket.tokenURI(500);

    expect(tokenUriBeforeBaseUriSet).to.equal("", "Token URI should be empty before base uri definition");
    expect(tokenUriAfterBaseUriSet).to.equal("https://random.host/500", "Token URI should be correct after base uri definition");
  });


});
