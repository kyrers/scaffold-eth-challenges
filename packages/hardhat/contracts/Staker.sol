// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ExampleExternalContract.sol";

/**
* @title Staker contract
* @author kyrers
* @notice Contract for ETH staking. Mostly based on speedrunethereum challenge 1, but allows for the minimumStakedAmount to be updated under some conditions.
 */
contract Staker is Ownable {
  //An example external contract to hold the staked funds, built by scaffold-eth
  ExampleExternalContract public exampleExternalContract;

  //User's staked funds
  mapping (address => uint256) public balances;

  //Minimum staked amount needed
  uint256 public minimumStakedAmount;

  //Events
  event Stake(address staker, uint256 amount);
  //------
  
  //Modifiers
  modifier isValidAmount(uint256 value) {
    require(value < 33, "Invalid minimum staked amount.");
    _;
  }
  //------

   /**
  * @notice Contract Constructor
  * @param _exampleExternalContractAddress Address of the external contract that will hold stacked funds
  * @param _minimumStakedAmount The minimum amount of staked ETH required for the contract to move the funds
  */
  constructor(address _exampleExternalContractAddress, uint256 _minimumStakedAmount) isValidAmount(_minimumStakedAmount) {
    exampleExternalContract = ExampleExternalContract(_exampleExternalContractAddress);
    minimumStakedAmount = _minimumStakedAmount;
  }

  /**
  * @notice Function that allows users to stake ETH
  */
  function stake() public payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  /**
  * @notice Function to allow the owner of this contract to update the _minimumStakedAmount
  * @param _minimumStakedAmount The new minimum staked amount
  */
  function updateMinimumStakedAmount(uint256 _minimumStakedAmount) external onlyOwner isValidAmount(_minimumStakedAmount) {
    minimumStakedAmount = _minimumStakedAmount;
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw(address payable)` function lets users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}
