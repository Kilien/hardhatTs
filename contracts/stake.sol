// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mine is Ownable{
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint public dailyOut = 1000000 ether;
    uint public rates = dailyOut / 86400; //每秒产量
    uint public acc = 1e18;
    struct UserInfo{
        uint stakeAmount;
        uint debt;
        uint claimed;
        uint toClaim;
    }
    struct Debt{
        uint debt;
        uint lastTime;
    }
    mapping(address => UserInfo) public userInfo;
    uint public totalStakeAmount;
    Debt public debt;
    event Stake(address indexed player,uint indexed amount);
    event Unstake(address indexed player,uint indexed amount);

    constructor(address tokenA_, address tokenB_) {
        tokenA = IERC20(tokenA_);
        tokenB = IERC20(tokenB_);
    }


    function setToken(address tokenA_,address tokenB_) external onlyOwner{
        tokenA = IERC20(tokenA_);
        tokenB = IERC20(tokenB_);
    }

    function countingDebt() public view returns(uint _debt){
        if(debt.lastTime == 0){
            return 0;
        }
        if (totalStakeAmount==0){
            return debt.debt;
        }
        _debt = debt.debt;
        _debt += rates * acc / totalStakeAmount * (block.timestamp - debt.lastTime);
        
    }

    function _calculateReward(address addr) public view returns(uint){
        uint _tempDiff= countingDebt() - userInfo[addr].debt;
        uint _rew = _tempDiff * userInfo[addr].stakeAmount / acc;
        return _rew;
    }

    function calculateReward(address addr) public view returns(uint){
        return(userInfo[addr].toClaim + _calculateReward(addr));
    }

    function stake(uint amount) external{
        require(amount != 0,'wrong amount');
        uint aptBalance = tokenA.balanceOf(msg.sender);
        // 余额不足
        require(aptBalance >= amount, "Insufficient balance");
        // 收钱 A代币
        tokenA.transferFrom(msg.sender, address(this), amount);

        uint _tempDebt = countingDebt();
        if(userInfo[msg.sender].stakeAmount > 0){
            userInfo[msg.sender].toClaim += _calculateReward(msg.sender);
        }

        debt.debt = _tempDebt;
        debt.lastTime = block.timestamp;
        totalStakeAmount += amount;
        userInfo[msg.sender].stakeAmount += amount;
        userInfo[msg.sender].debt = _tempDebt;
    }

    function claim() external {
      require(userInfo[msg.sender].toClaim != 0,'not reward');
      uint _tempDebt = countingDebt();
      if(userInfo[msg.sender].stakeAmount > 0){
          userInfo[msg.sender].toClaim += _calculateReward(msg.sender);
      }
      uint bptBalance = tokenB.balanceOf(address(this));
      // 余额不足
      require(bptBalance >= userInfo[msg.sender].toClaim, "Not enough tokens in the reserve");
      // 打钱
      tokenB.transferFrom(address(this),msg.sender, userInfo[msg.sender].toClaim);
      delete userInfo[msg.sender].toClaim;
      debt.debt = _tempDebt;
      debt.lastTime = block.timestamp;
      userInfo[msg.sender].debt = _tempDebt;
    }

    function unstake() external {
        require(userInfo[msg.sender].stakeAmount != 0,'wrong amount');
        uint aptBalance = tokenA.balanceOf(address(this));
        // 余额不足
        require(aptBalance >= userInfo[msg.sender].stakeAmount, "Insufficient balance");
        // 收钱 A代币
        tokenA.transferFrom(address(this), msg.sender, userInfo[msg.sender].stakeAmount);
        uint _tempDebt = countingDebt();
        debt.debt = _tempDebt;
        debt.lastTime = block.timestamp;
        delete userInfo[msg.sender].stakeAmount;
        userInfo[msg.sender].debt = _tempDebt;
    }

}