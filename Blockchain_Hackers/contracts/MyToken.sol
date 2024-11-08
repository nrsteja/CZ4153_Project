// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Author: @nrsteja
contract MyToken is ERC20 {

    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply); // Mint initial supply to contract owner
    }

    // Function to mint tokens to any account, only callable by the owner
    function mint(address recipient, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        _mint(recipient, amount);
    }

    // Standard ERC20 `approve` function for setting an allowance
    function approve(address spender, uint256 amount) public override returns (bool) {
        return super.approve(spender, amount);
    }

    // Implement `transferFrom` function for token transfers based on allowance
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Cannot transfer to the zero address");
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");

        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);
        return true;
    }
}

// Contract for TokenA
contract TokenA is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenA", "TKA") {
        _mint(msg.sender, initialSupply); // Mint initial supply to contract owner
    }

    // Function to mint tokens to any account, only callable by the owner
    function mint(address recipient, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        _mint(recipient, amount);
    }

    // Standard ERC20 `approve` function for setting an allowance
    function approve(address spender, uint256 amount) public override returns (bool) {
        return super.approve(spender, amount);
    }

    // Implement `transferFrom` function for token transfers based on allowance
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Cannot transfer to the zero address");
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");

        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);
        return true;
    }
}

// Contract for TokenB
contract TokenB is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenB", "TKB") {
        _mint(msg.sender, initialSupply); // Mint initial supply to contract owner
    }

    // Function to mint tokens to any account, only callable by the owner
    function mint(address recipient, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        _mint(recipient, amount);
    }

    // Standard ERC20 `approve` function for setting an allowance
    function approve(address spender, uint256 amount) public override returns (bool) {
        return super.approve(spender, amount);
    }

    // Implement `transferFrom` function for token transfers based on allowance
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Cannot transfer to the zero address");
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");

        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);
        return true;
    }
}
