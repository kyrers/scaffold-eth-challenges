// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
* @title Balloons Token contract
* @author kyrers
* @notice Balloons ERC20 Token contract. Built following the speedrunethereum challenge 5 guide.
*/
contract Balloons is ERC20 {

    /**
    * @notice Contract constructor. Mint 1000 Balloons to contract creator.
    */  constructor() ERC20("Balloons", "BAL") {
      _mint(msg.sender, 1000 ether);
  }
}
