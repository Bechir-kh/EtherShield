// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        require(msg.value > 0, "deposit required");
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "transfer failed");

        balances[msg.sender] = 0;
    }

    receive() external payable {}
}
