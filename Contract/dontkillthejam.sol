// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";

contract DystopianNarrativeNFT is ERC721Base {
    mapping(uint256 => string) public gamePath;
    mapping(address => bool) public hasFinalNFT;
    mapping(address => bool) public hasReceivedProducerReward;
    address public producerTokenAddress;
    uint256 public constant MAX_SUPPLY = 3333;

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

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        address _producerTokenAddress,
        address _royaltyRecipient,
        uint128 _royaltyBps  // Changed from uint256 to uint128
    ) ERC721Base(_defaultAdmin, _name, _symbol, _royaltyRecipient, _royaltyBps) {
        producerTokenAddress = _producerTokenAddress;
    }

    function mintNFT(
        address to,
        string memory path
    ) external returns (uint256 tokenId) {
        require(_currentIndex < MAX_SUPPLY, "Max supply reached");
        require(
            compareStrings(path, "A") ||
                compareStrings(path, "B") ||
                compareStrings(path, "C"),
            "Invalid path"
        );
        tokenId = _currentIndex;
        _safeMint(to, 1);
        string memory initialURI = getInitialTokenURI(path);
        _setTokenURI(tokenId, initialURI);
        gamePath[tokenId] = path;
        emit NFTMinted(tokenId, to, path);
    }

    function markProgress(string memory progress) external {
        emit ProgressMarked(msg.sender, progress, block.timestamp);
    }

    function finalizeNFT(
        address to,
        string memory finalURI,
        string memory path
    ) external onlyOwner returns (uint256 tokenId) {
        require(_currentIndex < MAX_SUPPLY, "Max supply reached");
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

    function updateTokenURI(
        uint256 tokenId,
        string memory newURI
    ) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _setTokenURI(tokenId, newURI);
        emit NFTUpdated(tokenId, newURI);
    }

    function rewardProducer(address to, uint256 amount) external onlyOwner {
        require(
            !hasReceivedProducerReward[to],
            "Producer reward already distributed"
        );
        hasReceivedProducerReward[to] = true;
        IProducerToken(producerTokenAddress).mint(to, amount);
        emit ProducerRewarded(to, amount);
    }

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

    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}

interface IProducerToken {
    function mint(address to, uint256 amount) external;
}
