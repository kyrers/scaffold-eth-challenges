import { Card, Col, Divider, Input, Row, List } from "antd";
import { useBalance, useContractReader } from "eth-hooks";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { useTokenBalance } from "eth-hooks/erc/erc-20/useTokenBalance";
import { ethers } from "ethers";
import React, { useState } from "react";
import Address from "./Address";
import Balance from "./Balance";
import Contract from "./Contract";
import Curve from "./Curve.jsx";
import TokenBalance from "./TokenBalance";
import '../App.css';

const contractName = "DEX";
const tokenName = "Balloons";

export default function Dex(props) {
  let display = [];

  const [form, setForm] = useState({});
  const [values, setValues] = useState({});
  const tx = props.tx;

  const writeContracts = props.writeContracts;

  const contractAddress = props.readContracts[contractName].address;
  const tokenAddress = props.readContracts[tokenName].address;
  const contractBalance = useBalance(props.localProvider, contractAddress);

  const tokenBalance = useTokenBalance(props.readContracts[tokenName], contractAddress, props.localProvider);
  const tokenBalanceFloat = parseFloat(ethers.utils.formatEther(tokenBalance));
  const ethBalanceFloat = parseFloat(ethers.utils.formatEther(contractBalance));
  const liquidity = useContractReader(props.readContracts, contractName, "liquidity", [props.address]);
  const ETHSwapEvents = useEventListener(props.readContracts, contractName, "ETHSwap", props.localProvider, 1);
  const BALSwapEvents = useEventListener(props.readContracts, contractName, "BALSwap", props.localProvider, 1);
  const AddLiquidityEvents = useEventListener(props.readContracts, contractName, "AddLiquidity", props.localProvider, 1);
  const WithdrawLiquidityEvents = useEventListener(props.readContracts, contractName, "WithdrawLiquidity", props.localProvider, 1);

  const rowForm = (title, icon, onClick) => {
    return (
      <Row>
        <Col span={8} style={{ textAlign: "right", opacity: 0.333, paddingRight: 6, fontSize: 24 }}>
          {title}
        </Col>
        <Col span={16}>
          <div style={{ cursor: "pointer", margin: 2 }}>
            <Input
              onChange={e => {
                let newValues = { ...values };
                newValues[title] = e.target.value;
                setValues(newValues);
              }}
              value={values[title]}
              addonAfter={
                <div
                  type="default"
                  onClick={() => {
                    onClick(values[title]);
                    let newValues = { ...values };
                    newValues[title] = "";
                    setValues(newValues);
                  }}
                >
                  {icon}
                </div>
              }
            />
          </div>
        </Col>
      </Row>
    );
  };

  if (props.readContracts && props.readContracts[contractName]) {
    display.push(
      <div>
        {rowForm("ethToToken", "💸", async value => {
          let valueInEther = ethers.utils.parseEther("" + value);
          let swapEthToTokenResult = await tx(writeContracts[contractName]["ethToToken"]({ value: valueInEther }));
          console.log("swapEthToTokenResult:", swapEthToTokenResult);
        })}

        {rowForm("tokenToEth", "🔏", async value => {
          let valueInEther = ethers.utils.parseEther("" + value);
          console.log("valueInEther", valueInEther);
          let allowance = await props.readContracts[tokenName].allowance(
            props.address,
            props.readContracts[contractName].address,
          );
          console.log("allowance", allowance);

          let approveTx;
          if (allowance.lt(valueInEther)) {
            approveTx = await tx(
              writeContracts[tokenName].approve(props.readContracts[contractName].address, valueInEther, {
                gasLimit: 200000,
              }),
            );
          }

          let swapTx = tx(writeContracts[contractName]["tokenToEth"](valueInEther, { gasLimit: 200000 }));
          if (approveTx) {
            console.log("waiting on approve to finish...");
            let approveTxResult = await approveTx;
            console.log("approveTxResult:", approveTxResult);
          }
          let swapTxResult = await swapTx;
          console.log("swapTxResult:", swapTxResult);
        })}

        <Divider> Liquidity ({liquidity ? ethers.utils.formatEther(liquidity) : "none"}):</Divider>

        {rowForm("deposit", "📥", async value => {
          let valueInEther = ethers.utils.parseEther("" + value);

          let expectedTokenAmount = valueInEther.mul(tokenBalance).div(contractBalance).add(1);
          console.log("expectedTokenAmount", expectedTokenAmount);
          let allowance = await props.readContracts[tokenName].allowance(
            props.address,
            props.readContracts[contractName].address,
          );
          console.log("allowance", allowance);
          if (allowance.lt(expectedTokenAmount)) {
            await tx(
              writeContracts[tokenName].approve(props.readContracts[contractName].address, expectedTokenAmount, {
                gasLimit: 200000,
              }),
            );
          }
          await tx(writeContracts[contractName]["deposit"]({ value: valueInEther, gasLimit: 200000 }));
        })}

        {rowForm("withdraw", "📤", async value => {
          let valueInEther = ethers.utils.parseEther("" + value);
          let withdrawTxResult = await tx(writeContracts[contractName]["withdraw"](valueInEther));
          console.log("withdrawTxResult:", withdrawTxResult);
        })}
      </div>,
    );
  }

  return (
    <div className="main-panel">
      <div className="contracts-panel">
        <div className="dex-panel">
          <Card
            title={
              <div>
                <Address value={contractAddress} />
                <div style={{ float: "right", fontSize: 24 }}>
                  {parseFloat(ethers.utils.formatEther(contractBalance)).toFixed(4)} ⚖️
                  <TokenBalance name={tokenName} img={"🎈"} address={contractAddress} contracts={props.readContracts} />
                </div>
              </div>
            }
            size="large"
            loading={false}
          >
            {display}
          </Card>
        </div>
        <div className="bal-panel">
          <Contract
            name="Balloons"
            signer={props.signer}
            provider={props.localProvider}
            show={["balanceOf", "approve"]}
            address={props.address}
            blockExplorer={props.blockExplorer}
            contractConfig={props.contractConfig}
          />
        </div>
      </div>
      <div className="info-panel">
        <div style={{ padding: 20 }}>
          <Curve
            addingEth={values && values["ethToToken"] ? values["ethToToken"] : 0}
            addingToken={values && values["tokenToEth"] ? values["tokenToEth"] : 0}
            ethReserve={ethBalanceFloat}
            tokenReserve={tokenBalanceFloat}
            width={600}
            height={400}
          />
        </div>
        <div className="events-panel">
          <div className="order-book-panel">
            <h3><b>Order Book</b></h3>
            <List
              className="order-book-list"
              dataSource={ETHSwapEvents.concat(BALSwapEvents).sort((a, b) => a.blockNumber - b.blockNumber)}
              renderItem={item => {
                if (item.event === "ETHSwap") {
                  return (
                    <List.Item key={item.blockNumber + item.blockHash} className="buy-token-event">
                      <Address value={item.args[0]} ensProvider={props.localProvider} fontSize={12} /> swapped
                      <Balance balance={item.args[1]} />
                      ETH for
                      <Balance balance={item.args[2]} />
                      BAL
                    </List.Item>
                  );
                } else {
                  return (
                    <List.Item key={item.blockNumber + item.blockHash} className="sell-token-event">
                      <Address value={item.args[0]} ensProvider={props.localProvider} fontSize={12} /> swapped
                      <Balance balance={item.args[1]} />
                      BAL for
                      <Balance balance={item.args[2]} />
                      ETH
                    </List.Item>
                  );
                }
              }}
            />
          </div>

          <div className="liquidity-panel">
            <h3><b>Liquidity</b></h3>
            <List
              className="order-book-list"
              dataSource={AddLiquidityEvents.concat(WithdrawLiquidityEvents).sort((a, b) => a.blockNumber - b.blockNumber)}
              renderItem={item => {
                if (item.event === "AddLiquidity") {
                  return (
                    <List.Item key={item.blockNumber + item.blockHash} className="buy-token-event">
                      <Address value={item.args[0]} ensProvider={props.localProvider} fontSize={12} /> Added
                      <Balance balance={item.args[1]} />
                      ETH and
                      <Balance balance={item.args[2]} />
                      BAL to the pool
                    </List.Item>
                  );
                } else {
                  return (
                    <List.Item key={item.blockNumber + item.blockHash} className="sell-token-event">
                      <Address value={item.args[0]} ensProvider={props.localProvider} fontSize={12} /> Withdrew
                      <Balance balance={item.args[1]} />
                      ETH and
                      <Balance balance={item.args[2]} />
                      BAL from the pool
                    </List.Item>
                  );
                }
              }}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
