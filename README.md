# Decentralized Staking App Solution

## App UI: [App](https://dependent-quicksand.surge.sh/)
## Staker contract: [Staker contract](https://rinkeby.etherscan.io/address/0x9A5eeA91dE9F5fC4B844802DC279aAaBac1FA70D)
## Example External contract: [Example External contract](https://rinkeby.etherscan.io/address/0xE475BD5056b0AD6F0D49c0dd192949B66E7f2874)

Please note that I took the liberty to make a few modifications to the Staker contract, even though they weren't explicit in the challenge. Namely:
- Allowed the owner of the contract, which is receives the contract ownership on deploy, to update the minimum stacked ETH amount and to restart the clock if the deadline has been reached;
- Added events for withdraw and restart clock calls;