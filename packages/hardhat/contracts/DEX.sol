// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title DEX contract
* @author kyrers
* @notice Decentralized exchange contract. Built following the speedrunethereum challenge 5 guide.
*/
contract DEX {
  //##### VARIABLES #####
  //Balloon ERC20 token interface
  IERC20 balloon;

  //Total DEX liquidity
  uint256 public totalLiquidity;

  //Liquidity by address
  mapping (address => uint256) public liquidity;

  //##### FUNCTIONS #####
  /**
  * @notice Contract constructor. Initialize the IERC20 interface using the Balloon token contract address
  */
  constructor(address _balloonTokenContract) {
    balloon = IERC20(_balloonTokenContract);
  }

  /**
  * @notice Initialize the DEX by providing liquidity.
  * @param _balloons Number of balloons to transfer to the DEX
  * @return Total DEX liquidity
  */
  function initialize(uint256 _balloons) public payable returns (uint256) {
    require(totalLiquidity == 0,"DEX already initialized");

    totalLiquidity = address(this).balance;
    liquidity[msg.sender] = totalLiquidity;

    bool success = balloon.transferFrom(msg.sender, address(this), _balloons);
    require(success, "Failed to transfer the balloons to the DEX");

    return totalLiquidity;
  }

  /**
  * @notice Calculates the price for a given swap.
  * @param _inputAmount Number of ETH or BAL the DEX will receive
  * @param _inputReserve Number of ETH or BAL the DEX has. Same type as input.
  * @param _outputReserve Number of ETH or BAL the DEX already. Different type from input.
  * @return The number of ETH or BAL to receive
  */
  function price(uint256 _inputAmount, uint256 _inputReserve, uint256 _outputReserve) public pure returns (uint256) {
    uint256 inputAmountWithFee = _inputAmount * 997;
    uint256 numerator = inputAmountWithFee * _outputReserve;
    uint256 denominator = _inputReserve * 1000 + inputAmountWithFee;
    return (numerator / denominator);
  }

}