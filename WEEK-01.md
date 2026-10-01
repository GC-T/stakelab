# 第 1 周：钱包连接与链上读取（已验收）

## 当周目标

把 StakeLab 从空项目推进到可运行的钱包页面：连接浏览器钱包，识别以太坊 Sepolia 网络，读取测试网 ETH 余额，并完成地址缩写与复制功能。重点是理解前端如何使用钱包配置和链上读取结果，而不只是让页面显示出来。

## 任务与完成情况

- [x] 在本地启动项目，运行 `npm run build`。
- [x] 使用 Phantom 测试账户验证连接、断开和重新连接。
- [x] 确认页面显示以太坊 Sepolia、正确地址及零余额。
- [x] 将地址显示为短格式；复制按钮复制完整原始地址，提供成功或失败提示。
- [x] 用自己的话说明 `src/config.ts`、`src/main.tsx`、`src/App.tsx` 的职责及配合方式。

## 验收证据

- [初始钱包页面提交](https://github.com/GC-T/stakelab/commit/18496b9)
- [地址复制与 Sepolia 调整提交](https://github.com/GC-T/stakelab/commit/727872d)
- [第一周验收记录提交](https://github.com/GC-T/stakelab/commit/9c50176)

验收时已确认：Phantom 可以手动连接和断开；页面显示 Sepolia，余额为 0；复制得到完整地址。当前仓库公开可查看。第一周没有部署合约，也没有完成存取交易，这些属于后续里程碑。

## 下一步

第 2 周不重复钱包演示，转向 Solidity 存取逻辑和自动化测试。见 [WEEK-02.md](./WEEK-02.md)。
