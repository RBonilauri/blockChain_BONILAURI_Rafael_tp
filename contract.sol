// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyNFT is ERC721, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VIP_ROLE = keccak256("VIP_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    uint256 public constant MAX_SUPPLY = 5;
    uint256 public constant BASE_PRICE = 1 ether;
    uint256 public constant VIP_PRICE = 0.5 ether;

    mapping (uint256 => string) private _tokenNames;

    bool private _isPrivate;
    bool public isActive = true;

    struct User {
        bool banned;
    }

    mapping (address => User) private _users;

    constructor() ERC721("MyNFT", "MNFT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _isPrivate = true;
    }

    modifier onlyPrivate() {
        require(!_isPrivate || hasRole(ADMIN_ROLE, msg.sender) || hasRole(VIP_ROLE, msg.sender) || hasRole(WHITELIST_ROLE, msg.sender), "Not authorized");
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


    function setPrivate(bool isPrivate) public onlyRole(ADMIN_ROLE) {
        _isPrivate = isPrivate;
    }

    function mint(address to) public onlyPrivate {
        // require(ERC721.totalSupply() < MAX_SUPPLY, "Max supply reached");

        // uint256 tokenId = ERC721.totalSupply() + 1;
        // string memory tokenName = generateTokenName(tokenId);
        // uint256 price = getPrice(tokenId);
        // require(msg.value >= price, "Insufficient funds");

        // _mint(to, tokenId);
        // _tokenNames[tokenId] = tokenName;
    }

    function generateTokenName(uint256 tokenId) private view returns (string memory) {
        return string(abi.encodePacked("MyToken #", tokenId));
    }

    function getTokenName(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenNames[tokenId];
    }

    function getPrice(uint256 tokenId) public view returns (uint256) {
        if (hasRole(ADMIN_ROLE, msg.sender)) {
            return 0;
        } else if (hasRole(VIP_ROLE, msg.sender)) {
            return VIP_PRICE;
        } else {
            return BASE_PRICE;
        }
    }

    function addVip(address account) public onlyRole(ADMIN_ROLE) onlyPrivate {
        grantRole(VIP_ROLE, account);
    }

    function removeVip(address account) public onlyRole(ADMIN_ROLE) onlyPrivate {
        revokeRole(VIP_ROLE, account);
    }

    function addWhitelist(address account) public onlyRole(ADMIN_ROLE) onlyPrivate {
        grantRole(WHITELIST_ROLE, account);
    }

    function removeWhitelist(address account) public onlyRole(ADMIN_ROLE) onlyPrivate {
        revokeRole(WHITELIST_ROLE, account);
    }

    function banUser(address account) public onlyRole(ADMIN_ROLE) {
        require(hasRole(ADMIN_ROLE, account) || hasRole(VIP_ROLE, account) || hasRole(WHITELIST_ROLE, account), "Cannot ban this user");
        _users[account].banned = true;
    }

    function unbanUser(address account) public onlyRole(ADMIN_ROLE) {
        _users[account].banned = false;
    }

    function setPause() public onlyRole(ADMIN_ROLE) onlyPrivate {
        isActive = false;
    }

    function setActive() public onlyRole(ADMIN_ROLE) onlyPrivate {
        isActive = true;
    }


    receive() external payable {}
}
