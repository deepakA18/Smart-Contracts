//SPDX-License-Identifier:MIT


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306    Chainlink Price feed of ETH/USD

pragma solidity ^0.8.24;

contract FundMe{

    uint256 minimumUSD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountInUSD) public addressToAmountinUSD;

    function fund() public payable {
        require( getConversionRate(msg.value) >= minimumUSD , "Not enough funds!");
        funders.push(msg.sender);
        addressToAmountinUSD[msg.sender] = addressToAmountinUSD[msg.sender] + msg.value;
    }

    function getFund() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 price, , ,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getFund();
        uint256 ethAmountinUSD = (ethAmount * ethPrice) / 1e18;
        return ethAmountinUSD;
    }

    function getVersion() public view returns(uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}