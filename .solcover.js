module.exports = {
  skipFiles: [
    "test/DepositWithdrawTest.sol",
    "explore/ExploreRewards.sol"
  ],
  modifierWhitelist: ["onlyOwner", "nonReentrant", "initializer", "onlyRewardDefiner", "whenFeeAddressExist", "stakeContractIsSet", "ticketDeployerIsSet", "paymentReceiverIsSet", "stakingContractIsSet"]
};
