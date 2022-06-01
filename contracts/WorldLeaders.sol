// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import "@chiru-labs/contracts//ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WorldLeaders is ERC721A {
    using Strings for uint256;

    string public uriPrefix = "";
    string public constant uriSuffix = ".json";

    uint96 constant royaltyFeesInBips = 1000;
    address constant royaltyAddress =
        0xA4Ad17ef801Fa4bD44b758E5Ae8B2169f59B666F;

    constructor() ERC721A("World Leaders", "WLD") {
        _safeMint(msg.sender, 100);
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = _startTokenId();
        uint256 ownedTokenIndex = 0;
        address latestOwnerAddress;

        while (
            ownedTokenIndex < ownerTokenCount && currentTokenId <= totalSupply()
        ) {
            TokenOwnership memory ownership = _ownershipOf(currentTokenId);

            if (!ownership.burned) {
                if (ownership.addr != address(0)) {
                    latestOwnerAddress = ownership.addr;
                }

                if (latestOwnerAddress == _owner) {
                    ownedTokenIds[ownedTokenIndex] = currentTokenId;

                    ownedTokenIndex++;
                }
            }

            currentTokenId++;
        }

        return ownedTokenIds;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        uriSuffix
                    )
                )
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        virtual
        returns (address, uint256)
    {
        return (royaltyAddress, calculateRoyalty(_salePrice));
    }

    function calculateRoyalty(uint256 _salePrice)
        public
        pure
        returns (uint256)
    {
        return (_salePrice / 10000) * royaltyFeesInBips;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721A)
        returns (bool)
    {
        return
            interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }
}
