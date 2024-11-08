import { useEffect, useState, useMemo, useCallback } from 'react';
import { ethers, parseUnits, formatUnits } from 'ethers';
import './App.css';
import { FaWallet, FaBalanceScale, FaCoins } from 'react-icons/fa';
import { CONTRACT_ADDRESS, SUPPORTED_TOKENS, CONTRACT_ABI, TOKEN_ABI } from './components/constants'; // Import the data


function App() {
  const [currentAccount, setCurrentAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const [tokenContracts, setTokenContracts] = useState({});
  const [successMessage, setSuccessMessage] = useState('');
  const [orderType, setOrderType] = useState('buy');
  const [amountToken, setAmountToken] = useState(SUPPORTED_TOKENS[0].address); // Amount Token
  const [priceToken, setPriceToken] = useState(SUPPORTED_TOKENS[1].address); // Price Token
  const [amount, setAmount] = useState('');
  const [price, setPrice] = useState('');
  const [buyOrders, setBuyOrders] = useState([]);
  const [sellOrders, setSellOrders] = useState([]);
  const [allBuyOrders, setAllBuyOrders] = useState([]); // New state for all buy orders
  const [allSellOrders, setAllSellOrders] = useState([]); // New state for all sell orders
  const [userBalances, setUserBalances] = useState({});
  const [tokensDistributed, setTokensDistributed] = useState(false);
  const [viewFulfilled, setViewFulfilled] = useState(false);
  const [showFulfilled, setShowFulfilled] = useState(false);

  const [mintRecipient, setMintRecipient] = useState('');
  const [mintAmount, setMintAmount] = useState('');
  const [showTooltip, setShowTooltip] = useState(false);
  const [showMintingForm, setShowMintingForm] = useState(false);
  const [recipientAddress, setRecipientAddress] = useState('');
  const [selectedToken, setSelectedToken] = useState(SUPPORTED_TOKENS[0].address); // Use token address from imported data

  const [provider, setProvider] = useState(null);
  const [network, setNetwork] = useState(null);
  const [tokenBalances, setTokenBalances] = useState({});
  const [isWalletConnected, setIsWalletConnected] = useState(false);

  const [stopPrice, setStopPrice] = useState('');
  const [showStopPricePopup, setShowStopPricePopup] = useState(false);

  const supportedTokens = useMemo(() => SUPPORTED_TOKENS, []);
  const contractAddress = CONTRACT_ADDRESS; // Use contract address from imported data
  const contractABI = useMemo(() => CONTRACT_ABI, []); // Use contract ABI from imported data
  const tokenABI = useMemo(() => TOKEN_ABI, []); // Use token ABI from imported data

  const connectWallet = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        alert("Please install MetaMask!");
        return;
      }
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });
      setCurrentAccount(accounts[0]);
      console.log("Connected account:", accounts[0]);
    } catch (error) {
      console.log("Error connecting to wallet:", error);
    }
  };

  const disconnectWallet = () => {
    setCurrentAccount(null);
    setProvider(null);
    setNetwork(null);
    setTokenBalances({});
    setIsWalletConnected(false);

    if (provider && provider.disconnect) {
      provider.disconnect();
    }

    console.log('Wallet disconnected');
  };

  const mintTokens = async (recipient, amount, tokenType) => {
    if (!currentAccount) {
      setSuccessMessage('Please connect your wallet first.');
      return;
    }
    const tokenContract = tokenContracts[tokenType]; // Get the contract for the selected token

    if (!tokenContract) {
      setSuccessMessage('Token contract not found!');
      return;
    }

    const amountInUnits = parseUnits(amount, 18); // Ensure the amount is in correct units

    try {
      const tx = await tokenContract.mint(recipient, amountInUnits); // Mint the tokens
      await tx.wait(); // Wait for the transaction to be mined
      console.log(`${tokenType} minted successfully!`);
      setSuccessMessage(`${amount} Tokens => (${tokenType}) minted successfully!`); // Success message
      disconnectWallet();
    } catch (error) {
      console.error('Error minting tokens:', error);
      setSuccessMessage('Minting failed!'); // Failure message
    }
  };

  const handleMint = () => {
    if (!recipientAddress || !mintAmount || !selectedToken) {
      setSuccessMessage('Please fill in all fields!');
      return;
    }

    mintTokens(recipientAddress, mintAmount, selectedToken); // Call mintTokens with input values
  };

  const fetchUserBalances = useCallback(async () => {
    const balances = {};

    for (const token of supportedTokens) {
      const tokenContract = tokenContracts[token.address];

      if (tokenContract && currentAccount) {
        try {
          const balance = await tokenContract.balanceOf(currentAccount);
          balances[token.name] = formatUnits(balance, 18);
        } catch (error) {
          console.error(`Error fetching balance for ${token.name}:`, error);
        }
      }
    }
    setUserBalances(balances);
  }, [tokenContracts, currentAccount, supportedTokens]);

  const distributeTokens = useCallback(async (recipient, amount) => {
    const tokenAddresses = supportedTokens.map(token => token.address);

    for (const address of tokenAddresses) {
      const tokenContract = tokenContracts[address];
      if (tokenContract) {
        try {
          const tx = await tokenContract.distributeTokens(recipient, amount);
          await tx.wait();
        } catch (error) {
          console.error(`Error distributing tokens for ${address}:`, error);
        }
      } else {
        console.error(`Token contract for ${address} not found.`);
      }
    }

    setSuccessMessage('Tokens distributed successfully!');
    fetchUserBalances();  // Update balances after distribution
    setTokensDistributed(true); // Set the flag to indicate tokens have been distributed
  }, [supportedTokens, tokenContracts, fetchUserBalances]);

  const submitOrder = async () => {
    if (amountToken === priceToken) {
      setSuccessMessage('Error: You cannot place an order with the same type of tokens.');
      return;
    }
    if (contract && amountToken) {
      try {
        const amountInUnits = parseUnits(amount, 18); // Convert amount to units
        let priceInUnits = 0;

        if (price) {
          priceInUnits = parseUnits(price, 18);
        } else if (!price && !stopPrice) {
          // If price is empty, trigger the stop price popup for market order
          setShowStopPricePopup(true);
          return;
        }

        // Convert stop price to units if it was entered for a market order
        const finalPrice = stopPrice ? parseUnits(stopPrice, 18) : priceInUnits;

        // Determine the token contract based on the order type
        const tokenContract = orderType === 'sell' ? tokenContracts[amountToken] : tokenContracts[priceToken];

        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const userAddress = accounts[0];

        const balance = await tokenContract.balanceOf(userAddress);
        console.log(`User balance: ${balance} tokens`);

        // Step 1: Approve tokens for transfer
        console.log("Approving tokens for transfer");

        const amountToApprove = orderType === "sell" ? amountInUnits : finalPrice;
        const approveTx = await tokenContract.approve(contractAddress, amountToApprove);
        await approveTx.wait();

        // Step 2: Call createAndMatchBuyOrder or any order function
        let tx;
        if (orderType === 'buy') {
          if (price) {
            console.log("Normal Buy");
            tx = await contract.createAndMatchBuyOrder(amountToken, amountInUnits, priceToken, finalPrice);
          } else {
            console.log("Market Buy");
            tx = await contract.createMarketBuyOrder(amountToken, amountInUnits, priceToken);
          }
        } else if (orderType === 'sell') {
          if (price) {
            console.log("Normal Sell");
            tx = await contract.createAndMatchSellOrder(amountToken, amountInUnits, priceToken, finalPrice);
          } else {
            console.log("Market Sell");
            tx = await contract.createMarketSellOrder(amountToken, amountInUnits, priceToken);
          }
        }

        const newOrder = await tx.wait();
        setSuccessMessage('Order placed successfully!');
        console.log("New Order:", newOrder);
      } catch (error) {
        // Error handling
        if (error.message.includes("Transfer amount exceeds allowance")) {
          console.error('Insufficient allowance for transfer. Please approve the token first.');
          setSuccessMessage('Insufficient allowance for transfer. Please approve the token first.');
        } else {
          console.error('Error placing order:', error);
          setSuccessMessage('Order placement failed!');
        }
      }
    }
  };

  const fetchOrders = useCallback(async () => {
    if (contract && amountToken) {
      try {
        const buyOrdersResponse = await contract.getBuyOrders(amountToken, priceToken);
        const sellOrdersResponse = await contract.getSellOrders(priceToken, amountToken);

        const userBuyOrders = buyOrdersResponse.filter(order =>
          order.trader.toLowerCase() === currentAccount.toLowerCase() &&
          ((viewFulfilled && order.isFulfilled) || (!viewFulfilled && !order.isFulfilled)) &&
          !order.isCanceled
        );

        const userSellOrders = sellOrdersResponse.filter(order =>
          order.trader.toLowerCase() === currentAccount.toLowerCase() &&
          ((viewFulfilled && order.isFulfilled) || (!viewFulfilled && !order.isFulfilled)) &&
          !order.isCanceled
        );

        setBuyOrders(userBuyOrders);
        setSellOrders(userSellOrders);
      } catch (error) {
        console.error("Error fetching orders:", error);
      }
    }
  }, [contract, amountToken, priceToken, currentAccount, viewFulfilled]);


  const fetchAllOrders = useCallback(async () => {
    if (contract) {
      try {
        const allBuyOrders = [];
        const allSellOrders = [];

        // Loop through all combinations of supported tokens
        for (const inputToken of supportedTokens) {
          for (const outputToken of supportedTokens) {
            if (inputToken.address !== outputToken.address) {
              // Fetch buy orders
              const buyOrdersResponse = await contract.getBuyOrders(inputToken.address, outputToken.address);

              const formattedBuyOrders = buyOrdersResponse.map(order => ({
                id: order[0],
                trader: order[1],
                orderType: 'Buy',
                inputToken: order[3],
                inputAmount: order[4],
                outputToken: order[5],
                outputAmount: order[6],
                isFulfilled: order[7],
                isCanceled: order[8],
              }));

              // Filter buy orders for the current user, only unfulfilled and uncanceled orders
              const userBuyOrders = formattedBuyOrders.filter(order =>
                order.trader.toLowerCase() === currentAccount.toLowerCase() &&
                !order.isCanceled
              );
              allBuyOrders.push(...userBuyOrders);

              // Fetch sell orders
              const sellOrdersResponse = await contract.getSellOrders(outputToken.address, inputToken.address);
              const formattedSellOrders = sellOrdersResponse.map(order => ({
                id: order[0],
                trader: order[1],
                orderType: 'Sell',
                inputToken: order[5],
                inputAmount: order[4],
                outputToken: order[3],
                outputAmount: order[6],
                isFulfilled: order[7],
                isCanceled: order[8],
              }));

              // Filter sell orders for the current user, only unfulfilled and uncanceled orders
              const userSellOrders = formattedSellOrders.filter(order =>
                order.trader.toLowerCase() === currentAccount.toLowerCase() &&
                !order.isCanceled
              );
              allSellOrders.push(...userSellOrders);
            }
          }
        }

        // Update the state with the accumulated user's orders
        setAllBuyOrders(allBuyOrders);
        setAllSellOrders(allSellOrders);
      } catch (error) {
        console.error("Error fetching all orders:", error);
      }
    }
  }, [contract, supportedTokens, currentAccount]);


  const cancelOrder = async (orderId, orderType, inputToken, outputToken) => {
    if (contract) {
      try {
        let tx;
        if (orderType === 'buy') {
          tx = await contract.cancelBuyOrder(orderId, inputToken, outputToken);
        } else {
          tx = await contract.cancelSellOrder(orderId, inputToken, outputToken);
        }
        await tx.wait();
        setSuccessMessage('Order canceled successfully!');
        await fetchOrders(); // Refresh orders after cancellation
      } catch (error) {
        console.error('Error canceling order:', error);
        setSuccessMessage('Order cancellation failed!');
      }
    }
  };


  useEffect(() => {
    const initializeContract = async () => {
      if (currentAccount) {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();

        // Set the contract instance using the already deployed contract address
        const contractInstance = new ethers.Contract(contractAddress, contractABI, signer);

        // Extract token addresses from supportedTokens array
        const myTokenAddress = supportedTokens.find(token => token.name === 'MyToken').address;
        const tokenAAddress = supportedTokens.find(token => token.name === 'TokenA').address;
        const tokenBAddress = supportedTokens.find(token => token.name === 'TokenB').address;

        // If your contract has a setter function, use it here (e.g., setTokenAddresses)
        // For example: await contractInstance.setTokenAddresses(myTokenAddress, tokenAAddress, tokenBAddress);

        setContract(contractInstance);

        const contracts = {};
        for (const token of supportedTokens) {
          const tokenInstance = new ethers.Contract(token.address, tokenABI, signer);
          contracts[token.address] = tokenInstance;
        }
        setTokenContracts(contracts);

        // Fetch all orders, user balances, etc.
        await fetchAllOrders(signer.address);
        await fetchOrders();
        await fetchUserBalances();
      }
    };

    initializeContract();

  }, [currentAccount, fetchOrders, fetchUserBalances, tokensDistributed, distributeTokens]);

  const hasUnfulfilledOrders = useMemo(() => {
    return buyOrders.some(order => !order.isFulfilled) || sellOrders.some(order => !order.isFulfilled);
  }, [buyOrders, sellOrders]);

  return (
    <div className="App">
      <header className="App-header">
        <h1>OrderBook DApp</h1>

        {!showMintingForm ? (
          <div>
            {/* Home Page */}
            {!currentAccount ? (
              <div className="button-container">
                <button
                  onClick={() => { connectWallet(); setShowMintingForm(true) }} // Show Minting Form
                  className="btn btn-asset"
                >
                  <FaCoins /> Asset Issuer
                </button>
                <button onClick={connectWallet} className="btn btn-wallet">
                  <FaWallet /> Connect Wallet
                </button>
              </div>
            ) : (
              <div className="content">
                <p className="connected-account">
                  Connected account: <span className="account-address">{currentAccount}</span>
                </p>

                <div className="balance-info">
                  <h3>Balances</h3>
                  <div className="balance-items">
                    {Object.entries(userBalances).map(([tokenName, balance]) => (
                      <p key={tokenName} className="balance-item">
                        <span className="token-name">{tokenName}</span> : {(balance)}
                      </p>
                    ))}
                  </div>
                </div>

                {/* Order Form */}
                <div className="order-form">
                  {/* Order Type Selection */}
                  <div className="order-type-info">
                    <select value={orderType} onChange={(e) => setOrderType(e.target.value)}>
                      <option value="buy">Buy</option>
                      <option value="sell">Sell</option>
                    </select>
                    {/* Info Icon */}
                    <span className="info-icon" onMouseEnter={() => setShowTooltip(true)} onMouseLeave={() => setShowTooltip(false)}>
                      ℹ️
                    </span>

                    {/* Tooltip */}
                    {showTooltip && (
                      <div className="tooltip">
                        <ul>
                          <li>Filling both fields will place Limit Order. Leaving <b>Amount</b> field empty will place Market Order.</li>
                          <li>Market Buy orders, gives the best exchange order for the tokens you are buying.</li>
                          <li>Market Sell orders, gives the best exchange order for the tokens you are selling.</li>
                        </ul>
                      </div>
                    )}

                  </div>

                  {/* Token and Amount Inputs in Parallel */}
                  <div className="input-row">
                    <div className="input-group">
                      <select value={amountToken} onChange={(e) => setAmountToken(e.target.value)}>
                        {supportedTokens.map((token) => (
                          <option key={token.address} value={token.address}>
                            {token.name}
                          </option>
                        ))}
                      </select>
                      <input
                        type="text"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                        placeholder="Amount"
                      />
                    </div>
                    <div className="input-group">
                      <select value={priceToken} onChange={(e) => setPriceToken(e.target.value)}>
                        {supportedTokens.map((token) => (
                          <option key={token.address} value={token.address}>
                            {token.name}
                          </option>
                        ))}
                      </select>
                      <input
                        type="text"
                        value={price}
                        onChange={(e) => setPrice(e.target.value)}
                        placeholder="Price"
                      />
                    </div>
                  </div>

                  <button onClick={submitOrder} className="btn btn-order">
                    Submit Order
                  </button>
                  {/* Popup for Stop Price */}
                  {showStopPricePopup && (
                    <div className="popup">
                      <div className="popup-content">
                        <h3>Enter Stop Price for Market Order</h3>
                        <input
                          type="text"
                          value={stopPrice}
                          onChange={(e) => setStopPrice(e.target.value)}
                          placeholder="Stop Price"
                        />
                        <button
                          onClick={() => {
                            setShowStopPricePopup(false);
                            submitOrder(); // Re-submit order with stop price
                          }}
                        >
                          Confirm
                        </button>
                        <button onClick={() => setShowStopPricePopup(false)}>Cancel</button>
                      </div>
                    </div>
                  )}
                  {successMessage && <p>{successMessage}</p>}
                </div>

                {/* Fulfillment Toggle Header */}
                <h2>Your Orders</h2>
                <div className="toggle-header-container">
                  <div className="toggle-header">
                    <span
                      className={`toggle-option ${!showFulfilled ? 'active' : ''}`}
                      onClick={() => setShowFulfilled(false)}
                    >
                      Unfulfilled Orders
                    </span>
                    <span
                      className={`toggle-option ${showFulfilled ? 'active' : ''}`}
                      onClick={() => setShowFulfilled(true)}
                    >
                      Fulfilled Orders
                    </span>
                  </div>
                </div>

                {/* Orders Table */}
                <div className="order-table">

                  {allBuyOrders.length === 0 && allSellOrders.length === 0 ? (
                    <p>You have no orders placed yet.</p>
                  ) : (
                    <div className="table-container"> {/* Add this div */}
                      <table className='centerTable'>
                        <thead>
                          <tr>
                            <th>Order Type</th>
                            <th>Token Being Bought (Amount)</th>
                            <th>Token Being Sold (Price)</th>

                            {showFulfilled ? null : <th>Fulfilled</th>}
                            {showFulfilled ? null : <th>Action</th>}
                          </tr>
                        </thead>
                        <tbody>
                          {allBuyOrders
                            .filter((order) => order.isFulfilled === showFulfilled)
                            .map((order) => (
                              <tr key={order.id}>
                                <td>Buy</td>
                                <td>
                                  {supportedTokens.find((t) => t.address === order.inputToken)?.name} (
                                  {formatUnits(order.inputAmount, 18)})
                                </td>
                                <td>
                                  {supportedTokens.find((t) => t.address === order.outputToken)?.name} (
                                  {formatUnits(order.outputAmount, 18)})
                                </td>
                                {!order.isFulfilled && !order.isCanceled && (
                                  <td>{order.isFulfilled ? "Yes" : "No"}</td>)}
                                {!order.isFulfilled && !order.isCanceled && (
                                  <td>
                                    <button onClick={() => cancelOrder(order.id, "buy", order.inputToken, order.outputToken)} className="btn btn-cancel">
                                      Cancel Order
                                    </button>
                                  </td>
                                )}
                              </tr>
                            ))}
                          {allSellOrders
                            .filter((order) => order.isFulfilled === showFulfilled)
                            .map((order) => (
                              <tr key={order.id}>
                                <td>Sell</td>
                                <td>
                                  {supportedTokens.find((t) => t.address === order.inputToken)?.name} (
                                  {formatUnits(order.outputAmount, 18)})
                                </td>
                                <td>
                                  {supportedTokens.find((t) => t.address === order.outputToken)?.name} (
                                  {formatUnits(order.inputAmount, 18)})
                                </td>
                                {!order.isFulfilled && !order.isCanceled && (
                                  <td>{order.isFulfilled ? "Yes" : "No"}</td>)}
                                {!order.isFulfilled && !order.isCanceled && (
                                  <td>
                                    <button onClick={() => cancelOrder(order.id, order.orderType, order.inputToken, order.outputToken)} className="btn btn-cancel">
                                      Cancel Order
                                    </button>
                                  </td>
                                )}
                              </tr>
                            ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        ) : (
          // Minting Page
          <div className="minting-form">
            <h3>Mint Tokens</h3>

            {/* Recipient Address Input */}
            <div className="input-group">
              <input
                type="text"
                value={recipientAddress}
                onChange={(e) => setRecipientAddress(e.target.value)}
                placeholder="Recipient Address"
              />
            </div>

            {/* Token Amount Input */}
            <div className="input-group">
              <input
                type="number"
                value={mintAmount}
                onChange={(e) => setMintAmount(e.target.value)}
                placeholder="Amount to Mint"
              />
            </div>

            {/* Select Token Type */}
            <div className="input-group">
              <select
                value={selectedToken}
                onChange={(e) => setSelectedToken(e.target.value)} // Set selected address as value
              >
                {supportedTokens.map((token) => (
                  <option key={token.address} value={token.address}>
                    {token.name}
                  </option>
                ))}
              </select>
            </div>


            {/* Mint Button */}
            <button onClick={handleMint} className="btn btn-mint">
              Mint Tokens
            </button>

            {/* Success or Error Message */}
            {successMessage && <p>{successMessage}</p>}

            {/* Back Button */}
            <button
              onClick={() => {
                disconnectWallet();
                setShowMintingForm(false)
              }} // Go back to Home Page
              className="btn btn-back"
            >
              Back to Orders
            </button>
          </div>
        )}
      </header>
    </div >
  );
}

export default App;