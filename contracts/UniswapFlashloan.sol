//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

// 1000000000000000000000,
// ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2","0xdAC17F958D2ee523a2206206994597C13D831ec7"]
// 0x71a94aFe6b8C18Cbb97Bc4072aBCBd3b908046e6
// 111111111111

contract FlashLoan is IUniswapV2Callee {
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    event Log(address, uint);

    function testFlashSwap(address _tokenBorrow, uint _amount) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenBorrow, WETH);
        require(pair != address(0), "not found pair");
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0 = _tokenBorrow == token0 ? _amount : 0;
        uint amount1 = _tokenBorrow == token1 ? _amount : 0;

        bytes memory data = abi.encode(_tokenBorrow, _amount);
        // if data is not empty, will trigger flash loan
        IUniswapV2Pair(pair).swap(amount0, amount1, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        address token0 = IUniswapV2Pair(sender).token0();
        address token1 = IUniswapV2Pair(sender).token1();
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(msg.sender == pair, "!pair");
        require(sender == address(this), "!sender");
        (address tokenBorrow, uint amount) = abi.decode(data, (address, uint));
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;

        emit Log(token0, amount0);
        emit Log(token1, amount1);
        IERC20(tokenBorrow).transfer(pair, amountToRepay);
    }
}
