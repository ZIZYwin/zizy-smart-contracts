import { ethers } from "hardhat";
import { TicketDeployer, ZizyPoPa } from "../typechain-types";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { expectError } from "../scripts/helpers/TestHelpers";

describe("ZizyPoPa", function() {
  let owner: SignerWithAddress;
  let account1: SignerWithAddress;
  let minter: SignerWithAddress;

  beforeEach(async function() {
    [owner, account1, minter] = await ethers.getSigners();
  });

  it("shouldn't deploy with minter zero address", async function() {
    const popaFactory = await ethers.getContractFactory("ZizyPoPa");
    try {
      await popaFactory.deploy("Random", "Random", ethers.constants.AddressZero);
      assert.fail("Shouldn't deploy with zero address minter");
    } catch (e: Error) {
      await expect(e.message).to.contain("Minter account can not be zero", "Shouldn't deploy with zero address minter");
    }
  });

  describe("After::Deployment", function() {
    let popa: ZizyPoPa | Contract;
    const popaInfo = {
      name: "Zizy Popa",
      symbol: "ZPOP"
    };

    beforeEach(async function() {
      const ZizyPoPaFactory = await ethers.getContractFactory("ZizyPoPa");
      [owner, account1] = await ethers.getSigners();

      popa = await ZizyPoPaFactory.deploy(popaInfo.name, popaInfo.symbol, owner.address);
      await popa.deployed();
    });

    it("should pass initial configurations check", async function() {
      await expect(await popa.owner()).to.equal(owner.address, "Wrong owner address");
      await expect(await popa.paused()).to.equal(false, "Should not paused on deploy");
      await expect(await popa.totalSupply()).to.equal(0, "Total supply should be zero");
      await expect(await popa.baseUri()).to.equal("", "Base URI should be empty");

      await expectError(popa.tokenURI(236617), "ERC721: invalid token ID", "Shouldn't get token uri of un existent token");
      await expectError(popa.connect(account1).mint(account1.address, 1000), "Only call from minter", "Shouldn't mint popa with un-authorized account");
    });

    it("support interface validations", async function() {
      await expect(await popa.supportsInterface("0x780e9d63")).to.equal(true, "Should support ERC721Enumerable interface id");
      await expect(await popa.supportsInterface("0x80ac58cd")).to.equal(true, "Should support ERC721 interface id");
      await expect(await popa.supportsInterface("0x00110011")).to.equal(false, "Shouldn't support not existed interface id");
    });

    it("shouldn't change minter account with wrong conditions", async function() {
      await expectError(popa.connect(account1).setMinter(account1.address), "Ownable: caller is not the owner", "Shouldn't change minter account from un-authorized account");
      await expectError(popa.setMinter(ethers.constants.AddressZero), "Minter account can not be zero", "Minter account can not be zero");
    });

    it("base uri validation", async function() {
      await expect(await popa.baseUri()).to.equal("", "Initial base uri should be empty");
      const newBaseUri = "https://random.host/base-uri/";
      const baseUriUpdate = await popa.setBaseURI(newBaseUri);

      await expect(baseUriUpdate, "Should emit BaseURIUpdated event after base uri changed").to.emit(popa, "BaseURIUpdated");
      await expect(await popa.baseUri()).to.equal(newBaseUri, "Wrong base uri");

      await expectError(popa.connect(account1).setBaseURI(newBaseUri), "Ownable: caller is not the owner", "Shouldn't change base uri from un-authorized account");
    });

    it("pausable extension checks", async function() {
      expect(await popa.paused()).to.equal(false, "PoPa shouldn't be paused on initial deployment");
      await expectError(popa.connect(account1).pause(), "Ownable: caller is not the owner", "Shouldn't pause with un-authorized account");
      await expectError(popa.connect(account1).unpause(), "Ownable: caller is not the owner", "Shouldn't pause with un-authorized account");

      await expectError(popa.unpause(), "Pausable: not paused", "Shouldn't un-pause already un-paused");

      const pauseTransaction = await popa.pause();
      expect(pauseTransaction, "Should emit `Paused` event after pause call").to.emit(popa, "Paused");
      expect(await popa.paused()).to.equal(true, "Should pause correctly");
      await expectError(popa.pause(), "Pausable: paused", "Shouldn't pause when already paused");

      const unPauseTransaction = await popa.unpause();
      expect(unPauseTransaction, "Should emit `Unpaused` event after unpause call").to.emit(popa, "Unpaused");
    });

    it("internal _baseUri & external tokenUri validation", async function() {
      await popa.mint(account1.address, 500); // Mint token with 500 ID

      const tokenUriBeforeBaseUriSet = await popa.tokenURI(500);
      await popa.setBaseURI(`https://random.host/`);
      const tokenUriAfterBaseUriSet = await popa.tokenURI(500);

      expect(tokenUriBeforeBaseUriSet).to.equal("", "Token URI should be empty before base uri definition");
      expect(tokenUriAfterBaseUriSet).to.equal("https://random.host/500", "Token URI should be correct after base uri definition");
    });
  });


});
