// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VulnerableAccessControl {
    function deposit() external payable {
        require(msg.value > 0, "Deposit required");
    }

    function withdrawAll() external {
        uint256 amount = address(this).balance;

        require(amount > 0, "Vault is empty");

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}
