// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTCollection is ERC721, Ownable, IERC721Receiver {
    error NFTCollection__PriceNotMatch();
    error NFTCollection__MaxSupplyReached();
    error NFTCollection__FailedToSendEther();

    uint256 public immutable i_maxSupply;
    uint256 public currentTokenId = 1;

    event NFTMinted(uint256 indexed tokenId, address indexed owner, uint256 mintPrice);

    struct NFTCreated {
        uint256 tokenId;
        uint256 mintPrice;
        address owner;
    }

    mapping(uint256 => NFTCreated) public nftCreated;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        i_maxSupply = _maxSupply;
    }

    function mint(address to, uint256 mintPrice) public payable returns (uint256) {
        if (msg.value != mintPrice) revert NFTCollection__PriceNotMatch();
        uint256 tokenId = currentTokenId;

        if (currentTokenId > i_maxSupply) revert NFTCollection__MaxSupplyReached();

        nftCreated[tokenId] = NFTCreated({tokenId: tokenId, mintPrice: mintPrice, owner: to});
        unchecked {
            currentTokenId++;
        }

        _safeMint(to, tokenId);

        emit NFTMinted(tokenId, to, mintPrice);
        return tokenId;
    }

    function selfMint() external payable returns (uint256) {
        return mint(_msgSender(), msg.value);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://nftcollection.com/";
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (address(this).balance > 0) {
            (bool success,) = payable(owner()).call{value: balance}("");
            if (!success) revert NFTCollection__FailedToSendEther();
        }
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
