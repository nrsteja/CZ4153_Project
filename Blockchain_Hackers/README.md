Decentralized Exchange (DEX) on Ethereum
This project is a minimal decentralized exchange (DEX) built on the Ethereum blockchain. It allows users to trade tokens without relying on a centralized exchange, giving users full control over their assets. The solution consists of two parts:

Smart Contracts - Deployed on the Sepolia testnet using Hardhat and Ignition.
Frontend - A React application for interacting with the DEX.
Features
Minting Tokens: AssetIssuer mint tokens to the users.
Order Matching: Users can place buy and sell orders.
Token Swapping: Supports swapping between different tokens listed on the exchange.
Limit and Market Orders: Users can submit limit and market orders.
Decentralized: No third-party key management; users control their own assets.
Prerequisites
Before deploying the DEX, ensure you have the following installed:

Node.js (>=v18)
npm
Hardhat
Ignition for seamless deployments
A wallet (e.g., MetaMask) and Sepolia testnet ETH (for deployment)
Getting Started

1. Clone the repository

    git clone https://github.com/your-username/your-dex-project.git
    cd Blockchain_Hackers

2. Install dependencies
   Install the required dependencies for both the frontend and smart contract:

    npm install

3. Configure Environment Variables
   You need to configure your environment variables to deploy to the Sepolia testnet. Create a .env file in the root of your project and add the following variables:

    ALCHEMY_API_KEY=<your-alchemy-api-key>
    ETHERSCAN_API_KEY=<your-etherscan-api-key>
    SEPOLIA_PRIVATE_KEY=<your-sepolia-private-key>

    ALCHEMY_API_KEY: You can get an Alchemy API key by signing up at Alchemy.
    ETHERSCAN_API_KEY: You can get an Etherscan API key by signing up at Etherscan.
    SEPOLIA_PRIVATE_KEY: The private key of your wallet on the Sepolia testnet. Be careful to keep this private and never expose it in public repositories.

4. Run a Local Hardhat Network (for testing)
   To deploy and test your contracts in a local environment that simulates an Ethereum testnet, you can use the Hardhat network.

    npx hardhat node

    This command launches a local Ethereum network at localhost:8545 with a set of pre-funded test accounts. This setup allows you to deploy and test your DEX application entirely on a private, simulated testnet.

5. Deploy the Smart Contracts
   Once the environment variables are set up, deploy both the smart contracts (Token Generation contract and Order Management contract) to the Sepolia testnet using Hardhat:

    npx hardhat ignition deploy ./ignition/modules/MyToken.js --network sepolia --verify

b. Update the contract addresses for MyToken, TokenA, and TokenB (from the deployment step) inside the ./ignition/modules/OrderBooks.js file.

    npx hardhat ignition deploy ./ignition/modules/OrderBooks.js --network sepolia --verify

    This will deploy your smart contracts, including OrderBooks, and print the contract addresses. Make sure your wallet has enough Sepolia ETH (you can get it from a Sepolia faucet).

5. Frontend Setup
   Configure frontend to connect to the Sepolia testnet

    In the src/components/constants.js file of your React app, update the OrderBook contract address and the contract addresses for MyToken, TokenA, and TokenB and (from the deployment step) and the Sepolia network settings.

    export const CONTRACT_ADDRESS = '<your_OrderBooks_contract_address>'; // Main contract address

    export const SUPPORTED_TOKENS = [
    { name: 'MyToken', address: '<your_MyToken_contract_address>' },
    { name: 'TokenA', address: '<your_TokenA_contract_address>' },
    { name: 'TokenB', address: '<your_TokenB_contract_address>' },
    ];

6. Start the frontend
   Navigate to the frontend directory and start the React app:

    cd webapp
    npm start

The app should now be running locally. You can access it at http://localhost:3000.

7. Interacting with the DEX

    Once everything is deployed, you can:
    . Place buy and sell orders using the web interface.
    . View and manage your active orders.
    . Swap tokens by matching orders.
