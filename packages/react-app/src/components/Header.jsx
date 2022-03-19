import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://github.com/kyrers/scaffold-eth-challenges/tree/challenge-0-simple-nft" target="_blank" rel="noopener noreferrer">
      <PageHeader title="🖼 NFT example" subTitle="By kyrers. Forked from 🏗 scaffold-eth" style={{ cursor: "pointer" }} />
    </a>
  );
}
