// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

contract EthVault {
  mapping(address => uint) private balances;
  uint public totalDeposits;
  //增加存入、提取事件，并在操作成功后发出。
  event Deposited(address indexed user, uint amount);
  event Withdrawn(address indexed user, uint amount);

  function deposit() external payable {
    require(msg.value > 0, "Deposit must be greater than 0");
    balances[msg.sender] += msg.value;
    totalDeposits += msg.value;
    emit Deposited(msg.sender, msg.value);
  }

  function withdraw(uint256 amount) external {
    require(amount > 0, "Withdrawal must be greater than 0");
    require(balances[msg.sender] >= amount, "Insufficient balance");
    balances[msg.sender] -= amount;
    totalDeposits -= amount;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed.");
    emit Withdrawn(msg.sender, amount);
  }

  function balanceOf(address account) external view returns (uint) {
    return balances[account];
  }




}
