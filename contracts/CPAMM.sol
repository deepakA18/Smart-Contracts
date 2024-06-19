// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20} from "./IERC20.sol";

contract CPAMM{

    error CPAMM__InvalidToken();
    error CPAMM__AmountCannotBeZero();
    error CPAMM__EquationFails();
    error CPAMM__SharesCannotBeZero();

    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(address _tokenA, address _tokenB){
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function _update(uint256 _reserveA, uint256 _reserveB) private{
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function swap(address _tokenIn, uint256 _amountIn) external returns(uint256 amountOut) {
        if(_tokenIn != address(tokenA) || _tokenIn != address(tokenB))
        {
            revert CPAMM__InvalidToken();
        }
        if(_amountIn < 0)
        {
            revert CPAMM__AmountCannotBeZero();
        }
        //pull in token In:
        bool istokenA = _tokenIn == address(tokenA);
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = istokenA ? (tokenA,tokenB,reserveA,reserveB) : (tokenB, tokenA,reserveB,reserveA);

        tokenIn.transferFrom(msg.sender,address(this),_amountIn); 
        //Calculate the token In with fees (0.3%):
        //ydx / (x+dx) = dy
        uint256 amountInWithFees = (_amountIn * 997) / 1000;
        amountOut = (reserveOut * amountInWithFees) / (amountInWithFees + reserveIn);

        //Transfer token out to msg.sender:
        tokenOut.transfer(msg.sender,amountOut);

        //update reserves:
        _update(tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this)));
    }

    function addLiquidity(uint256 _amountA, uint256 _amountB) external returns(uint256 shares){
        //pull in:
        tokenA.transferFrom(msg.sender,address(this), _amountA);
        tokenB.transferFrom(msg.sender,address(this),_amountB);

        //dy/dx = y/x == x*dy = y*dx:
        if(reserveA > 0 || reserveB >0)
        {
            if(reserveA * _amountB != reserveB * _amountA)
            {
                revert CPAMM__EquationFails();
            }
        }

        //Mint Shares:
        //f(x,y) = value of liquidity = sqrt(xy)
        //s = dx/x * T == dy/y*T
        if(totalSupply == 0)
        {
            shares = _sqrt(_amountA * _amountB);
        }
        else{
            shares = _min((_amountA * totalSupply) / reserveA,
            (_amountB * totalSupply) / reserveB);
        }

        if(shares == 0)
        {
            revert CPAMM__SharesCannotBeZero();
        }

        _mint(msg.sender,shares);

         //update reserves:
        _update(tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this)));

    }

    function removeLiquidity(uint256 _shares) external returns(uint256 amountA, uint256 amountB){
        uint256 balA = tokenA.balanceOf(address(this));
        uint256 balB = tokenB.balanceOf(address(this));

        amountA = (_shares * balA) / totalSupply;
        amountB = (_shares * balB) / totalSupply ;

        if(amountA < 0 && amountB < 0)
        {
            revert CPAMM__AmountCannotBeZero();
        }

        //burn shares:
        _burn(msg.sender,_shares);

        //update reserves:
        _update(balA - amountA, balB - amountB);

        //transfer to msg.sender:
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender,amountB);
    }


     function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if(y > 3){
            z=y;
            uint256 x = y/2 + 1;
            while(x<z){
                z= x;
                y= y/(x+x) /2;

            }
        }
        else if(y != 0){
            z= 1;
        }

    }

    function _min(uint256 x,uint256 y) private pure returns(uint256){
        return x<=y ? x:y;
    }
}

