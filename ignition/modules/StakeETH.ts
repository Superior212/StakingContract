import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const INITIAL_CONTRACT_BALANCE = (1n * 1_000_000_000_000_000_000n) / 10n;

const StakeEthModule = buildModule("StakeEthModule", (m) => {
  const initialBalance = m.getParameter(
    "initialBalance",
    INITIAL_CONTRACT_BALANCE
  );

  const stakeEth = m.contract("StakeEther", [], {
    value: initialBalance,
  });

  return { stakeEth };
});

export default StakeEthModule;
//https://sepolia-blockscout.lisk.com/address/0x9D3688360DD7D00F0f7EEf32c0eeDD6Dc61bf301#code