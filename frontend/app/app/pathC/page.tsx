// frontend/pages/pathC.js
import React from "react";
import Link from "next/link";

export default function PathC() {
  return (
    <div style={{ padding: "20px", fontFamily: "sans-serif" }}>
      <h2>Path C: Fight the Conspiracy</h2>
      <p>Dive deep into a world of secrets and power struggles as you battle to free artistic expression.</p>
      {/* Integrate interactive puzzles or narrative decisions here */}
      <Link href="/mint">
        <a>Mint NFT for Your Victory</a>
      </Link>
      <br />
      <Link href="/">
        <a>Back Home</a>
      </Link>
    </div>
  );
}