// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/extension/ERC721Base.sol";

/*
    Contract Name   : Don't Kill the Jam NFT
    Symbol          : DKJ
    Description     : Choose your musical Destiny Jam Killer, Be rewarded with Mojo for Producer Protocol and an exclusive collectors NFT.
    Platform Fee    : 0.000777 ETH on Optimism
*/

contract DontKillTheJamNFT is ERC721Base {
    mapping(uint256 => string) public gamePath;
    mapping(address => bool) public hasFinalNFT;
    
    uint256 public constant MAX_SUPPLY = 3333;
    // Set mint fee to 0.000777 ETH
    uint256 public constant MINT_FEE = 0.000777 ether;

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

    constructor(
        address _defaultAdmin,
        address _royaltyRecipient,
        uint128 _royaltyBps
    ) ERC721Base(_defaultAdmin, "Don't Kill the Jam", "DKJ", _royaltyRecipient, _royaltyBps) {}

    // Public mint function requiring a fixed mint fee
    function mintNFT(
        address to,
        string memory path
    ) external payable returns (uint256 tokenId) {
        require(msg.value == MINT_FEE, "Must send mint fee of 0.000777 ETH");
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

    // Emits progress update for the caller
    function markProgress(string memory progress) external {
        emit ProgressMarked(msg.sender, progress, block.timestamp);
    }

    // Finalize NFT for a given address and mark that final NFT has been minted
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

    // Update token URI for an existing token
    function updateTokenURI(
        uint256 tokenId,
        string memory newURI
    ) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _setTokenURI(tokenId, newURI);
        emit NFTUpdated(tokenId, newURI);
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