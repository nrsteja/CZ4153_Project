// Define contract and token addresses in this file

export const CONTRACT_ADDRESS = '0xB5133E3F64F2B8ac3Ec6D1098b2CB776b564B26b'; // Main contract address

export const SUPPORTED_TOKENS = [
    { name: 'MyToken', address: '0x67195Fba0B4Ff375eeDa2c7cDa9ad7d702B67f1d' },
    { name: 'TokenA', address: '0x630bC7a727C43265be20758a02eF7EcE8Be3a85E' },
    { name: 'TokenB', address: '0x49510E494946EC6c8E41e381627058CBA5d52658' },
];

export const CONTRACT_ABI = [
    "function createAndMatchBuyOrder(address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount) external returns ((uint id, address trader, uint8 orderType, address inputToken, uint inputAmount, address outputToken, uint outputAmount, bool isFulfilled, bool isCanceled))",
    "function createAndMatchSellOrder(address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount) external returns ((uint id, address trader, uint8 orderType, address inputToken, uint inputAmount, address outputToken, uint outputAmount, bool isFulfilled, bool isCanceled))",
    "function cancelBuyOrder(uint256 orderId, address inputToken, address outputToken) external",
    "function cancelSellOrder(uint256 orderId, address inputToken, address outputToken) external",
    "function getBuyOrders(address inputToken, address outputToken) external view returns ((uint256 id, address trader, uint8 orderType, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount, bool isFulfilled, bool isCanceled)[])",
    "function getSellOrders(address inputToken, address outputToken) external view returns ((uint256 id, address trader, uint8 orderType, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount, bool isFulfilled, bool isCanceled)[])",
    "function createMarketBuyOrder(address inputToken, uint256 inputAmount, address outputToken) external returns ((uint id, address trader, uint8 orderType, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount, bool isFulfilled, bool isCanceled))",
    "function createMarketSellOrder(address outputToken, uint256 outputAmount, address inputToken) external returns ((uint id, address trader, uint8 orderType, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount, bool isFulfilled, bool isCanceled))"
];

export const TOKEN_ABI = [
    "function balanceOf(address owner) view returns (uint256)",
    "function approve(address spender, uint256 amount) returns (bool)",
    "function transfer(address to, uint256 amount) returns (bool)", // Standard ERC20 transfer
    "function transferFrom(address from, address to, uint256 amount) returns (bool)",
    "function mint(address recipient, uint256 amount) external", // Mint function for all tokens
];
