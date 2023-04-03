import { providers } from "ethers"

async function readStorage() {
    const provider = new providers.JsonRpcProvider(
        "https://eth-goerli.alchemyapi.io/v2/W4zZE8TgeZC8QnDNpfl603NqwKHWxpiw"
    )
    console.log(await provider.getStorageAt("0x92F56CCf07101443b656A1F6298b9C38dBE8dd70", 5))
}

readStorage()
