const { ethers } = require("hardhat")

const PRICE = ethers.utils.parseEther("1")

//first: yarn hardhat node 
//then: yarn hardhat run scripts/mint-and-list.js --network localhost

async function mintAndList() {
    const nftMarketPlace = await ethers.getContract("NftMarketPlace")
    const basicNft = await ethers.getContract("BasicNft")
    console.log("Minting...")
    const mintTx = await basicNft.mintNft()
    const mintTxReceipt = await mintTx.wait(1)
    const tokenId = mintTxReceipt.events[0].args.tokenId

    const approvalTx = await basicNft.approve(nftMarketPlace.address, tokenId)
    /* { approve(address to, uint256 tokenId) }
       Approve or remove `operator` as an operator for the caller.
       Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller. 
    */
    await approvalTx.wait(1)
    console.log("Listing NFT...")
    const listTx = await nftMarketPlace.listItem(basicNft.address, tokenId, PRICE) 
    await listTx.wait(1)
    console.log("Listed!")
}

mintAndList()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error)
        process.exit(1)
    })