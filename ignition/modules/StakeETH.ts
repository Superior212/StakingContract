import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// const INITIAL_CONTRACT_BALANCE = 1n * 1_000_000_000_000_000_000n;
const INITIAL_CONTRACT_BALANCE = 0.1n * 1_000_000_000_000_000_000n;

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
