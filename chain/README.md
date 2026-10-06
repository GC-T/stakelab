# EthVault

StakeLab 的智能合约子项目。EthVault 允许用户存入和提取 ETH，
分别记录每个地址的存款余额及总存款额。

## 运行测试

从仓库根目录执行：

```powershell
cd chain
npm ci
npx hardhat test solidity
```

## 合约如何工作

- `deposit()`：从交易的 `msg.value` 取得存入金额；成功后增加调用者的金库余额 `balances[msg.sender]` 和当前存款总额 `totalDeposits`。
- `withdraw(amount)`：要求 `amount > 0` 且调用者的金库余额不少于 `amount`；减少两项记录，再把 ETH 发给 `msg.sender`。转账失败时整笔交易回滚。
- `balanceOf(address)`：返回指定地址在金库中的账面存款余额，而不是该地址的钱包 ETH 余额。

## 测试覆盖

- `test_DepositOneEther`：正常存入。
- `test_DepositZeroEther`：零金额存入失败。
- `test_WithdrawPartial`：部分金额提取。
- `test_WithdrawMoreThanBalance`：超额提取失败。
- `test_MultipleUsers`：多人余额隔离。
- `test_WithdrawZero`：零金额提取失败。
- `test_WithdrawToRejectingContract`：收款方拒收 ETH 时提取回滚。
- `test_UnfundedAddressCannotDeposit`：无资金地址携带 ETH 调用失败。
- `test_DepositedEvent`：存入事件的用户和金额。
- `test_WithdrawnEvent`：提取事件的用户和金额。


## 安全考虑与功能边界

提取时先检查条件并更新个人余额和 `totalDeposits`，最后执行外部 ETH 转账。这遵循 CEI 顺序，降低重入风险。转账失败会回滚整笔交易，个人余额、`totalDeposits` 和合约 ETH 余额均保持原值。

这是 ETH 存取金库，目前没有收益或质押功能。
