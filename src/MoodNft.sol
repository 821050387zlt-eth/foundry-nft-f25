//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721URIStorage {
    error MoodNft__CantFlipMoodIfNotOwner();
    error MoodNft__TokenDoesNotExist();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum Mood { HAPPY, SAD }
    mapping (uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory sadSvgImageUri, 
        string memory happySvgImageUri
    ) ERC721 ("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // 校验 tokenId 存在（v5.5.0 正确方式）
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) revert MoodNft__TokenDoesNotExist();
        
        string memory imageURI = s_tokenIdToMood[tokenId] == Mood.HAPPY 
            ? s_happySvgImageUri 
            : s_sadSvgImageUri;

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "', name(), '",',
                            '"description": "An NFT that changes based on mood", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], ',
                            '"image": "', imageURI, '"}'
                        )
                    )
                )
            )
        );
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function flipMood(uint256 tokenId) public {
        // ========== v5.5.0 _checkAuthorized 正确调用方式 ==========
        address tokenOwner = _ownerOf(tokenId); // 获取 NFT 所有者
        _checkAuthorized(tokenOwner, msg.sender, tokenId); // 校验调用者是否有权限

        // 翻转心情逻辑
        s_tokenIdToMood[tokenId] = s_tokenIdToMood[tokenId] == Mood.HAPPY 
            ? Mood.SAD 
            : Mood.HAPPY;
    }
}