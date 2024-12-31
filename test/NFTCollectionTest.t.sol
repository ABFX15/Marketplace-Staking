// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Test, console2} from "forge-std/Test.sol";
import {NFTCollection} from "../src/NFTCollection.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTCollectionTest is Test, IERC721Receiver {
    NFTCollection public nftCollection;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MINT_PRICE = 0.01 ether;
    uint256 public constant BIDDER_PRICE = MINT_PRICE + 1 ether;

    function setUp() public {
        nftCollection = new NFTCollection("Test NFT", "TEST", MAX_SUPPLY);
    }

    function testCanCreateNFT() public {
        uint256 mintPrice = MINT_PRICE;
        uint256 tokenId = nftCollection.mint{value: mintPrice}(address(this), mintPrice);

        (uint256 storedTokenId, uint256 storedMintPrice, address storedOwner) = nftCollection.nftCreated(tokenId);
        assertEq(storedTokenId, tokenId);
        assertEq(storedMintPrice, mintPrice);
        assertEq(storedOwner, address(this));
    }

    function testRevertsIfMintPriceIsNotMatch() public {
        uint256 mintPrice = MINT_PRICE;
        uint256 bidderPrice = BIDDER_PRICE;

        vm.expectRevert(NFTCollection.NFTCollection__PriceNotMatch.selector);
        nftCollection.mint{value: bidderPrice}(address(this), mintPrice);
    }

    function testYouCanMint() public {
        uint256 mintPrice = MINT_PRICE;

        uint256 tokenId = nftCollection.mint{value: mintPrice}(address(this), mintPrice);
        assertEq(tokenId, 1);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
