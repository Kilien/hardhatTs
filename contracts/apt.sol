// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
// import "hardhat/console.sol";
import "../node_modules/hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token - a simple example (non - ERC-20 compliant) token contract.
 */
contract APT is ERC20 {
    address private owner;

    constructor(uint256 initialSupply) ERC20("AwesomeProject", "APT") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * get owner address
     */
    function ownerOf() public view returns (address) {
        return owner;
    }

    function hello() public pure returns(uint) {
        console.log('hello...');
        return 1;
    }

    /**
     * set owner address
     */
    function setOwner(address account) public returns (address) {
        require(msg.sender != owner, "not owner");
        owner = account;
        return owner;
    }

    function burn(address account, uint256 amount) public returns (uint256) {
        require(msg.sender != owner, "not owner");
        _burn(account, amount);
        return account.balance;
    }
}
