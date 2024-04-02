// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address[] private s_funders;
    uint256 private s_totalFunded;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;  // in wei
    AggregatorV3Interface private s_priceFeed;  //s_ is storage variable
    
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConvertedAmount(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
        s_totalFunded += msg.value;
    }

    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner(); }
        _;
    }

    function withdraw() public onlyOwner {
        // for loop: for(starting index, ending index, step amount)
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
      
        // three ways to withdraw funds:
        // transfer - 2300 gas, returns error when fails
            // payable(msg.sender).transfer(address(this).balance); // payable(msg.sender) = payable address

        // send - 2300 gas, return bool when fails
            // bool sendSuccess payable(msg.sender).send(address(this).balance);
            // require(sendSuccess, "Send Failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getTotalFunded() external view returns (uint256) {
        return s_totalFunded;
    }

    function getAddressToAmountFunded(address funderAddress) external view returns (uint256) {
        return s_addressToAmountFunded[funderAddress];
    }

    function getFunder(uint256 index) external view returns(address){
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }

    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }
}