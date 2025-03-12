// SPDX-License// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";

contract DystopianNarrativeNFT is ERC721Base {
    // Mapping from tokenId to chosen game path ("A", "B", or "C")
    mapping(uint256 => string) public gamePath;

    // Mapping to ensure each address can only finalize their NFT once
    mapping(address => bool) public hasFinalNFT;

    // Mapping to ensure each address receives the producer reward only once
    mapping(address => bool) public hasReceivedProducerReward;

    // Address of the Producer Protocol ERC20 token contract
    address public producerTokenAddress;

    // Events for minting, updating, marking progress, and rewarding
    event NFTMinted(
        uint256 indexed tokenId,
        address indexed owner,
        string path
    );
    event NFTUpdated(uint256 indexed tokenId, string newURI);
    event ProgressMarked(
        address indexed player,
        string progress,
        uint256 timestamp
    );
    event ProducerRewarded(address indexed player, uint256 amount);

    // The Producer Protocol interface
    interface IProducerToken {
        function mint(address to, uint256 amount) external;
    }

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        address _producerTokenAddress
    ) ERC721Base(_defaultAdmin, _name, _symbol) {
        producerTokenAddress = _producerTokenAddress;
    }

    // Restrict certain functions to the contract deployer
    modifier onlyAdmin() {
        require(msg.sender == owner(), "Only admin can call this function");
        _;
    }

    // Mint an NFT with an initial metadata URI based on the chosen game path.
    function mintNFT(
        address to,
        string memory path
    ) external returns (uint256 tokenId) {
        require(
            compareStrings(path, "A") ||
                compareStrings(path, "B") ||
                compareStrings(path, "C"),
            "Invalid path"
        );

        tokenId = _currentIndex;
        _safeMint(to, 1);

        // Set the initial metadata URI based on the selected path.
        string memory initialURI = getInitialTokenURI(path);
        _setTokenURI(tokenId, initialURI);

        // Record the selected game path.
        gamePath[tokenId] = path;

        emit NFTMinted(tokenId, to, path);
    }

    // Emit progress event to record narrative progression.
    function markProgress(string memory progress) external {
        emit ProgressMarked(msg.sender, progress, block.timestamp);
    }

    // Finalize the narrative and mint the NFT with a final metadata URI.
    function finalizeNFT(
        address to,
        string memory finalURI,
        string memory path
    ) external onlyAdmin returns (uint256 tokenId) {
        require(!hasFinalNFT[to], "Final NFT already minted for this address");
        require(
            compareStrings(path, "A") ||
                compareStrings(path, "B") ||
                compareStrings(path, "C"),
            "Invalid path"
        );

        tokenId = _currentIndex;
        _safeMint(to, 1);
        _setTokenURI(tokenId, finalURI);
        gamePath[tokenId] = path;
        hasFinalNFT[to] = true;

        emit NFTMinted(tokenId, to, path);
    }

    // Update the token URI for an existing NFT.
    function updateTokenURI(
        uint256 tokenId,
        string memory newURI
    ) external onlyAdmin {
        require(_exists(tokenId), "Token does not exist");
        _setTokenURI(tokenId, newURI);
        emit NFTUpdated(tokenId, newURI);
    }

    // Reward the player with ERC20 tokens (Mojo tokens) from Producer Protocol.
    function rewardProducer(address to, uint256 amount) external onlyAdmin {
        require(
            !hasReceivedProducerReward[to],
            "Producer reward already distributed"
        );
        hasReceivedProducerReward[to] = true;
        IProducerToken(producerTokenAddress).mint(to, amount);
        emit ProducerRewarded(to, amount);
    }

    // Return an initial token URI based on the game path.
    function getInitialTokenURI(
        string memory path
    ) internal pure returns (string memory) {
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

    // Utility function to compare two strings.
    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}