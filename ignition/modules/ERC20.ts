import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ERC20TokenModule = buildModule("ERC20TokenModule", (m) => {
  const initialSupply = m.getParameter(
    "initialSupply",
    1_000_000n * 10n ** 18n
  );

  const erc20Token = m.contract("ERC", [], {
    value: initialSupply,
  });

  return { erc20Token };
});

export default ERC20TokenModule;
