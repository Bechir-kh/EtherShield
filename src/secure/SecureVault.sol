// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SecureVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        require(msg.value > 0, "deposit required");
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        balances[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "transfer failed");
    }

    receive() external payable {}
}
