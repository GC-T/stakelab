# 第 2 周：ETH 存取合约与测试（2026-09-28 至 10-04）

**状态：代码交付已完成，个人讲解与岗位对照待验收。** 原计划每周投入 9–12 小时；以下按 2026-10-06 的仓库状态记录，不把未展示的能力标成已完成。

## 本周目标

独立说明并实现一个最小 ETH 存取金库：每个地址单独记账；存取时维护 `totalDeposits`；失败时全部状态回滚。它是 Web3 全栈作品的合约层，不是带收益的质押协议。

## 已完成的交付

- [x] 在独立的 `chain/` 初始化 Hardhat 3，保留原有 `src/` 前端配置。
- [x] 在 `chain/contracts/EthVault.sol` 实现 `deposit()`、`withdraw(uint256)`、`balanceOf(address)`、`totalDeposits` 和存取事件。
- [x] 明确零金额、超额提取、多人记账和拒收 ETH 时的行为；提取先改账再转账，转账失败则回滚。
- [x] 在 `chain/contracts/EthVault.t.sol` 编写 10 项 EthVault 测试，包括拒收 ETH 的辅助合约。
- [x] 在 `chain/README.md` 记录运行方式、账本含义、安全考虑和功能边界。
- [x] 检查并提交 `chain/` 到 GitHub：[合约与测试提交](https://github.com/GC-T/stakelab/commit/2a261dd14f9dcd2263fc4312254d601b6e64dc30)。

## 可复现的证据

从仓库根目录运行：

```powershell
cd chain
npm ci
npx hardhat test
npx hardhat build
npx tsc --noEmit
cd ..
npm run build
```

2026-10-06 已在当前环境验证：Hardhat **15 项测试通过**（EthVault 10 项、初始化示例 5 项）；合约构建、`chain/` TypeScript 类型检查和前端构建通过。`Counter` 是 Hardhat 初始化示例，不应算作 EthVault 的功能或测试覆盖。

## 尚待亲自完成的训练验收

- [ ] 不看代码，画出 `Alice → deposit(1 ETH) → withdraw(0.4 ETH)` 的四项变化：Alice 钱包余额、`balanceOf(Alice)`、`totalDeposits`、合约实际 ETH 余额。说明 gas 与账本金额的区别。
- [ ] 用自己的话解释 `msg.value`、`msg.sender`、事件、CEI，以及为什么“先改账再转账”不能被描述为绝对防止所有重入问题。
- [ ] 用 3 分钟讲清一项失败测试：触发条件、预期回滚、三个关键断言和最初遇到的错误。
- [ ] 找 3 条**当前仍可打开**的海外远程 Web3 前端/合约集成任务，记录链接、任务范围、要求和自己目前的证据差距；不要把高级全栈岗位当作本周可投递目标。
- [ ] 写 100–150 词英文项目简介，准确使用 *ETH deposit and withdrawal vault*，不要宣称 staking rewards、audit 或 production ready。

这些项目未完成前，第 2 周的“代码交付”成立，“能向客户独立解释交付”仍待验收。第 3 周继续使用同一个 EthVault，把合约接到页面并形成可演示的完整流程，见 [WEEK-03.md](./WEEK-03.md)。
