// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAndConsume(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    IAuthorizationManager public immutable authManager;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    constructor(address _authManager) {
        authManager = IAuthorizationManager(_authManager);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(
        address payable recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(address(this).balance >= amount, "Insufficient balance");

        authManager.verifyAndConsume(
            address(this),
            recipient,
            amount,
            nonce,
            signature
        );

        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "Transfer failed");

        emit Withdrawal(recipient, amount);
    }
}