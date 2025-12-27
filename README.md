# Authorization-Governed Vault System

This project implements a secure ETH vault where withdrawals are only allowed
if authorized by an off-chain signer. Each authorization can be used exactly once.

---

## Architecture Overview

- **AuthorizationManager**
  - Verifies ECDSA signatures
  - Prevents replay attacks using a consumed-hash registry

- **SecureVault**
  - Holds ETH
  - Allows withdrawals only after successful authorization verification

---

## Local Deployment

The system is deployed locally using Docker and Hardhat.

### Start the system

```bash
docker compose build --no-cache
docker compose up
```

This starts:
- A local Hardhat blockchain
- Deploys AuthorizationManager
- Deploys SecureVault
- Prints deployed contract addresses

---

## Authorization Flow (Manual Validation)

### Step 1: Authorization Creation (Off-chain)

An off-chain trusted signer creates an authorization by signing the following data:

```
keccak256(
  abi.encode(
    vaultAddress,
    chainId,
    recipient,
    amount,
    nonce
  )
)
```

This hash is signed using the signer's private key (ECDSA).

---

### Step 2: Withdrawal Request (On-chain)

Anyone can call `withdraw()` on the SecureVault contract:

```solidity
withdraw(
  recipient,
  amount,
  nonce,
  signature
)
```

---

### Step 3: Verification & Consumption

Inside the withdrawal process:

1. SecureVault calls AuthorizationManager
2. AuthorizationManager:
   - Reconstructs the authorization hash
   - Recovers the signer from the signature
   - Confirms signer matches the trusted signer
   - Ensures the authorization was not used before
   - Marks the authorization as consumed

---

### Step 4: Successful Withdrawal

If verification succeeds:
- ETH is transferred to the recipient
- The authorization cannot be reused

---

## Failure Scenarios (Verified Manually)

###  Replayed Authorization
- Using the same signature twice
- Rejected due to consumed authorization hash

###  Invalid Signature
- Signature not created by trusted signer
- Rejected during ECDSA recovery

###  Insufficient Vault Balance
- Withdrawal amount exceeds vault balance
- Rejected by SecureVault

---

## Security Properties

- Replay protection via consumed hashes
- Off-chain authorization
- On-chain enforcement
- No privileged withdrawal functions
- Deterministic deployment