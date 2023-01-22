const { developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async function({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const waitBlockConfirmations = developmentChains.includes(network.name) ? 1 : 6
    const arguments = []

    log("---------------------------------------------------")

    const nftMarketPlace = await deploy("NftMarketPlace", {
        args: arguments,
        from: deployer,
        log: true,
        waitConfirmations: waitBlockConfirmations
    })

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(nftMarketPlace.address, arguments)
    }

    log("-----------------------------------------------------")
}

module.exports.tags = ["all", "nftmarketplace"]