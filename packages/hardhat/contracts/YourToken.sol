// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
* @title Token contract
* @author kyrers
* @notice ERC20 Token contract. Built following the speedrunethereum challenge 2 guide.
*/
contract YourToken is ERC20 {

    /**
    * @notice Contract constructor
    * @dev Mint 1000 KRS tokens by default
    */
    constructor() ERC20("kyrers", "KRS") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}
