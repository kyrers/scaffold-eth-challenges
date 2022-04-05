import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://github.com/kyrers/scaffold-eth-challenges/tree/challenge-1-decentralized-staking" target="_blank" rel="noopener noreferrer">
    <PageHeader title="Decentralized Staking App" subTitle="By kyrers. Forked from 🏗 scaffold-eth" style={{ cursor: "pointer" }} />
  </a>
  );
}
