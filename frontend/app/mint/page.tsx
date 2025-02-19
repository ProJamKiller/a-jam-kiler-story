// frontend/pages/mint.js
import React from "react";
import MintNFT from "../components/MintNFT";
import Link from "next/link";

export default function MintPage() {
  return (
    <div style={{ padding: "20px", fontFamily: "sans-serif" }}>
      <h2>Mint Your Jam Killer NFT</h2>
      <MintNFT />
      <br />
      <Link href="/">
        <a>Back Home</a>
      </Link>
    </div>
  );
}