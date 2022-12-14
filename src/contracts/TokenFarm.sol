// TokenFarm.sol
pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./MockDaiToken.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm";
    address public owner;
    DappToken public dappToken; // interface
    DaiToken public daiToken; // interface

    // store all the stakers
    address[] public stakers;

    // store the staking balance
    mapping(address => uint256) public stakingBalance;

    // store a value to show if someone has ever staked or not
    mapping(address => bool) public hasStaked;

    // store a value to show if someone is staking now
    mapping(address => bool) public isStaking;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken; // instance
        daiToken = _daiToken; // instance
        owner = msg.sender;
    }

    // core function of staking
    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "staking amount must be over zero");
        // send tokens to the contract
        daiToken.transferFrom(msg.sender, address(this), _amount);
        // change the staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    function issueTokens() public {
        // Dapp トークンを発行できるのはあなたのみであることを確認する
        require(msg.sender == owner, "caller must be the owner");

        // 投資家が預けた偽Daiトークンの数を確認し、同量のDappトークンを発行する
        for (uint256 i = 0; i < stakers.length; i++) {
            // recipient は Dapp トークンを受け取る投資家
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];
            if (balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }

    function unstakeTokens() public {
        // 投資家がステーキングした金額を取得する
        uint256 balance = stakingBalance[msg.sender];
        // 投資家がステーキングした金額が0以上であることを確認する
        require(balance > 0, "staking balance cannot be 0");
        // 偽の Dai トークンを投資家に返金する
        daiToken.transfer(msg.sender, balance);
        // 投資家のステーキング残高を0に更新する
        stakingBalance[msg.sender] = 0;
        // 投資家のステーキング状態を更新する
        isStaking[msg.sender] = false;
    }
}
