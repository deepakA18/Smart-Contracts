//SPDX-License-Identifier:MIT

import {PriceConverter} from "./PriceConverter.sol";

//Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306    Chainlink Price feed of ETH/USD

pragma solidity ^0.8.24;

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant minimumUSD = 5e18;

    address public immutable owner;

    address[] public funders;
    mapping(address funder => uint256 amountInUSD) public addressToAmountinUSD;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require( msg.value.getConversionRate() >= minimumUSD , "Not enough funds!");
        funders.push(msg.sender);
        addressToAmountinUSD[msg.sender] = addressToAmountinUSD[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner{
        
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++)
        {
            address funder = funders[funderIndex];
            addressToAmountinUSD[funder] = 0;
        }
        funders = new address[](0);

        //transfer
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send failed!");

        //call
        (bool send, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(send, "Call Failed!");
    }

    modifier onlyOwner(){
        // require(msg.sender == owner, "Must be owner!");
        if(msg.sender != owner)
        {
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable{
        fund();
    }
}