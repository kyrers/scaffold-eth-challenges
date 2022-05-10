// deploy/00_deploy_balloons_dex.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("Balloons", {
    from: deployer,
    log: true,
  });

  const balloons = await ethers.getContract("Balloons", deployer);

  await deploy("DEX", {
    from: deployer,
    args: [balloons.address],
    log: true,
  });

  const dex = await ethers.getContract("DEX", deployer);

  console.log("Approving DEX (" + dex.address + ") to take Balloons from main account...");
  await balloons.approve(dex.address, ethers.utils.parseEther('10'));
  console.log("Initializing exchange with 10 Ballons and 10 ETH...");
  await dex.initialize(ethers.utils.parseEther("10"), { value: ethers.utils.parseEther('10'), gasLimit: 200000 })
};
module.exports.tags = ["Balloons", "DEX"];
