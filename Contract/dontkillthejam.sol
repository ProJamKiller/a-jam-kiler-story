// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin contracts for ERC721 and access control.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DystopianNarrativeNFT
 * @notice A dynamic NFT smart contract for a narrative-driven game with three paths:
 *         A: Build a band and host live events.
 *         B: Develop a solo career using AI-driven composition.
 *         C: Uncover and fight a conspiracy that suppresses artistic freedom.
 *
 * The contract supports deferred minting via progress markers and finalization.
 * It also integrates a surprise ERC20 reward for Producer Protocol.
 */
contract DystopianNarrativeNFT is ERC721URIStorage, Ownable {
    // Counter for token IDs.
    uint256 public tokenCounter;

    // Mapping from tokenId to chosen game path ("A", "B", or "C").
    mapping(uint256 => string) public gamePath;

    // Mapping to ensure each address can only finalize their NFT once.
    mapping(address => bool) public hasFinalNFT;
    
    // Mapping to ensure each address receives the producer reward only once.
    mapping(address => bool) public hasReceivedProducerReward;

    // Address of the Producer Protocol ERC20 token contract.
    address public producerTokenAddress;

    // Events for minting, updating, marking progress, and rewarding.
    event NFTMinted(uint256 indexed tokenId, address indexed owner, string path);
    event NFTUpdated(uint256 indexed tokenId, string newURI);
    event ProgressMarked(address indexed player, string progress, uint256 timestamp);
    event ProducerRewarded(address indexed player, uint256 amount);

    /**
     * @notice Interface for the Producer Protocol ERC20 token.
     */
    interface IProducerToken {
        function mint(address to, uint256 amount) external;
        // Alternatively, if using a transfer-based approach:
        // function transfer(address recipient, uint256 amount) external returns (bool);
    }
        /**
         * @notice Contract constructor sets the NFT name, symbol, and the Producer Protocol token address.
     * @param _producerTokenAddress The address of the Producer Protocol ERC20 token.
     */
    constructor(address _producerTokenAddress) ERC721("DystopianNarrativeNFT", "DYNFT") {
        tokenCounter = 0;
        producerTokenAddress = _producerTokenAddress;
    }

    /**
     * @notice Immediate minting function.
     * Mints a new NFT based on the selected game path.
     * @param to The recipient address for the NFT.
     * @param path The game path selected ("A", "B", or "C").
     * @return tokenId The ID of the minted NFT.
     */
    function mintNFT(address to, string memory path) external returns (uint256 tokenId) {
        require(compareStrings(path, "A") || compareStrings(path, "B") || compareStrings(path, "C"), "Invalid path");
        
        tokenId = tokenCounter;
        _safeMint(to, tokenId);
        
        // Set the initial metadata URI based on the selected path.
        string memory initialURI = getInitialTokenURI(path);
        _setTokenURI(tokenId, initialURI);
        
        // Record the selected game path.
        gamePath[tokenId] = path;
        
        tokenCounter++;
        emit NFTMinted(tokenId, to, path);
    }

    /**
     * @notice Records progress during the narrative.
     * Emits an event that can be listened to off-chain.
     * @param progress A string (or hash) representing the player's progress.
     */
    function markProgress(string memory progress) external {
        emit ProgressMarked(msg.sender, progress, block.timestamp);
    }

    /**
     * @notice Finalizes the narrative and mints the NFT to the player.
     * Callable only by the contract owner (e.g., a Cloudflare Worker after off-chain validation).
     * Ensures that each address can only have one finalized NFT.
     * @param to The recipient address.
     * @param finalURI The final token URI pointing to the complete narrative metadata.
     * @param path The final game path ("A", "B", or "C").
     * @return tokenId The ID of the minted NFT.
     */
    function finalizeNFT(address to, string memory finalURI, string memory path) external onlyOwner returns (uint256 tokenId) {
        require(!hasFinalNFT[to], "Final NFT already minted for this address");
        require(compareStrings(path, "A") || compareStrings(path, "B") || compareStrings(path, "C"), "Invalid path");

        tokenId = tokenCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, finalURI);
        gamePath[tokenId] = path;
        hasFinalNFT[to] = true;
        tokenCounter++;

        emit NFTMinted(tokenId, to, path);
    }

    /**
     * @notice Updates the token URI for a given NFT.
     * Only callable by the contract owner.
     * @param tokenId The ID of the NFT to update.
     * @param newURI The new token URI pointing to updated metadata.
     */
    function updateTokenURI(uint256 tokenId, string memory newURI) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _setTokenURI(tokenId, newURI);
        emit NFTUpdated(tokenId, newURI);
    }

    /**
     * @notice Distributes the Producer Protocol ERC20 token reward (e.g., "mojo") to a player.
     * Only callable by the contract owner.
     * Ensures each address receives the reward only once.
     * @param to The recipient address.
     * @param amount The amount of ERC20 tokens to mint as a reward.
     */
    function rewardProducer(address to, uint256 amount) external onlyOwner {
        require(!hasReceivedProducerReward[to], "Producer reward already distributed");
        hasReceivedProducerReward[to] = true;
        IProducerToken(producerTokenAddress).mint(to, amount);
        emit ProducerRewarded(to, amount);
    }

    /**
     * @notice Constructs the initial token URI based on the selected game path.
     * In production, these URIs should point to a metadata JSON file (e.g., stored on IPFS).
     * @param path The selected game path ("A", "B", or "C").
     * @return A string representing the initial token URI.
     */
    function getInitialTokenURI(string memory path) internal pure returns (string memory) {
        if (compareStrings(path, "A")) {
            return "ipfs://path-a-initial-metadata";
        } else if (compareStrings(path, "B")) {
            return "ipfs://path-b-initial-metadata";
        } else if (compareStrings(path, "C")) {
            return "ipfs://path-c-initial-metadata";
        } else {
            return "";
        }
    }

    /**
     * @notice Compares two strings for equality.
     * @param a The first string.
     * @param b The second string.
     * @return True if the strings are equal, false otherwise.
     */
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    }
}