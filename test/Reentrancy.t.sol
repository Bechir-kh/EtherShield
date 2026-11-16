// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IVault, ReentrancyAttacker} from "../src/attacks/ReentrancyAttacker.sol";
import {SecureVault} from "../src/secure/SecureVault.sol";
import {VulnerableVault} from "../src/vulnerable/VulnerableVault.sol";

contract ReentrancyTest is Test {
    address private victim = makeAddr("victim");

    function test_ReentrancyDrainsVulnerableVault() public {
        VulnerableVault vault = new VulnerableVault();
        ReentrancyAttacker attacker = new ReentrancyAttacker(IVault(address(vault)));

        _depositAs(IVault(address(vault)), victim, 10 ether);

        vm.deal(address(this), 1 ether);
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0);
        assertEq(address(attacker).balance, 11 ether);
        assertEq(attacker.reentrantCalls(), 10);
    }

    function test_SecureVaultRejectsReentrancy() public {
        SecureVault vault = new SecureVault();
        ReentrancyAttacker attacker = new ReentrancyAttacker(IVault(address(vault)));

        _depositAs(IVault(address(vault)), victim, 10 ether);

        vm.deal(address(this), 1 ether);
        vm.expectRevert();
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 10 ether);
        assertEq(vault.balances(address(attacker)), 0);
        assertEq(address(attacker).balance, 0);
        assertEq(attacker.reentrantCalls(), 0);
    }

    function _depositAs(IVault vault, address depositor, uint256 amount) private {
        vm.deal(depositor, amount);
        vm.prank(depositor);
        vault.deposit{value: amount}();
    }
}
