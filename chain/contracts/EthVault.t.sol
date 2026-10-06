// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {EthVault} from "./EthVault.sol";

contract RejectEther {
    EthVault vault;

    constructor(EthVault _vault) {
        vault = _vault;
    }

    receive() external payable {
        revert("Rejecting ETH");
    }

    function deposit() external payable {
        vault.deposit{value: msg.value}();
    }

    function withdraw(uint256 amount) external {
        vault.withdraw(amount);
    }
}

contract EthVaultTest is Test {
    EthVault vault;
    address alice = address(0xA11CE);

    function setUp() public {
        vault = new EthVault();
        vm.deal(alice, 3 ether);
    }

    function test_DepositOneEther() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);

    }
    function test_DepositZeroEther() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.deposit();
        assertEq(vault.balanceOf(alice), 0);
        assertEq(vault.totalDeposits(), 0);
        assertEq(address(vault).balance, 0);
    }

    // Alice deposits 1 ether, then withdraws 0.4 ether.
    function test_WithdrawPartial() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);

        vm.prank(alice);
        vault.withdraw(0.4 ether);
        assertEq(vault.balanceOf(alice), 0.6 ether);
        assertEq(vault.totalDeposits(), 0.6 ether);
        assertEq(address(vault).balance, 0.6 ether);
        assertEq(address(alice).balance, 2.4 ether);
    }

    function test_WithdrawMoreThanBalance() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);

        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        vault.withdraw(1.1 ether);
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);
    }

    // Fund Bob with test ETH. Alice deposits 1 ETH and Bob deposits 0.5 ETH.
    // Verify their balances and the vault total, then reject Bob's 1 ETH withdrawal.
    function test_MultipleUsers() public {
        address bob = address(0xB0B);
        vm.deal(bob, 2 ether);

        // Alice deposits 1 ether
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);

        // Bob deposits 0.5 ether
        vm.prank(bob);
        vault.deposit{value: 0.5 ether}();
        assertEq(vault.balanceOf(bob), 0.5 ether);
        assertEq(vault.totalDeposits(), 1.5 ether);
        assertEq(address(vault).balance, 1.5 ether);

        // Bob tries to withdraw 1 ether (should revert)
        vm.prank(bob);
        vm.expectRevert("Insufficient balance");
        vault.withdraw(1 ether);

        // Verify balances remain unchanged
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.balanceOf(bob), 0.5 ether);
        assertEq(vault.totalDeposits(), 1.5 ether);
        assertEq(address(vault).balance, 1.5 ether);
    }

    // Alice deposits 1 ETH. A zero withdrawal reverts and all balances stay unchanged.
    function test_WithdrawZero() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);

        vm.prank(alice);
        vm.expectRevert("Withdrawal must be greater than 0");
        vault.withdraw(0);
        assertEq(vault.balanceOf(alice), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);
    }

    // A helper contract rejects ETH in receive(). Its failed withdrawal must
    // preserve its deposit record, totalDeposits, and the vault's ETH balance.
    function test_WithdrawToRejectingContract() public {
        RejectEther rejectingContract = new RejectEther(vault);

        // Alice funds the helper, which deposits under its own address.
        vm.prank(alice);
        rejectingContract.deposit{value: 1 ether}();
        assertEq(vault.balanceOf(address(rejectingContract)), 1 ether);

        vm.expectRevert("Transfer failed.");
        rejectingContract.withdraw(1 ether);

        // Verify balances remain unchanged
        assertEq(vault.totalDeposits(), 1 ether);
        assertEq(address(vault).balance, 1 ether);
        assertEq(address(alice).balance, 2 ether);
        //Verify balanceOf(rejectingContract) remain 1 ether
        assertEq(vault.balanceOf(address(rejectingContract)), 1 ether);
    }

    function test_UnfundedAddressCannotDeposit() public {
        RejectEther rejectingContract = new RejectEther(vault);
        assertEq(address(rejectingContract).balance, 0);

        vm.prank(address(rejectingContract));
        (bool success, ) = address(rejectingContract).call{value: 1 ether}(
            abi.encodeWithSignature("deposit()")
        );
        assertFalse(success);
        assertEq(vault.balanceOf(address(rejectingContract)), 0);
        assertEq(vault.totalDeposits(), 0);
    }

    // Verify that the Deposited event contains Alice's address and 1 ether in the "Deposit 1 ETH" test
    function test_DepositedEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposited(alice, 1 ether);
        vault.deposit{value: 1 ether}();
    }

    //Verify that the Withdrawn event contains Alice's address and 1 ether in the "Withdraw 1 ETH" test
    function test_WithdrawnEvent() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit EthVault.Withdrawn(alice, 1 ether);
        vault.withdraw(1 ether);
    }

}
