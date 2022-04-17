// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Utility.sol"; // Utility Functions

contract YORKIES is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter internal _tokenIds;

    string internal revealCID;
    string internal baseCID; // CID of the base URI I.E//QmP5NXDTvFmFQiU91xDdt56yfSPybCUb22mX3Zkvg3nJDT
    // Files In IPFS Folder need to be name 1.json, 2.json, 3.json, etc.

    bool public _paused = true; //Minting Status

    bool public premint_paused = true; //Preminting Status

    uint256 public _price; //Price in wei
    uint256 public _discount_price; //Discounted Price in wei

    uint256 public _reserved; //Reserved Tokens for giveaway

    uint16 public mintingSupply; // NFT Supply Cap

    uint16 public mintedFromReserve; // reserved token supply //default 0

    uint16 public mintedFromSupply; // reserved token supply //default 0
    mapping(address => bool) public whitelisted; // Reserved Tokens for Giveaway
    mapping(address => bool) public claimedToken; // pre-minted tokens per address

    //INITIALIZING CONTRACT
    constructor(
        string memory name,
        string memory symbol,
        uint16 supply,
        uint256 reserved,
        string memory uri,
        address[] memory _whiteList,
        uint256 price,
        uint256 discount_price

    ) ERC721(name, symbol) {
        mintingSupply = supply;
        _reserved = reserved;
        revealCID = uri;
        whitelistBatch_Admin(_whiteList);
        _price = price;
    }

    //Get Total Supply of Tokens // --<
    function totalSupply() public view override returns (uint256) {
        return _tokenIds.current();
    }

    // Allows Tokens to be Viewed // --<
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            bytes(baseCID).length > 0
                ? string(
                    abi.encodePacked(
                        "ipfs://",
                        baseCID,
                        "/",
                        tokenId,
                        ".json"
                    )
                )
                : revealCID;
    }

    // --<
    function pre_mint() external payable {
        require(whitelisted[msg.sender], "NOT_WHITELISTED");
        require(!claimedToken[msg.sender], "Presale Token Claimed");
        require(!premint_paused, "Minting is currently paused!");
        require(msg.value == getDiscountPrice(1), "ETH sent not correct!");
        require(
            mintedFromSupply + 1 <= mintingSupply - _reserved,
            "Exceeds Minting Supply"
        );
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
        mintedFromSupply++;
        claimedToken[msg.sender] = true;
    }

    //MINT x amount of NFT // --<
    function mint(uint8 amount) external payable {
        uint256 price = getDiscountPrice(amount);
        require(!_paused, "Minting is currently paused!");
        require(msg.value == price * amount, "ETH sent not correct!");
        require(
            mintedFromSupply + amount <= mintingSupply - _reserved,
            "MUST_MINT_FROM_RESERVE"
        );
        require(amount > 0 && amount <= 5, "EXCEEDS_TRANSACTION_LIMIT");
        for (uint256 i = 0; i < amount; i++) {
            _tokenIds.increment();
            _safeMint(msg.sender, _tokenIds.current());
            mintedFromSupply++;
        }
    }

    // --<
    function giveAway(address _to, uint256 _amount) external onlyOwner {
        require(mintedFromReserve + _amount <= _reserved, "EXCEEDS_SUPPLY");
        for (uint256 i; i < _amount; i++) {
            _tokenIds.increment();
            _safeMint(_to, _tokenIds.current());
            mintedFromReserve++;
        }
    }

    //CHANGE PAUSE STATE // --<
    function premint_toggle() external onlyOwner {
        premint_paused = !premint_paused;
    }

    // --<
    function mint_toggle() external onlyOwner {
        premint_paused = true;
        _paused = !_paused;
    }

    //GET PRICE // --<
    function getDiscountPrice(uint256 amount) public view returns (uint256) {
        if (amount >= 10) {
            return _discount_price;
        } else {
            return _price;
        }
    }

    // --<
    function getPrice() public view returns (uint256) {
        return _price;
    }

    //RETURN ALL TOKENS OF A SPECIFIC ADDRESS // --<
    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    //WITHDRAW CONTRACT BALANCE TO DEFINED ADDRESS // --<
    function withdraw(address _withdrawAddress) public onlyOwner {
        payable(address(_withdrawAddress)).transfer(address(this).balance);
    }

    //SETS THE BASEURL FOR THE METADATA USING CID // --<
    function setBaseURI(string calldata cid) public onlyOwner {
        baseCID = cid;
    }

    // SETS WHITELIST // TESTED
    function whitelistBatch_Admin(address[] memory _to) public onlyOwner {
        for (uint256 i = 0; i < _to.length; i++) {
            whitelisted[_to[i]] = true;
        }
    }

    // --<
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // --<
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
