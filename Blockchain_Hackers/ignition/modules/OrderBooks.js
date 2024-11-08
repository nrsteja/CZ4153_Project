// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("OrdersHandle", (m) => {
    // Replace these with actual addresses for the tokens
    const tokenAAddress = "0x630bC7a727C43265be20758a02eF7EcE8Be3a85E";  // Replace with the actual address of TokenA
    const tokenBAddress = "0x49510E494946EC6c8E41e381627058CBA5d52658";  // Replace with the actual address of TokenB
    const myTokenAddress = "0x67195Fba0B4Ff375eeDa2c7cDa9ad7d702B67f1d"; // Replace with the actual address of MyToken

    // Deploy the OrderBooks contract with constructor parameters
    const orderBooks = m.contract("OrderBooks", [tokenAAddress, tokenBAddress, myTokenAddress]);

    // Return the deployed contract
    return { orderBooks };
});

