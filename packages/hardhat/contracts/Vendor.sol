pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "No ETH sent.");

    uint256 amountToBuy = msg.value * tokensPerEth;

    // check if Vendor Contract has enough tokens
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract does not have enough tokens.");

    // Transfer token to the msg.sender
    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer tokens.");

    // emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

   /**
  * @notice Allow the owner of the contract to withdraw ETH
  */
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "No balance withdraw.");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send balance to the owner.");
  }

  // ToDo: create a sellTokens() function:

}
