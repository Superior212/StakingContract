import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Define the initial amount of Ether to send to the contract on deployment
const INITIAL_CONTRACT_BALANCE = 10n * 1_000_000_000_000_000_000n; // 10 ETH in wei

const StakeEthModule = buildModule("StakeEthModule", (m) => {
  // Optional parameter for initial balance, with a default of 10 ETH
  const initialBalance = m.getParameter(
    "initialBalance",
    INITIAL_CONTRACT_BALANCE
  );

  // Deploy the StakeEth_2 contract
  const stakeEth = m.contract("StakeEther", [], {
    value: initialBalance,
  });

  return { stakeEth };
});

export default StakeEthModule;
