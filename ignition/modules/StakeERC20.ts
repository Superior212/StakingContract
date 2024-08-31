import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {
  const stakingTokenAddress = m.getParameter("stakingTokenAddress");

  const stakeERC20 = m.contract("StakeERC20", [stakingTokenAddress]);

  return { stakeERC20 };
});

export default StakeERC20Module;
