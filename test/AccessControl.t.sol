// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {IAccessControlVault, AccessControlAttacker} from "../src/attacks/AccessControlAttacker.sol";
import {VulnerableAccessControl} from "../src/vulnerable/VulnerableAccessControl.sol";
import {SecureAccessControl} from "../src/secure/SecureAccessControl.sol";

contract AccessControlTest is Test {
    address private victim = makeAddr("victim");

    function test_UnauthorizedUserCanWithdrawFromVulnerableVault() public {
        VulnerableAccessControl vault = new VulnerableAccessControl();

        AccessControlAttacker attacker = new AccessControlAttacker(IAccessControlVault(address(vault)));

        vm.deal(victim, 10 ether);

        vm.prank(victim);
        vault.deposit{value: 10 ether}();

        attacker.attack();

        assertEq(address(vault).balance, 0);
        assertEq(address(attacker).balance, 10 ether);
    }

    function test_UnauthorizedUserCannotWithdrawFromSecureVault() public {
        SecureAccessControl vault = new SecureAccessControl();

        AccessControlAttacker attacker = new AccessControlAttacker(IAccessControlVault(address(vault)));

        vm.deal(victim, 10 ether);

        vm.prank(victim);
        vault.deposit{value: 10 ether}();

        vm.expectRevert();
        attacker.attack();

        assertEq(address(vault).balance, 10 ether);
        assertEq(address(attacker).balance, 0);
    }

    function test_OwnerCanWithdrawFromSecureVault() public {
        SecureAccessControl vault = new SecureAccessControl();

        vm.deal(victim, 10 ether);

        vm.prank(victim);
        vault.deposit{value: 10 ether}();

        uint256 ownerBalanceBefore = address(this).balance;

        vault.withdrawAll();

        uint256 ownerBalanceAfter = address(this).balance;

        assertEq(address(vault).balance, 0);
        assertEq(ownerBalanceAfter - ownerBalanceBefore, 10 ether);
    }
    receive() external payable {}
}
