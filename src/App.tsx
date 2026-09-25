import { useBalance, useConnect, useConnection, useConnectors, useDisconnect, useSwitchChain } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'
import { formatUnits } from 'viem'

export function App() {
  const connection = useConnection()
  const connectors = useConnectors()
  const { connect, error: connectError, isPending } = useConnect()
  const { disconnect } = useDisconnect()
  const { switchChain, isPending: isSwitching } = useSwitchChain()
  const balance = useBalance({
    address: connection.address,
    chainId: baseSepolia.id,
    query: { enabled: connection.isConnected && connection.chainId === baseSepolia.id },
  })
  const onTargetChain = connection.chainId === baseSepolia.id

  return (
    <main className="shell">
      <header className="header">
        <div className="brand"><span className="brand-mark">S</span><span>StakeLab</span></div>
        <span className="network">Base Sepolia · 测试网</span>
      </header>

      <section className="hero">
        <div>
          <p className="eyebrow">WEB3 PORTFOLIO PROJECT · MILESTONE 01</p>
          <h1>从连接钱包开始，<br />做出可交付的链上应用。</h1>
          <p className="intro">这是质押管理台的第一步：识别钱包、确认网络并读取测试网余额。下一阶段会加入独立编写的质押合约和完整交易流程。</p>
        </div>
        <div className="milestone"><strong>01 / 04</strong><span>钱包连接与链上读取</span><div className="progress"><i /></div></div>
      </section>

      <section className="grid" aria-label="项目状态">
        <article className="card wallet-card">
          <div className="card-heading"><span>钱包状态</span><span className={connection.isConnected ? 'pill success' : 'pill'}>{connection.isConnected ? '已连接' : '未连接'}</span></div>
          {connection.isConnected ? (
            <>
              <p className="label">当前地址</p>
              <p className="address">{connection.address}</p>
              <p className="label">当前网络</p>
              <p className="value">{connection.chain?.name ?? `Chain ID ${connection.chainId}`}</p>
              {!onTargetChain && <p className="notice">请切换到 Base Sepolia，才能读取本项目的测试网数据。</p>}
              <div className="actions">
                {!onTargetChain && <button onClick={() => switchChain({ chainId: baseSepolia.id })} disabled={isSwitching}>{isSwitching ? '切换中…' : '切换到测试网'}</button>}
                <button className="secondary" onClick={() => disconnect()}>断开连接</button>
              </div>
            </>
          ) : (
            <>
              <p className="muted">连接浏览器钱包后，这里会显示地址、网络和测试网余额。</p>
              {connectors.map((connector) => <button key={connector.uid} onClick={() => connect({ connector })} disabled={isPending}>{isPending ? '连接中…' : `连接 ${connector.name}`}</button>)}
              {connectors.length === 0 && <p className="notice">未检测到浏览器钱包。请先安装支持 EVM 的钱包扩展。</p>}
              {connectError && <p className="notice">连接失败：{connectError.message}</p>}
            </>
          )}
        </article>

        <article className="card balance-card">
          <div className="card-heading"><span>测试网余额</span><span className="dot" /></div>
          <p className="balance">{balance.data ? Number(formatUnits(balance.data.value, balance.data.decimals)).toFixed(4) : '—'} <small>ETH</small></p>
          <p className="muted">{!connection.isConnected ? '连接钱包后读取' : !onTargetChain ? '请先切换网络' : balance.isPending ? '正在读取链上数据…' : balance.isError ? '读取失败，请稍后重试' : '数据来自 Base Sepolia 测试网'}</p>
          {connection.address && <a href={`${baseSepolia.blockExplorers.default.url}/address/${connection.address}`} target="_blank" rel="noreferrer">在区块浏览器查看 ↗</a>}
        </article>
      </section>

      <section className="next"><span>下一阶段</span><strong>质押合约 · 存入与提取 · 交易反馈 · 测试与部署</strong></section>
      <footer>仅供学习与作品展示 · 不接入真实资金</footer>
    </main>
  )
}
