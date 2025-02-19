// frontend/pages/pathB.js
import React from "react";
import Link from "next/link";

export default function PathB() {
  return (
    <div style={{ padding: "20px", fontFamily: "sans-serif" }}>
      <h2>Path B: Solo Composition</h2>
      <p>Work with AI-powered tools to craft your unique sound and create masterpieces.</p>
      {/* Integrate AI tools or simulation components as needed */}
      <Link href="/mint">
        <a>Mint NFT for Your Composition</a>
      </Link>
      <br />
      <Link href="/">
        <a>Back Home</a>
      </Link>
    </div>
  );
}