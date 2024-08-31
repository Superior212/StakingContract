import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {
  const stakingTokenAddress = "0xEC824d6122f5D63A41Cb6AB8839362f342e2b35F";

  const stakeERC20 = m.contract("StakeERC20", [stakingTokenAddress]);

  return { stakeERC20 };
});

export default StakeERC20Module;


// ERC20TokenModule#ERC - 0xEC824d6122f5D63A41Cb6AB8839362f342e2b35F
// StakeERC20Module#StakeERC20 - 0x557CB58e6894F96931beA245D6d1Abd22844C439
// https://sepolia-blockscout.lisk.com/address/0x557CB58e6894F96931beA245D6d1Abd22844C439#code