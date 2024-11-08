// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MyToken.sol";

contract OrderBooks {
    enum OrderType { Buy, Sell }

    struct Order {
        uint id;
        address trader;
        OrderType orderType;
        address inputToken;
        uint inputAmount;
        address outputToken;
        uint outputAmount;
        bool isFulfilled;
        bool isCanceled;
    }

    MyToken private myToken;
    TokenA private tokenA;
    TokenB private tokenB;

    address[] public tokens;

    constructor(address _myTokenAddress, address _tokenAAddress, address _tokenBAddress) {
        myToken = MyToken(_myTokenAddress);
        tokenA = TokenA(_tokenAAddress);
        tokenB = TokenB(_tokenBAddress);

        // Initialize tokens array
        tokens.push(_myTokenAddress);
        tokens.push(_tokenAAddress);
        tokens.push(_tokenBAddress);
        orderCounter = 0;
    }

    mapping(address => mapping(address => Order[])) public buyOrders;
    mapping(address => mapping(address => Order[])) public sellOrders;

    // Define events
    event OrderCreated(
        uint indexed orderId,
        address indexed trader,
        OrderType orderType,
        address inputToken,
        uint inputAmount,
        address outputToken,
        uint outputAmount
    );
    event OrderPlaced(
        uint indexed orderId,
        address indexed trader,
        OrderType orderType,
        address inputToken,
        uint inputAmount,
        address outputToken,
        uint outputAmount
    );

    event OrderFulfilled(
        uint indexed orderId,
        address indexed trader,
        OrderType orderType,
        address inputToken,
        uint inputAmount,
        address outputToken,
        uint outputAmount
    );

    uint public orderCounter;

    event OrderCanceled(uint id, address indexed trader, OrderType orderType);

    // Function to create and match a buy order
    function createAndMatchBuyOrder(
        address inputToken,
        uint inputAmount,
        address outputToken,
        uint outputAmount
    ) external returns (Order memory) {
        orderCounter++;
        Order memory newOrder = Order({
            id: orderCounter,
            trader: msg.sender,
            orderType: OrderType.Buy,
            inputToken: inputToken,
            inputAmount: inputAmount,
            outputToken: outputToken,
            outputAmount: outputAmount,
            isFulfilled: false,
            isCanceled: false
        });

        uint remainingInputAmount = newOrder.inputAmount;
        uint remainingOutputAmount = newOrder.outputAmount;

        // First, try matching with sell orders
        Order[] storage sells = sellOrders[inputToken][outputToken];

        for (uint i = 0; i < sells.length; i++) {
            Order storage sellOrder = sells[i];

            if (sellOrder.isFulfilled || sellOrder.isCanceled) continue;

            uint amountToMatch = min(remainingOutputAmount, sellOrder.outputAmount);
            uint inputAmountNeeded = (amountToMatch * sellOrder.inputAmount) / sellOrder.outputAmount;


            uint sellOrderInputAmount = sellOrder.inputAmount;
            uint sellOrderOutputAmount = sellOrder.outputAmount;

            if (inputAmountNeeded <= remainingInputAmount) {
                // Perform the token transfers
                IERC20(outputToken).transferFrom(newOrder.trader, sellOrder.trader, amountToMatch);
                IERC20(inputToken).transferFrom(sellOrder.trader, newOrder.trader, inputAmountNeeded);

                // Update order amounts
                remainingInputAmount -= inputAmountNeeded;
                remainingOutputAmount -= amountToMatch;
                sellOrderInputAmount -= inputAmountNeeded;
                sellOrderOutputAmount -= amountToMatch;

                if (sellOrderOutputAmount == 0) {
                    sellOrder.isFulfilled = true;
                } else {
                    sellOrder.inputAmount = sellOrderInputAmount;
                    sellOrder.outputAmount = sellOrderOutputAmount;
                    orderCounter++;
                        Order memory newOrder3 = Order({
                            id: orderCounter,
                            trader: sellOrder.trader,
                            orderType: OrderType.Sell,
                            inputToken: sellOrder.inputToken,
                            inputAmount: inputAmountNeeded,
                            outputToken: sellOrder.outputToken,
                            outputAmount: amountToMatch,
                            isFulfilled: true,
                            isCanceled: false
                        });
                        sellOrders[sellOrder.inputToken][sellOrder.outputToken].push(newOrder3);
                }
                if (remainingOutputAmount == 0) {
                    newOrder.isFulfilled = true;
                    break;
                }
            }
        }

        // If there’s still remaining input amount, try matching with other buy orders
        if (remainingInputAmount > 0) {
            Order[] storage buys = buyOrders[outputToken][inputToken];
            for (uint j = 0; j < buys.length; j++) {
                Order storage buyOrder = buys[j];
                if (buyOrder.isFulfilled || buyOrder.isCanceled || buyOrder.trader == msg.sender) continue;

                uint amountToMatch = min(remainingOutputAmount, buyOrder.inputAmount);
                uint inputAmountNeeded = (amountToMatch * buyOrder.outputAmount) / buyOrder.inputAmount;

                uint buyOrderInputAmount = buyOrder.inputAmount;
                uint buyOrderOutputAmount = buyOrder.outputAmount;

                if (inputAmountNeeded <= remainingInputAmount) {
                    // Perform the token transfers
                    IERC20(outputToken).transferFrom(newOrder.trader, buyOrder.trader, amountToMatch);
                    IERC20(inputToken).transferFrom(buyOrder.trader, newOrder.trader, inputAmountNeeded);

                    // Update order amounts
                    remainingInputAmount -= inputAmountNeeded;
                    remainingOutputAmount -= amountToMatch;
                    buyOrderInputAmount -= amountToMatch;
                    buyOrderOutputAmount -= inputAmountNeeded;

                    if (buyOrderOutputAmount == 0) {
                        buyOrder.isFulfilled = true;
                    } else {
                        buyOrder.inputAmount = buyOrderInputAmount;
                        buyOrder.outputAmount = buyOrderOutputAmount;
                        orderCounter++;
                        Order memory newOrder2 = Order({
                            id: orderCounter,
                            trader: buyOrder.trader,
                            orderType: OrderType.Buy,
                            inputToken: buyOrder.inputToken,
                            inputAmount: amountToMatch,
                            outputToken: buyOrder.outputToken,
                            outputAmount: inputAmountNeeded,
                            isFulfilled: true,
                            isCanceled: false
                        });
                        buyOrders[buyOrder.inputToken][buyOrder.outputToken].push(newOrder2);
                    }
                    if (remainingOutputAmount == 0) {
                        newOrder.isFulfilled = true;
                        break;
                    }
                }
            }
        }

        // If still not fully matched, add the new order to the buy orders list
        if (remainingOutputAmount > 0) {
            newOrder.outputAmount = remainingOutputAmount;
        } else {
            emit OrderCreated(newOrder.id, msg.sender, OrderType.Buy, inputToken, inputAmount, outputToken, outputAmount);
        }
        buyOrders[inputToken][outputToken].push(newOrder);

        return newOrder;
    }

    function createAndMatchSellOrder(
        address inputToken,
        uint inputAmount,
        address outputToken,
        uint outputAmount
    ) external returns (Order memory) {
        orderCounter++;
        Order memory newOrder = Order({
            id: orderCounter,
            trader: msg.sender,
            orderType: OrderType.Sell,
            inputToken: inputToken,
            inputAmount: inputAmount,
            outputToken: outputToken,
            outputAmount: outputAmount,
            isFulfilled: false,
            isCanceled: false
        });

        uint remainingInputAmount = newOrder.inputAmount;
        uint remainingOutputAmount = newOrder.outputAmount;

        // First, try matching with buy orders
        Order[] storage buys = buyOrders[inputToken][outputToken];
        for (uint i = 0; i < buys.length; i++) {
            Order storage buyOrder = buys[i];
            if (buyOrder.isFulfilled || buyOrder.isCanceled) continue;

            uint amountToMatch = min(remainingOutputAmount, buyOrder.outputAmount);
            uint inputAmountNeeded = (amountToMatch * buyOrder.inputAmount) / buyOrder.outputAmount;

            uint buyOrderInputAmount = buyOrder.inputAmount;
            uint buyOrderOutputAmount = buyOrder.outputAmount;

            if (inputAmountNeeded <= remainingInputAmount) {
                // Perform the token transfers
                IERC20(inputToken).transferFrom(newOrder.trader, buyOrder.trader, inputAmountNeeded);
                IERC20(outputToken).transferFrom(buyOrder.trader, newOrder.trader, amountToMatch);

                // Update order amounts
                remainingInputAmount -= inputAmountNeeded;
                remainingOutputAmount -= amountToMatch;
                buyOrderInputAmount -= inputAmountNeeded;
                buyOrderOutputAmount -= amountToMatch;

                if (buyOrderOutputAmount == 0) {
                    buyOrder.isFulfilled = true;
                } else {
                    buyOrder.inputAmount = buyOrderInputAmount;
                    buyOrder.outputAmount = buyOrderOutputAmount;
                    orderCounter++;
                    Order memory newOrder2 = Order({
                        id: orderCounter,
                        trader: buyOrder.trader,
                        orderType: OrderType.Buy,
                        inputToken: buyOrder.inputToken,
                        inputAmount: inputAmountNeeded,
                        outputToken: buyOrder.outputToken,
                        outputAmount: amountToMatch,
                        isFulfilled: true,
                        isCanceled: false
                    });
                    buyOrders[buyOrder.inputToken][buyOrder.outputToken].push(newOrder2);
                }
                if (remainingOutputAmount == 0) {
                    newOrder.isFulfilled = true;
                    break;
                }
            }
        }

        // If there’s still remaining output amount, try matching with other sell orders
        if (remainingOutputAmount > 0) {
            Order[] storage sells = sellOrders[outputToken][inputToken];
            for (uint j = 0; j < sells.length; j++) {
                Order storage sellOrder = sells[j];
                if (sellOrder.isFulfilled || sellOrder.isCanceled || sellOrder.trader == msg.sender) continue;

                uint amountToMatch = min(remainingOutputAmount, sellOrder.inputAmount);
                uint inputAmountNeeded = (amountToMatch * sellOrder.outputAmount) / sellOrder.inputAmount;

                uint sellOrderInputAmount = sellOrder.inputAmount;
                uint sellOrderOutputAmount = sellOrder.outputAmount;

                if (inputAmountNeeded <= remainingInputAmount) {
                    // Perform the token transfers
                    IERC20(inputToken).transferFrom(newOrder.trader, sellOrder.trader, inputAmountNeeded);
                    IERC20(outputToken).transferFrom(sellOrder.trader, newOrder.trader, amountToMatch);

                    // Update order amounts
                    remainingInputAmount -= inputAmountNeeded;
                    remainingOutputAmount -= amountToMatch;
                    sellOrderInputAmount -= amountToMatch;
                    sellOrderOutputAmount -= inputAmountNeeded;

                    if (sellOrderOutputAmount == 0) {
                        sellOrder.isFulfilled = true;
                    } else {
                        sellOrder.inputAmount = sellOrderInputAmount;
                        sellOrder.outputAmount = sellOrderOutputAmount;
                        orderCounter++;
                        Order memory newOrder3 = Order({
                            id: orderCounter,
                            trader: sellOrder.trader,
                            orderType: OrderType.Sell,
                            inputToken: sellOrder.inputToken,
                            inputAmount: amountToMatch,
                            outputToken: sellOrder.outputToken,
                            outputAmount: inputAmountNeeded,
                            isFulfilled: true,
                            isCanceled: false
                        });
                        sellOrders[sellOrder.inputToken][sellOrder.outputToken].push(newOrder3);
                    }
                    if (remainingOutputAmount == 0) {
                        newOrder.isFulfilled = true;
                        break;
                    }
                }
            }
        }
        
        // If still not fully matched, add the new order to the sell orders list
        if (remainingOutputAmount > 0) {
            newOrder.outputAmount = remainingOutputAmount;
            emit OrderPlaced(newOrder.id, msg.sender, OrderType.Sell, inputToken, inputAmount, outputToken, outputAmount);
        } else {
            emit OrderCreated(newOrder.id, msg.sender, OrderType.Sell, inputToken, inputAmount, outputToken, outputAmount);
        }
        sellOrders[inputToken][outputToken].push(newOrder);

        return newOrder;
    }

    // Utility function to find the minimum of two values
    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    // Debugging event
    event Debug(string message, uint orderId, address trader, uint amount1, address trader2, uint amount2);


    function cancelBuyOrder(uint orderId, address inputToken, address outputToken) external {
        Order[] storage orders = buyOrders[inputToken][outputToken];
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].id == orderId && orders[i].trader == msg.sender) {
                orders[i].isCanceled = true;
                emit OrderCanceled(orderId, msg.sender, OrderType.Buy);
                return;
            }
        }
        revert("Order not found or not owned by caller");
    }

    function cancelSellOrder(uint orderId, address inputToken, address outputToken) external {
        Order[] storage orders = sellOrders[inputToken][outputToken];
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].id == orderId && orders[i].trader == msg.sender) {
                orders[i].isCanceled = true;
                emit OrderCanceled(orderId, msg.sender, OrderType.Sell);
                return;
            }
        }
        revert("Order not found or not owned by caller");
    }

    function getBuyOrders(address inputToken, address outputToken) external view returns (Order[] memory) {
        return buyOrders[inputToken][outputToken];
    }

    function getSellOrders(address inputToken, address outputToken) external view returns (Order[] memory) {
        return sellOrders[inputToken][outputToken];
    }

    function createMarketBuyOrder(address inputToken, uint inputAmount, address outputToken) external returns (Order memory) {
        orderCounter++;
        Order memory newOrder = Order({
            id: orderCounter,
            trader: msg.sender,
            orderType: OrderType.Buy,
            inputToken: inputToken,
            inputAmount: inputAmount,
            outputToken: outputToken,
            outputAmount: 0, // Not needed for market orders
            isFulfilled: false,
            isCanceled: false
        });

        uint remainingInputAmount = inputAmount;
        uint totalOutputMatched = 0;

        // First, try matching with sell orders
        Order[] storage sells = sellOrders[inputToken][outputToken];
        for (uint j = 0; j < sells.length; j++) {
            Order storage sellOrder = sells[j];
            if (sellOrder.isFulfilled || sellOrder.isCanceled) continue;

            uint inputAmountNeeded = min(remainingInputAmount, sellOrder.inputAmount);
            uint amountToMatch = (inputAmountNeeded * sellOrder.outputAmount) / sellOrder.inputAmount;

            uint sellOrderInputAmount = sellOrder.inputAmount;
            uint sellOrderOutputAmount = sellOrder.outputAmount;

            if (inputAmountNeeded <= remainingInputAmount) {
                // Perform the token transfers
                IERC20(outputToken).transferFrom(newOrder.trader, sellOrder.trader, amountToMatch);
                IERC20(inputToken).transferFrom(sellOrder.trader, newOrder.trader, inputAmountNeeded);

                remainingInputAmount -= inputAmountNeeded;
                totalOutputMatched += amountToMatch;
                sellOrderOutputAmount -= amountToMatch;
                sellOrderInputAmount -= inputAmountNeeded;

                if (sellOrderOutputAmount == 0) {
                    sellOrder.isFulfilled = true;
                } else {
                    sellOrder.inputAmount = sellOrderInputAmount;
                    sellOrder.outputAmount = sellOrderOutputAmount;
                    orderCounter++;
                    Order memory newOrder3 = Order({
                        id: orderCounter,
                        trader: sellOrder.trader,
                        orderType: OrderType.Sell,
                        inputToken: sellOrder.inputToken,
                        inputAmount: inputAmountNeeded,
                        outputToken: sellOrder.outputToken,
                        outputAmount: amountToMatch,
                        isFulfilled: true,
                        isCanceled: false
                    });
                    sellOrders[sellOrder.inputToken][sellOrder.outputToken].push(newOrder3);
                }

                if (remainingInputAmount == 0) {
                    newOrder.outputAmount = amountToMatch;
                    newOrder.isFulfilled = true;
                    break;
                }
                
            }
        }

        // If still not fully matched, try matching with other buy orders
        if (remainingInputAmount > 0) {
            Order[] storage buys = buyOrders[outputToken][inputToken];
            for (uint j = 0; j < buys.length; j++) {
                Order storage buyOrder = buys[j];
                if (buyOrder.isFulfilled || buyOrder.isCanceled || buyOrder.trader == msg.sender) continue;

                uint inputAmountNeeded = min(remainingInputAmount, buyOrder.outputAmount);
                uint amountToMatch = (inputAmountNeeded * buyOrder.inputAmount) / buyOrder.outputAmount;

                uint buyOrderInputAmount = buyOrder.inputAmount;
                uint buyOrderOutputAmount = buyOrder.outputAmount;

                if (inputAmountNeeded <= remainingInputAmount) {
                    // Perform the token transfers
                    IERC20(outputToken).transferFrom(newOrder.trader, buyOrder.trader, amountToMatch);
                    IERC20(inputToken).transferFrom(buyOrder.trader, newOrder.trader, inputAmountNeeded);

                    remainingInputAmount -= inputAmountNeeded;
                    totalOutputMatched += amountToMatch;
                    buyOrderOutputAmount -= inputAmountNeeded;
                    buyOrderInputAmount -= amountToMatch;

                    if (buyOrderOutputAmount == 0) {
                        buyOrder.isFulfilled = true;
                    } else {
                        buyOrder.inputAmount = buyOrderInputAmount;
                        buyOrder.outputAmount = buyOrderOutputAmount;
                        orderCounter++;
                        Order memory newOrder2 = Order({
                            id: orderCounter,
                            trader: buyOrder.trader,
                            orderType: OrderType.Buy,
                            inputToken: buyOrder.inputToken,
                            inputAmount: amountToMatch,
                            outputToken: buyOrder.outputToken,
                            outputAmount: inputAmountNeeded,
                            isFulfilled: true,
                            isCanceled: false
                        });
                        buyOrders[buyOrder.inputToken][buyOrder.outputToken].push(newOrder2);
                    }

                    if (remainingInputAmount == 0) {
                        newOrder.outputAmount = inputAmountNeeded;
                        newOrder.isFulfilled = true;
                        break;
                    }
                }
            }
        }

        // If still not fully matched, add the new order to the buy orders list
        if (remainingInputAmount > 0) {
            newOrder.isCanceled = true;
            emit OrderCanceled(newOrder.id, msg.sender, OrderType.Buy);
        } else {
            newOrder.isFulfilled = true;
            buyOrders[inputToken][outputToken].push(newOrder);
            emit OrderCreated(
                newOrder.id,
                msg.sender,
                OrderType.Buy,
                inputToken,
                inputAmount,
                outputToken,
                totalOutputMatched
            );
        }
        
        return newOrder;
    }

    function createMarketSellOrder(address inputToken, uint inputAmount, address outputToken) external returns (Order memory) {
        orderCounter++;
        Order memory newOrder = Order({
            id: orderCounter,
            trader: msg.sender,
            orderType: OrderType.Sell,
            inputToken: inputToken,
            inputAmount: inputAmount,
            outputToken: outputToken,
            outputAmount: 0, // Not needed for market orders
            isFulfilled: false,
            isCanceled: false
        });

        uint remainingInputAmount = inputAmount;
        uint totalOutputMatched = 0;

        // First, try matching with buy orders
        Order[] storage buys = buyOrders[inputToken][outputToken];
        for (uint i = 0; i < buys.length; i++) {
            Order storage buyOrder = buys[i];
            if (buyOrder.isFulfilled || buyOrder.isCanceled) continue;

            uint amountToMatch = min(remainingInputAmount, buyOrder.inputAmount);
            uint outputAmountProvided = (amountToMatch * buyOrder.outputAmount) / buyOrder.inputAmount;

            uint buyOrderInputAmount = buyOrder.inputAmount;
            uint buyOrderOutputAmount = buyOrder.outputAmount;

            if (amountToMatch <= remainingInputAmount) {
                // Perform the token transfers
                IERC20(inputToken).transferFrom(msg.sender, buyOrder.trader, amountToMatch);
                IERC20(outputToken).transferFrom(buyOrder.trader, msg.sender, outputAmountProvided);

                remainingInputAmount -= amountToMatch;
                totalOutputMatched += outputAmountProvided;
                buyOrderInputAmount -= amountToMatch;
                buyOrderOutputAmount -= outputAmountProvided;

                if (buyOrderInputAmount == 0) {
                    buyOrder.isFulfilled = true;
                } else {
                    buyOrder.inputAmount = buyOrderInputAmount;
                    buyOrder.outputAmount = buyOrderOutputAmount;
                    orderCounter++;
                    Order memory newOrder2 = Order({
                        id: orderCounter,
                        trader: buyOrder.trader,
                        orderType: OrderType.Buy,
                        inputToken: buyOrder.inputToken,
                        inputAmount: amountToMatch,
                        outputToken: buyOrder.outputToken,
                        outputAmount: outputAmountProvided,
                        isFulfilled: true,
                        isCanceled: false
                    });
                    buyOrders[buyOrder.inputToken][buyOrder.outputToken].push(newOrder2);
                }

                if (remainingInputAmount == 0) {
                    newOrder.outputAmount = outputAmountProvided;
                    newOrder.isFulfilled = true;
                    break;
                }
            }
        }

        // If still not fully matched, try matching with other sell orders
        if (remainingInputAmount > 0) {
            Order[] storage sells = sellOrders[outputToken][inputToken];
            for (uint i = 0; i < sells.length; i++) {
                Order storage sellOrder = sells[i];
                if (sellOrder.isFulfilled || sellOrder.isCanceled || sellOrder.trader == msg.sender) continue;

                uint inputAmountNeeded = min(remainingInputAmount, sellOrder.outputAmount);
                uint amountToMatch = (inputAmountNeeded * sellOrder.inputAmount) / sellOrder.outputAmount;

                uint sellOrderInputAmount = sellOrder.inputAmount;
                uint sellOrderOutputAmount = sellOrder.outputAmount;

                if (inputAmountNeeded <= remainingInputAmount) {
                    // Perform the token transfers
                    IERC20(inputToken).transferFrom(msg.sender, sellOrder.trader, inputAmountNeeded);
                    IERC20(outputToken).transferFrom(sellOrder.trader, msg.sender, amountToMatch);

                    remainingInputAmount -= inputAmountNeeded;
                    totalOutputMatched += amountToMatch;
                    sellOrderOutputAmount -= inputAmountNeeded;
                    sellOrderInputAmount -= amountToMatch;

                    if (sellOrderOutputAmount== 0) {
                        sellOrder.isFulfilled = true;
                    } else {
                        sellOrder.inputAmount = sellOrderInputAmount;
                        sellOrder.outputAmount = sellOrderOutputAmount;
                        orderCounter++;
                        Order memory newOrder3 = Order({
                            id: orderCounter,
                            trader: sellOrder.trader,
                            orderType: OrderType.Sell,
                            inputToken: sellOrder.inputToken,
                            inputAmount: amountToMatch,
                            outputToken: sellOrder.outputToken,
                            outputAmount: inputAmountNeeded,
                            isFulfilled: true,
                            isCanceled: false
                        });
                        sellOrders[sellOrder.inputToken][sellOrder.outputToken].push(newOrder3);
                    }

                    if (remainingInputAmount == 0) {
                        newOrder.outputAmount = inputAmountNeeded;
                        newOrder.isFulfilled = true;
                        break;
                    }
                }
            }
        }

        // If the order could not be fully matched, cancel the order
        if (remainingInputAmount > 0) {
            newOrder.isCanceled = true;
            emit OrderCanceled(newOrder.id, msg.sender, OrderType.Sell);
        } else {
            newOrder.isFulfilled = true;
            sellOrders[inputToken][outputToken].push(newOrder);
            emit OrderCreated(
                newOrder.id,
                msg.sender,
                OrderType.Sell,
                inputToken,
                inputAmount,
                outputToken,
                totalOutputMatched
            );
        }
        
        return newOrder;
    }
}
