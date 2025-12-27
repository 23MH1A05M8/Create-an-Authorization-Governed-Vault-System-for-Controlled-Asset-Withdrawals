// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AuthorizationManager {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address public immutable signer;
    mapping(bytes32 => bool) public consumed;

    event AuthorizationConsumed(bytes32 indexed authorizationHash);

    constructor(address _signer) {
        require(_signer != address(0), "Invalid signer");
        signer = _signer;
    }

    function verifyAndConsume(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool) {
        bytes32 authHash = keccak256(
            abi.encode(vault, block.chainid, recipient, amount, nonce)
        );

        require(!consumed[authHash], "Authorization already used");

        address recovered =
            authHash.toEthSignedMessageHash().recover(signature);

        require(recovered == signer, "Invalid signature");

        consumed[authHash] = true;
        emit AuthorizationConsumed(authHash);
        return true;
    }
}