STXUSD Smart Contract  
**A Decentralized STX-Backed Stablecoin on the Stacks Blockchain**

---

Overview
**STXUSD** is a **decentralized stablecoin** fully backed by **STX collateral** and governed by smart contract logic on the **Stacks blockchain**.  
It allows users to **mint**, **redeem**, and **maintain peg stability** without intermediaries — ensuring transparency, security, and decentralization.

The goal of STXUSD is to bring **on-chain liquidity and stable value** to the Stacks ecosystem by leveraging the native STX token as collateral.

---

Core Features

- **Collateralized Minting** – Lock STX to mint STXUSD tokens at a defined collateral ratio.  
- **Redemption Mechanism** – Redeem STXUSD for STX by burning tokens.  
- **Stability Enforcement** – Prevents under-collateralization and maintains a stable peg.  
- **Trustless & Transparent** – No intermediaries; all transactions are verifiable on-chain.  
- **On-Chain Ledger** – Tracks all mint, burn, and collateral events.

---

Contract Architecture

| Component | Description |
|------------|--------------|
| `mint-tokens` | Allows users to lock STX as collateral to mint STXUSD tokens. |
| `redeem-tokens` | Enables token holders to burn STXUSD in exchange for STX collateral. |
| `liquidate` | Handles liquidation of under-collateralized positions. |
| `get-collateral-ratio` | Returns the current collateral-to-debt ratio for a given user. |
| `get-user-balance` | Checks the minted STXUSD and collateral balance. |

---

Technical Details

- **Language:** [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview)  
- **Framework:** [Clarinet](https://github.com/hirosystems/clarinet)  
- **Network:** Stacks Blockchain (Layer-2 on Bitcoin)  
- **Contract Type:** STX-Backed Stablecoin System  
- **Token Standard:** SIP-010 Compatible  

---

Getting Started

Prerequisites
Ensure you have the following installed:
- [Clarinet](https://docs.hiro.so/clarinet/getting-started)
- [Node.js](https://nodejs.org/)
- [Stacks Wallet](https://wallet.hiro.so/)

Clone the Repository
```bash
git clone https://github.com/<your-username>/stxusd.git
cd stxusd
