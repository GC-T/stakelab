import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { parseEther } from "viem";

describe("EthVault", async function () {
    const { viem } = await network.create();
    const publicClient = await viem.getPublicClient();
    const [alice, bob]  = await viem.getWalletClients();


  it("Alice deposits 1 ETH, Bob deposit 0.5 ETH, Alice withdraw 0.4 ETH", async function () {
    const vault = await viem.deployContract("EthVault");
    await vault.write.deposit({
        account: alice.account,
        value: 1n * 10n ** 18n, // 1 ETH in wei
    });
    assert.equal(await vault.read.balanceOf([alice.account.address]), 1n * 10n ** 18n);
    assert.equal(await vault.read.balanceOf([bob.account.address]), 0n);
    assert.equal(await vault.read.totalDeposits(), 1n * 10n ** 18n);

    //let's have Bob deposit 0.5 ETH in the same test, and then verify that Alice has 1 ETH, Bob has 0.5 ETH,
    // and totalDeposits and the actual contract balance are both 1.5 ETH. You can use parseEther("0.5") to convert decimal amounts to precise wei.
    await vault.write.deposit({
        account: bob.account,
        value: parseEther("0.5"),
    });
    assert.equal(await vault.read.balanceOf([alice.account.address]), 1n * 10n ** 18n);
    assert.equal(await vault.read.balanceOf([bob.account.address]), parseEther("0.5"));
    assert.equal(await vault.read.totalDeposits(), parseEther("1.5"));
    assert.equal(await publicClient.getBalance({ address: vault.address }), parseEther("1.5"));

    //let's have Alice withdraw 0.4 ETH, and then assert that Alice has 0.6 ETH, Bob has 0.5 ETH, and totalDeposits and the actual contract balance are both 1.1 ETH.
    //save the transaction hash returned by withdraw() to hash
    const hash = await vault.write.withdraw([parseEther("0.4")],{
        account: alice.account
    });
    //let's assert that the receipt.status is "success".
    //assert.equal(receipt.status, "success");
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    assert.equal(receipt.status, "success");

    assert.equal(await vault.read.balanceOf([alice.account.address]), parseEther("0.6"));
    assert.equal(await vault.read.balanceOf([bob.account.address]), parseEther("0.5"));
    assert.equal(await vault.read.totalDeposits(), parseEther("1.1"));
    assert.equal(await publicClient.getBalance({ address: vault.address }), parseEther("1.1"));

    });
});
