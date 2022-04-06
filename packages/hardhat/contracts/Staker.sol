// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ExampleExternalContract.sol";

/**
* @title Staker contract
* @author kyrers
* @notice Contract for ETH stacking. Mostly based on speedrunethereum challenge 1, but allows for the minimumStackedAmount to be updated under some conditions.
 */
contract Staker is Ownable {
  //An example external contract to hold the staked funds, built by scaffold-eth
  ExampleExternalContract public exampleExternalContract;

  //User's staked funds
  mapping (address => uint256) public balances;

  //Minimum stacked amount needed
  uint256 public minimumStackedAmount;

  //Maximum amount of time for the stacked amount to be reached
  uint256 public deadline;

  //Events
  event Stake(address staker, uint256 amount);
  //------
  
  //Modifiers
  /**
  * @notice Modifier that requires the new stacked amount to be between 1 and 32 ETH 
  * @param value The new amount
  */
  modifier isValidAmount(uint256 value) {
    require(0 < value && value < 33, "Invalid minimum stacked amount.");
    _;
  }

  /**
  * @notice Modifier that requires the external contract not to be completed
  */
  modifier isNotCompleted() {
    require(!exampleExternalContract.completed(), "Staking process already completed.");
    _;
  }

  /**
  * @notice Modifier that requires the deadline to be reached or not
  * @param requireReached Check if the deadline was reached or not
  */
  modifier deadlineReached(bool requireReached) {
    if(requireReached) {
      require(timeLeft() == 0, "Deadline not reached yet.");
    } else {
      require(timeLeft() > 0, "Deadline already reached.");
    }
    _;
  }
  //------

   /**
  * @notice Contract Constructor
  * @param _exampleExternalContractAddress Address of the external contract that will hold stacked funds
  * @param _minimumStackedAmount The minimum amount of stacked ETH required for the contract to move the funds
  */
  constructor(address _exampleExternalContractAddress, uint256 _minimumStackedAmount) isValidAmount(_minimumStackedAmount) {
    exampleExternalContract = ExampleExternalContract(_exampleExternalContractAddress);
    minimumStackedAmount = _minimumStackedAmount * 1 ether;
    deadline = block.timestamp + 3 minutes;
  }


  /**
  * @notice Allow users to withdraw their balance from the contract if deadline is reached but the stake is not completed
  */
  function execute() public deadlineReached(false) isNotCompleted {
    uint256 contractBalance = address(this).balance;

    // check the contract has enough ETH to reach the treshold
    require(contractBalance >= minimumStackedAmount, "Minimum amount not reached");

    // Execute the external contract, transfer all the balance to the contract
    (bool sent,) = address(exampleExternalContract).call{value: contractBalance}(abi.encodeWithSignature("complete()"));
    require(sent, "Could not successfully call complete on the external contract");
  }

  /**
  * @notice Allows users to stake ETH
  */
  function stake() public payable deadlineReached(false) isNotCompleted {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  /**
  * @notice Allow the owner of this contract to update the _minimumStackedAmount
  * @param _minimumStackedAmount The new minimum stacked amount
  */
  function updateMinimumStackedAmount(uint256 _minimumStackedAmount) external onlyOwner isValidAmount(_minimumStackedAmount) {
    minimumStackedAmount = _minimumStackedAmount * 1 ether;
  }

  /**
  * @notice Allow users to withdraw their balance from the contract if deadline is reached but the stake is not completed
  */
  function withdraw() public deadlineReached(true) isNotCompleted {
    uint256 userBalance = balances[msg.sender];

    // check if the user has balance to withdraw
    require(userBalance > 0, "You don't have balance to withdraw");

    // reset the balance of the user
    balances[msg.sender] = 0;

    // Transfer balance back to the user
    (bool sent, ) = msg.sender.call{value: userBalance}("");
    require(sent, "Failed to send user balance back to the user");
  }

  /**
  * @notice Time remaining for the deadline to be reached
  */
  function timeLeft() public view returns (uint256) {
    if(block.timestamp < deadline) {
      return deadline - block.timestamp;
    }

    return 0;
  }

  /**
  * @notice Allows the owner to restart the deadline if the current one was reached
  */
  function restartClock() external onlyOwner deadlineReached(true) {
    deadline = block.timestamp + 1 minutes;
  }
}
