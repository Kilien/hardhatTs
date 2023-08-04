// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract MechaCat is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct CardInfo {
        uint id;
        string name;
        uint currentAmount;
        uint burnedAmount;
        uint maxAmount;
        string tokenURI;
    }

    mapping(uint => CardInfo) public cardInfo;
    mapping(uint => uint) public cardIdMap;
    mapping(address => mapping(uint => uint)) public minters;
    mapping(address => bool) private freeMinted;
    address public superMinter;

    constructor() ERC721("MechaCat", "MCat") {
        newCard(
            168,
            "Origin Cat",
            100000,
            "QmZiVN5GkWvftHYNzVpR2EEYRmjYs1emg52C4utRGu7kfC"
        );
        newCard(
            200,
            "Merge Cat",
            50000,
            "QmaJcC2xGaurV8z8qiLCi52dYmTuu9hwmTMSkLE7zfQAKA"
        );
        newCard(
            222,
            "Merlin Cat",
            25000,
            "QmeFypffVrVsjbw1UvcTrKEGrKvJDcm8gmZjYbCUFXtn8H"
        );
        newCard(
            226,
            "Evelyn Cat",
            25000,
            "QmUPwkcQ8xH8cZBkz87DzAnV8PFcB9P4Z5NWEny1kWtToA"
        );
        newCard(
            300,
            "Dauphin Cat",
            4000,
            "QmShCuYTqunYW4P49pZT7wzRXAngc77qehcwBUZEY4SG8X"
        );
        newCard(
            400,
            "Turing",
            800,
            "QmRPSXkS8jWHpY6FAihbXfkWasJPcn2KkvqMBcktazQ8JQ"
        );
        superMinter = msg.sender;
    }

    function newCard(
        uint id_,
        string memory name_,
        uint maxAmount_,
        string memory tokenURI_
    ) public onlyOwner {
        require(id_ != 0 && cardInfo[id_].id == 0, "MechaCat: wrong Id");

        cardInfo[id_] = CardInfo({
            id: id_,
            name: name_,
            currentAmount: 0,
            burnedAmount: 0,
            maxAmount: maxAmount_,
            tokenURI: tokenURI_
        });
    }

    function setSuperMinter(
        address newSuperMinter_
    ) public onlyOwner returns (bool) {
        superMinter = newSuperMinter_;
        return true;
    }

    /**
     * 同一个用户铸造多种卡片
     * @param player_ 用户
     * @param cardIds 卡片Ids
     */
    function mintVariousCards(
        address player_,
        uint[] memory cardIds
    ) public returns (bool) {
        for (uint i = 0; i < cardIds.length; ++i) {
            mint(player_, cardIds[i]);
        }
        return true;
    }

    /**
     * 铸造卡片
     * @param player_ 用户
     * @param cardId_ 卡片Id
     */
    function mint(address player_, uint cardId_) public returns (uint) {
        require(
            cardId_ != 0 && cardInfo[cardId_].id != 0,
            "MechaCat: wrong cardId"
        );

        if (superMinter != msg.sender) {
            require(minters[msg.sender][cardId_] > 0, "MechaCat: not minter");
            minters[msg.sender][cardId_] -= 1;
        }

        require(
            cardInfo[cardId_].currentAmount < cardInfo[cardId_].maxAmount,
            "k: amount out of limit"
        );
        cardInfo[cardId_].currentAmount += 1;

        uint tokenId = getNextTokenId();
        cardIdMap[tokenId] = cardId_;
        _safeMint(player_, tokenId);

        return tokenId;
    }

    /**
     * 免费铸造
     */
    function freeMint() external returns (uint) {
        require(
            freeMinted[msg.sender] == false,
            "minted"
        );
        
        require(
            cardInfo[168].currentAmount < cardInfo[168].maxAmount,
            "k: amount out of limit"
        );
        cardInfo[168].currentAmount += 1;

        uint tokenId = getNextTokenId();
        cardIdMap[tokenId] = 168;
        _safeMint(msg.sender, tokenId);
        freeMinted[msg.sender] = true;
        return tokenId;
    }

    function getNextTokenId() internal returns (uint) {
        _tokenIds.increment();
        return _tokenIds.current();
    }

    function exists(uint tokenId_) public view returns (bool) {
        return _exists(tokenId_);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 _tokenId) external onlyOwner returns (bool) {
        _burn(_tokenId);
        return true;
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    /**
     * IPFS json
     * @param tokenId_ id
     */
    function tokenURI(
        uint tokenId_
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(super._exists(tokenId_), "MechaCatr: not existent token");

        return
            string.concat(_baseURI(), cardInfo[cardIdMap[tokenId_]].tokenURI);
    }

    function checkUserCardIds(
        address userAddr_
    ) public view returns (uint[] memory) {
        uint len = super.balanceOf(userAddr_);
        uint[] memory cardIdList = new uint[](len);
        for (uint i = 0; i < len; i++) {
            uint tokenId = super.tokenOfOwnerByIndex(userAddr_, i);
            cardIdList[i] = tokenId;
        }
        return cardIdList;
    }

    /**
     * 查询用户卡片列表
     * @param userAddr_  用户地址
     */
    function checkUserCardList(
        address userAddr_
    ) public view returns (CardInfo[] memory cardList) {
        uint len = super.balanceOf(userAddr_);
        cardList = new CardInfo[](len);
        for (uint i = 0; i < len; i++) {
            uint tokenId = super.tokenOfOwnerByIndex(userAddr_, i);
            cardList[i] = cardInfo[cardIdMap[tokenId]];
        }
    }
}
