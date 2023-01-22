const { ethers, network } = require("hardhat")
const { moveBlocks } = require("../utils/move-blocks")

const TOKEN_ID = 0

async function cancelListing() {

    const nftMarketPlace = await ethers.getContract("NftMarketPlace")
    const basicNft = await ethers.getContract("BasicNft")
    const cancelTx = await nftMarketPlace.cancelListing(basicNft.address, TOKEN_ID)
    const cancelReceipt = await cancelTx.wait(1)
    console.log("NFT cancelled!!")

    if(network.config.chainId == 31337) {
        await moveBlocks(2, 1000)
    } 
}

cancelItem()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error)
        process.exit(1)
    })