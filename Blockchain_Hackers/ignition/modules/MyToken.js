const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// Update the initial supply to 10 million tokens
const TEN_MILLION_TOKENS = 10_000_000n * 1_000_000n;

module.exports = buildModule("TokenDeployments", (m) => {
    // Define the parameter for initial supply (default is 10 million tokens)
    const initialSupply = m.getParameter("initialSupply", TEN_MILLION_TOKENS);

    // Deploy MyToken, TokenA, and TokenB with the same initial supply
    const myToken = m.contract("MyToken", [initialSupply]);
    const tokenA = m.contract("TokenA", [initialSupply]);
    const tokenB = m.contract("TokenB", [initialSupply]);

    // Return the deployed contract instances
    return { myToken, tokenA, tokenB };
});
