// scripts/deploy.js
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const JamKillerNFT = await ethers.getContractFactory("JamKillerNFT");
    const nftContract = await JamKillerNFT.deploy();
    await nftContract.deployed();

    console.log("JamKillerNFT deployed to:", nftContract.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});