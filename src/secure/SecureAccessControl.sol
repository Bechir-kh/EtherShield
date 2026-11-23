// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SecureAccessControl {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit required");
    }

    function withdrawAll() external onlyOwner {
        uint256 amount = address(this).balance;

        require(amount > 0, "Vault is empty");

        (bool success,) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}
