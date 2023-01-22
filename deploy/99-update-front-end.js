/*
require("dotenv").config
const fs = require("fs")
const { ethers, network } = require("hardhat")
const { frontEndContractsFile, frontEndAbiLocation } = require("../helper-hardhat-config")

module.exports = async () => {
    if (process.env.UPDATE_FRONT_END) {
        console.log("Writing to front end...")
        await updateContractAddresses()
        await updateAbi()
        console.log("front end written")
    }
}

async function updateAbi() {

    const nftMarketPlace = await ethers.getContract("NftMarketPlace")
    fs.writeFileSync(
        `${frontEndAbiLocation}NftMarketPlace.json`,
        nftMarketPlace.interface.format(ethers.utils.FormatTypes.json)
    )

    const basicNft = await ethers.getContract("BasicNft")
    fs.writeFileSync(
        `${frontEndAbiLocation}BasicNft.json`,
        basicNft.interface.format(ethers.utils.FormatTypes.json)
    )
}

async function updateContractAddresses() {
    const chainId = network.config.chainId.toString()
    const nftMarketPlace = await ethers.getContract("NftMarketPlace")
    const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, "utf-8"))
    if (chainId in contractAddresses) {
        if (!contractAddresses[chainId]["NftMarketPlace"].includes(nftMarketPlace.address)) {
            contractAddresses[chainId]["NftMarketPlace"].push(nftMarketPlace.address)
        }
    } else {
        contractAddresses[chainId] = { NftMarketPlace: [nftMarketPlace.address]}
    }
    fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))
}

module.exports.tags = ["all", "frontend"]
*/

module.exports = async () => {
    console.log("yooo")
}