// scripts/deploy_upgradeable_box.js
const {ethers, upgrades} = require('hardhat');

async function main() {
  const ERC721 = await ethers.getContractFactory('YORKIES');
  const mc = await ERC721.deploy();

  await mc.deployed(
    'collection name', // collection name
    'collection symbol', // symbol
    10000, // supply
    200, //reserve
    'QmP5NXDTvFmFQiU91xDdt56yfSPybCUb22mX3Zkvg3nJDT', //reveal cid
    5000000000000000000, // price in wei
    4000000000000000000 // price in wei
  );
  console.log('YORKIES deployed to:', mc, mc.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
