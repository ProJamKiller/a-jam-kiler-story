// frontend/components/MintNFT.js
import React from "react";
import {
  useAddress,
  useMetamask,
  useContract,
} from "@thirdweb-dev/react";

export default function MintNFT() {
  const address = useAddress();
  const connectWithMetamask = useMetamask();

  // Replace with your deployed NFT contract address
  const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";

  // Get the contract instance
  const { contract } = useContract(contractAddress);

  const mint = async () => {
    if (!address) {
      connectWithMetamask();
      return;
    }
    try {
      // Call the contract's mintNFT function
      // Here, "ipfs://your-token-uri" should point to the metadata stored on IPFS
      await contract.call("mintNFT", [address, "ipfs://your-token-uri"]);
      alert("NFT minted successfully!");
    } catch (error) {
      console.error("Minting failed:", error);
      alert("Minting failed. Please check the console for details.");
    }
  };

  return (
    <button onClick={mint} style={{ padding: "10px 20px", fontSize: "16px" }}>
      Mint Jam Killer NFT
    </button>
  );
}