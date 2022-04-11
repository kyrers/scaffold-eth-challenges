pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

/**
* @title Vendor contract
* @author kyrers
* @notice Contract to allow users to buy and sell tokens. Built following the speedrunethereum challenge 2 guide.
*/
contract Vendor is Ownable {
  //Amount of tokens per 1 ETH
  uint256 public constant tokensPerEth = 100;

  //The token contract
  YourToken public yourToken;

  //Events
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);
  //-----

  /**
  * @dev Contract constructor
  * @param _tokenAddress The token contract address
  */
  constructor(address _tokenAddress) {
    yourToken = YourToken(_tokenAddress);
  }

  /**
  * @notice Allow users to buy tokens
  * @return Amount of tokens bought
  */
  function buyTokens() public payable returns (uint256) {
    require(msg.value > 0, "No ETH sent.");

    uint256 amountToBuy = msg.value * tokensPerEth;

    //Check if the vendor has enough tokens
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract does not have enough tokens.");

    //Transfer tokens to the msg.sender
    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer tokens.");

    //Emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  /**
  * @notice Allow users to sell tokens
  * @param _amount The amount of tokens to sell
  */
  function sellTokens(uint256 _amount) public {
    //Check that the user is selling an amount of tokens greater than 0
    require(_amount > 0, "Can't sell 0 tokens.");

    //Check that the user has enough tokens
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= _amount, "You don't have enough tokens.");

    //Check that the vendor has enough ETH to buy the tokens
    uint256 amountOfETH = _amount / tokensPerEth;
    uint256 vendorETHBalance = address(this).balance;
    require(vendorETHBalance >= amountOfETH, "Vendor does not have enough ETH to buy your tokens.");

    //Transfer the tokens from the user to the vendor
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(sent, "Failed to transfer tokens to vendor.");

    //Send ETH from the vendor to the user
    (sent,) = msg.sender.call{value: amountOfETH}("");
    require(sent, "Failed to send ETH to the user.");

    //Emit the event
    emit SellTokens(msg.sender, _amount, amountOfETH);
  }

  /**
  * @notice Allow the owner of the contract to withdraw ETH
  */
  function withdraw() public onlyOwner {
    //Verify that there is some ETH to withdraw
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "No balance withdraw.");

    //Withdraw the whole balance
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send balance to the owner.");
  }
}
