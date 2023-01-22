const { ethers, network } = require("hardhat")
const { moveBlocks } = require("../utils/move-blocks")

async function mint() {
    const basicNft = await ethers.getContract("BasicNft") 

    console.log("Minting NFT...")
    
    const mintTx = await basicNft.mintNft()
    const mintTxReceipt = await mintTx.wait(1)
    const tokenId = mintTxReceipt.events[0].args.tokenId

    console.log(`Minted tokenId ${tokenId.toString()} from contract ${basicNft.address}`)

    if (network.config.chainId == 31337) {
        await moveBlocks(2, 1000) // move 2 blocks, sleep for 1000ms (1s)
    }
}

mint()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error)
        process.exit(1)
    })