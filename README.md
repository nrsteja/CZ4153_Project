# **Decentralized Exchange (DEX) on Ethereum**
## ***Blockchain Hackers***

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

### **4. Run a Local Hardhat Network (for testing)**

To deploy and test your contracts in a local environment that simulates an Ethereum testnet, you can use the Hardhat network.

```bash
npx hardhat node
```
This command launches a local Ethereum network at `localhost:8545` with a set of pre-funded test accounts. This setup allows you to deploy and test your DEX application entirely on a private, simulated testnet.

### **5. Deploy the Smart Contracts**
Once the environment variables are set up, deploy both the smart contracts (Token Generation contract and Order Management contract) to the Sepolia testnet using Hardhat:

1. Deploy the `MyToken` contract:

```bash
npx hardhat ignition deploy ./ignition/modules/MyToken.js --network sepolia --verify
```

2. **Update the contract addresses** for `MyToken`, `TokenA`, and `TokenB` (from the deployment step) inside the `./ignition/modules/OrderBooks.js` file.

In the `./ignition/modules/OrderBooks.js` file, modify the contract address references like this:

```javascript
export const CONTRACT_ADDRESS = '<your_OrderBooks_contract_address>'; // Main contract address

export const SUPPORTED_TOKENS = [
  { name: 'MyToken', address: '<your_MyToken_contract_address>' },
  { name: 'TokenA', address: '<your_TokenA_contract_address>' },
  { name: 'TokenB', address: '<your_TokenB_contract_address>' }
];
```

3. Deploy the `OrderBooks` contract:

```bash
npx hardhat ignition deploy ./ignition/modules/OrderBooks.js --network sepolia --verify
```

### **6. Frontend Setup**

To configure the frontend to connect to the Sepolia testnet, follow these steps:

1. In the `src/components/constants.js` file of your React app, update the `OrderBook` contract address and the contract addresses for `MyToken`, `TokenA`, and `TokenB` (from the deployment step) and the Sepolia network settings.

```javascript
export const CONTRACT_ADDRESS = '<your_OrderBooks_contract_address>'; // Main contract address

export const SUPPORTED_TOKENS = [
  { name: 'MyToken', address: '<your_MyToken_contract_address>' },
  { name: 'TokenA', address: '<your_TokenA_contract_address>' },
  { name: 'TokenB', address: '<your_TokenB_contract_address>' }
];
```

2. **Start the Frontend**

Navigate to the frontend directory and start the React app:

```bash
cd webapp
npm start
```
The app should now be running locally. You can access it at `http://localhost:3000`.

### **7. Interacting with the DEX**

Once everything is deployed, you can:

1. **Place buy and sell orders** using the web interface.
2. **View and manage your active orders**.
3. **Swap tokens** by matching orders.

The frontend will allow you to interact with the deployed smart contracts, enabling seamless trading and token management directly through the DEX.


### **8. Blockchain Hackers Architecture**

![image](https://github.com/user-attachments/assets/03622888-3daa-4bed-aef3-5164d8c1cf4d)

This dApp architecture enables decentralized token creation, token swapping, and balance management through a frontend (JavaScript-based) interface and integrated smart contracts on the Hardhat network.

### System Components

1. **User Interaction**:  
   The user interacts with the dApp's frontend to perform actions such as minting new tokens, creating orders, and viewing balances.
  
2. **Wallet/Signer**:  
   Metamask or similar wallets act as the user's signer for transaction authorization, enabling secure interaction with the blockchain.

3. **DEX Contracts**:  
   The decentralized exchange (DEX) contracts facilitate essential functions like minting tokens, executing token swaps, and updating balances. These contracts interact with the ERC20 contract to manage token approvals and transfers.

4. **ERC20 Contract**:  
   This standard contract handles token-specific actions, such as approving transactions and transferring tokens, ensuring compliance with the ERC20 token standard.

5. **Hardhat Network**:  
   The Hardhat network, running multiple nodes, serves as the blockchain test environment, simulating a live network for deploying and testing the smart contracts.


### **9. Features**

### **9.1 Metamask Integration**

![image](https://github.com/user-attachments/assets/7ec26558-faa1-4616-8901-546552df36c1)

Users must install Metamask to use this application.

### **9.2 Asset Issuers - Minting Tokens**

![image](https://github.com/user-attachments/assets/46f06627-fad2-4cd4-8ae3-cc4acc6f4f10)

Asset Issuers can mint any one of the 3 Tokens: `MyToken`, `TokenA`, `TokenB`, to the users.

### **9.3 Placing Orders**

Different Transactions supported by Blockchain Hackers:

1. Limit Orders (Buy/Sell)

![image](https://github.com/user-attachments/assets/77b595a3-9986-4218-9fec-c865dec403f1)

2. Market Orders (Buy/Sell)

![image](https://github.com/user-attachments/assets/aebc7e25-14db-4afa-8b0e-f09e4b4961d5)
  

### **9.4 View Order Placed**

1. Unfilled Orders waiting for the other matching orders in the market

2. Fulfilled Orders to track the orders placed by the users so far


### **9.5 View Account Balance**

![image](https://github.com/user-attachments/assets/e472da6d-0bc5-4658-aaaa-b111c076670b)

Users are able to view their account balances for all the 3 Tokens: `MyToken`, `TokenA`, `TokenB` available in the market.

### **9.6 Cancel Orders**

Users are able to cancel the orders they made which are not fulfilled or matched with other orders in the market. Only unfulfilled orders are matched.

### **9.7 Information Page**

Information button is available to let users know about the application and how it works to avoid the confusions for the users when they place orders and improve the user-friendliness of the application.

### **9.8 Error Checking**

Cannot place orders between same Token Types and also orders are not matched for the same user (i.e) 2 orders placed by the same users are always not matched with each other.
