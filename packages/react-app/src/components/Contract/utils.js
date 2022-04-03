import React from "react";
import { Address } from "..";
import ReactJson from "react-json-view";

const { utils } = require("ethers");

const tryToDisplay = thing => {
  if (thing && thing.toNumber) {
    try {
      return thing.toNumber();
    } catch (e) {
      return "Ξ" + utils.formatUnits(thing, "ether");
    }
  
  }
  if (thing && thing.indexOf && thing.indexOf("0x") === 0 && thing.length === 42) {
    return (
      <Address address={thing} size="long" fontSize={22} />
    );
  }

  return (
    <ReactJson
      style={{ padding: 8 }}
      src={thing}
      theme="pop"
      enableClipboard={false} />
  );
};

export default tryToDisplay;
