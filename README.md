# **Decentralized Exchange (DEX) on Ethereum**

This project is a minimal decentralized exchange (DEX) built on the Ethereum blockchain, allowing users to trade tokens without relying on a centralized exchange and maintaining full control over their assets. The solution consists of two parts:

- **Smart Contracts** - Deployed on the Sepolia testnet using Hardhat and Ignition.
- **Frontend** - A React application for interacting with the DEX.

## **Features**

- **Minting Tokens**: Asset issuers can mint tokens for users.
- **Order Matching**: Users can place buy and sell orders.
- **Token Swapping**: Supports swapping between different tokens listed on the exchange.
- **Limit and Market Orders**: Users can submit limit and market orders.
- **Decentralized**: No third-party key management; users control their own assets.

## **Prerequisites**

Before deploying the DEX, ensure you have the following installed:

- **Node.js** (>=v18)
- **npm**
- **Hardhat Ignition** for seamless deployments
- A wallet (e.g., MetaMask) and **Sepolia testnet ETH** (for deployment)

## **Getting Started**

### **1. Clone the Repository**


```bash
git clone https://github.com/your-username/your-dex-project.git
cd Blockchain_Hackers
```

### **2. Install Dependencies**

Install the required dependencies for both the frontend and smart contracts:

```bash
npm install
```

### **3. Configure Environment Variables**

You need to configure your environment variables to deploy to the Sepolia testnet. Create a `.env` file in the root of your project and add the following variables:

```bash
ALCHEMY_API_KEY=<your_alchemy_api_key>
ETHERSCAN_API_KEY=<your_etherscan_api_key>
SEPOLIA_PRIVATE_KEY=<your_sepolia_private_key>
```
- `ALCHEMY_API_KEY`: You can get an Alchemy API key by signing up at [Alchemy](https://www.alchemy.com).
- `ETHERSCAN_API_KEY`: You can get an Etherscan API key by signing up at [Etherscan](https://etherscan.io).
- `SEPOLIA_PRIVATE_KEY`: The private key of your wallet on the Sepolia testnet. Be careful to keep this private and never expose it in public repositories.

