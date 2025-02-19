// frontend/pages/index.js
import React from "react";
import Link from "next/link";
import FarcasterAuth from "../components/FarcasterAuth";

export default function Home() {
  return (
    <div style={{ padding: "20px", fontFamily: "sans-serif" }}>
      <h1>Don't Kill the Jam: A Jam Killer Story</h1>
      <FarcasterAuth />
      <p>Select your path:</p>
      <ul>
        <li>
          <Link href="/pathA">
            <a>Path A: Build a Band</a>
          </Link>
        </li>
        <li>
          <Link href="/pathB">
            <a>Path B: Solo Composition</a>
          </Link>
        </li>
        <li>
          <Link href="/pathC">
            <a>Path C: Fight the Conspiracy</a>
          </Link>
        </li>
      </ul>
      <p>Or head over to mint your Jam Killer NFT:</p>
      <Link href="/mint">
        <a>Mint NFT</a>
      </Link>
    </div>
  );
}