import { ethers } from 'hardhat'

async function main() {
  const wallet = await ethers.getContractAt(
    'EtherWallet',
    '0x61d4f00216A02B82475B9781F498662847b06d3C'
  )
  const [deployer] = await ethers.getSigners()
  // console.log(
  //   await wallet.deposit({
  //     from: deployer.address,
  //     value: ethers.utils.parseEther('0.1'),
  //   })
  // )
  console.log(
    await (
      await deployer.sendTransaction({
        to: wallet.address,
        value: ethers.utils.parseEther('0.1'),
      })
    ).wait()
  )
  // console.log(
  //   await (
  //     await wallet.withdraw(
  //       '0xC48151B0E7aAd4C391D99Db0047800016e694dC8',
  //       ethers.utils.parseEther('0.1')
  //     )
  //   ).wait()
  // )
  console.log(ethers.utils.formatEther(await wallet.balanceOf(deployer.address)), 'ETH')
  // console.log(
  //   ethers.utils.formatEther(
  //     await ethers.provider.getBalance('0xC48151B0E7aAd4C391D99Db0047800016e694dC8')
  //   ),
  //   'ETH'
  // )
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e)
    process.exit(1)
  })
