// scripts/deploy_upgradeable_box.js
const {ethers, upgrades} = require('hardhat');

async function main() {
  const ERC721 = await ethers.getContractFactory('YORKIES');
  const mc = await ERC721.deploy();

  await mc.deployed(
    'insert name', // collection name
    'symbol', // symbol
    10000, // supply
    200, //reserve
    'uri' //uri'
  );
  console.log('YORKIES deployed to:', mc, mc.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
