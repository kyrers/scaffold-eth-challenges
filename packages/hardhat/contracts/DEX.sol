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


  //##### EVENTS #####
  event ETHSwap(address user, uint256 ethAmount, uint256 balAmount);
  event BALSwap(address user, uint256 balAmount, uint256 ethAmount);
  event AddLiquidity(address user, uint256 ethAmount, uint256 balAmount);
  event WithdrawLiquidity(address user, uint256 ethAmount, uint256 balAmount);

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

  /**
  * @notice Swap ETH for BAL.
  * @return The number of BAL to receive
  */
  function ethToToken() external payable returns (uint256) {
    require(msg.value > 0, "No ETH sent!");

    uint256 tokenReserve = balloon.balanceOf(address(this));
    uint256 ethReserve = address(this).balance - msg.value;
    uint256 balReturn = price(msg.value, ethReserve, tokenReserve);

    bool success = balloon.transfer(msg.sender, balReturn);
    require(success, "Failed to send tokens to user.");

    emit ETHSwap(msg.sender, msg.value, balReturn);
    return balReturn;
  }

  /**
  * @notice Swap ETH for BAL.
  * @param _tokenAmount Amount of BAL to receive
  * @return The number of BAL to receive
  */
  function tokenToEth(uint256 _tokenAmount) external payable returns (uint256) {
    require(_tokenAmount > 0, "No tokens sent!");

    uint256 tokenReserve = balloon.balanceOf(address(this));
    uint256 ethReserve = address(this).balance - msg.value;
    uint256 ethReturn = price(_tokenAmount, tokenReserve, ethReserve);

    bool received = balloon.transferFrom(msg.sender, address(this), _tokenAmount);
    require(received, "Failed to send tokens to the DEX.");

    (bool sent, ) = msg.sender.call{ value: ethReturn }("");
    require(sent, "Failed to send ETH to user.");

    emit BALSwap(msg.sender, _tokenAmount, ethReturn);
    return ethReturn;
  }

  /**
  * @notice Provide liquidity.
  * @return The number of BAL provided as liquidity
  */
  function deposit() public payable returns (uint256) {
      uint256 ethReserve = address(this).balance - msg.value;
      uint256 tokenReserve = balloon.balanceOf(address(this));
      uint256 tokenDeposit = ((msg.value * tokenReserve) / ethReserve) + 1;

      uint256 liquidityMinted = (msg.value * totalLiquidity) / ethReserve;
      liquidity[msg.sender] += liquidityMinted;
      totalLiquidity += liquidityMinted;

      bool success = balloon.transferFrom(msg.sender, address(this), tokenDeposit);
      require(success, "Could not transfer BAL to the DEX.");

      emit AddLiquidity(msg.sender, liquidityMinted, tokenDeposit);
      return tokenDeposit;
  }

  /**
  * @notice Withdraw liquidity.
  * @param _amount Amount of ETH to withdraw
  * @return ethAmount - Amount of ETH withdrawn
  * @return balAmount - Amount of BAL withdrawn
  */
  function withdraw(uint256 _amount) public returns (uint256 ethAmount, uint256 balAmount) {
    require(liquidity[msg.sender] >= _amount, "Trying to withdraw too much.");
    uint256 ethReserve = address(this).balance;
    uint256 tokenReserve = balloon.balanceOf(address(this));
    uint256 ethWithdrawn = (_amount * ethReserve) / totalLiquidity;

    uint256 tokenAmount = (_amount * tokenReserve) / totalLiquidity;
    liquidity[msg.sender] -= _amount;
    totalLiquidity -= _amount;

    (bool sentEth, ) = payable(msg.sender).call{ value: ethWithdrawn }("");
    require(sentEth, "Could not transfer ETH back to you.");
    
    bool sentBal = balloon.transfer(msg.sender, tokenAmount);
    require(sentBal, "Could not transfer BAL back to you.");

    emit WithdrawLiquidity(msg.sender, ethWithdrawn, tokenAmount);  
    return (ethWithdrawn, tokenAmount);
  }

}