import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://github.com/kyrers/scaffold-eth-challenges/tree/challenge-2-token-vendor" target="_blank" rel="noopener noreferrer">
      <PageHeader title="Token Vendor" subTitle="By kyrers. Forked from 🏗 scaffold-eth" style={{ cursor: "pointer" }} />
    </a>
  );
}
