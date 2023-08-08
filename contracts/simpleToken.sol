// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract simpleToken is ERC20, Ownable {
    address public pair;
    uint private Fee = 200; // 2%手续费
    uint private initialSupply = 1 * 1e24; // 100w

    mapping(address => bool) pairs;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    // 新增合约组合
    function addPairs(address[] calldata pairs_, bool isOpen) external onlyOwner {
        for(uint i=0; i < pairs_.length; i++) {
            pairs[pairs_[i]] = isOpen;
        }
    }

    // 交易逻辑
    function _processTransfer(address from, address to, uint amount) internal {
        //    买卖手续费2%
       if (pairs[from] || pairs[to] ) {
           uint _fee = amount * Fee / 10000;
           _transfer(from, address(this), _fee); // 手续费入合约
           _transfer(from, to, amount - _fee); // 剩余给用户
           return;
       }
       _transfer(from, to, amount);
    }

    // 重写 transfer
    function transfer(address to, uint amount) public override returns(bool) {
        address _sender = msg.sender;
        _processTransfer(_sender, to, amount);
        return true;
    }

    // 重写 transferFrom
    function transferFrom(address from, address to, uint amount) public override returns(bool) {
        address _sender = msg.sender;
        _spendAllowance(from, _sender, amount);
        _processTransfer(from, to, amount);
        return true;
    }


    // 提现fee
    function withdrowFee(address wallet_,uint amount_) external onlyOwner {
        _transfer(address(this), wallet_, amount_);
    }
}