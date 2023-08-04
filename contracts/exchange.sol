// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface Token {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory); //名字

    function symbol() external view returns (string memory); //缩写

    function decimals() external view returns (uint8);//精度

    function agentPayment(address spender, uint256 amount) external returns (bool);

    function agentBurn(address spender, uint256 amount) external returns (bool);
}

contract exchangeToken {
    address private owner;
    address apt;
    address bpt;

    Token token1; 
    Token token2; 

    struct UserInfo {
        uint buyAmount; // 买入多少
        uint toAmount; // 转移多少
        uint timestamp;
    }

    mapping(address => UserInfo) public userInfo;

    constructor(address tokenA, address tokenB) {
        apt = tokenA;
        bpt = tokenB;
        token1 = Token(tokenA); 
        token2 = Token(tokenB); 
    }

    event BuyToken(address indexed sender, uint amount, uint payAmount); // 买币
    event BuyBack(address indexed sender, uint amount, uint payAmount); // 兑换

    // 只允许自身调用
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // 余额不足
    modifier validBalance(uint256 amount_) {
        require(amount_ != 0, "Insufficient balance");
        _;
    }

    // 设置Owner
    function setOwner(address account) public onlyOwner returns (address) {
        owner = account;
        return owner;
    }

    function setTokens(address tokenA, address tokenB) external onlyOwner returns(bool) {
        token1 = Token(tokenA); 
        token2 = Token(tokenB); 
        return true;
    }

    // A代币买B代币
    function buyToken(uint amount) external returns(bool){
        address _sender = msg.sender;
        UserInfo storage info = userInfo[_sender];
        uint aptBalance = token1.balanceOf(_sender);
        uint bptBalance = token2.balanceOf(bpt);
        // 余额不足
        require(aptBalance >= amount, "Insufficient balance");
        require(bptBalance >= amount, "Not enough tokens in the reserve");
        // 收钱 A代币
        token1.transferFrom(_sender, address(this), amount);
        // 记账
        info.buyAmount = amount;
        info.timestamp = block.timestamp;
        // 给B代币
        token2.agentPayment(_sender, amount);
        
        emit BuyToken(_sender, amount, amount);
        return true;
    }

    function buyBack(uint amount) external returns(bool){
        address _sender = msg.sender;
        UserInfo storage info = userInfo[_sender];
        uint aptBalance = token1.balanceOf(address(this));
        uint bptBalance = token2.balanceOf(_sender);

        // 余额不足
        require(bptBalance >= amount, "Insufficient balance");
        require(aptBalance >= amount, "Not enough tokens in the reserve");

        // 烧了B币
        token2.agentBurn(_sender, amount);
        // 给A币
        token1.transfer(address(this), amount);

        // 代币收了2%手续费
        uint fee = amount * 200 / 10000;
        uint payAmount = amount - fee;
        info.buyAmount = 0;
        info.toAmount = payAmount;
        info.timestamp = block.timestamp;

        emit BuyBack(_sender, amount, payAmount);

        return true;
    }

}