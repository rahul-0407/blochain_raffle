# 🎰 Raffle Lottery DApp with Chainlink VRF v2.5 & Foundry

This project is a decentralized Raffle Lottery application built using **Solidity**, **Foundry**, and **Chainlink VRF v2.5**. It ensures fair and verifiable randomness for selecting winners in a trustless environment.

---

## 📌 Features

- **Decentralized Lottery** – Users participate by paying an entrance fee.
- **Chainlink VRF v2.5** – Tamper-proof, verifiable randomness.
- **Chainlink Automation** – Automatic periodic winner selection.
- **Foundry** – Modern testing and deployment toolkit for smart contracts.

---

## 🧱 Architecture Overview


| <img src="https://www.twistedbrackets.com/content/images/size/w1200/2023/03/lottery-blockchain-flow-2.jpg" width="600"/> | <img src="https://ibb.co/HTTTt8Dk" width="200"/> |

---

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Node.js](https://nodejs.org/)
- [MetaMask](https://metamask.io/)
- Sepolia ETH and LINK test tokens

## 🛠️ Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/lottery-raffle.git
   cd lottery-raffle

2. **Install Dependencies**:
   ```bash
   forge install

3. **Build the Project**:
   ```bash
   forge build

4. **Configure Environment**:
   ```bash
   PRIVATE_KEY=your_private_key
   RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
   ETHERSCAN_API_KEY=your_etherscan_key

5. **Deploy Contracts**:
   ```bash
   forge script script/DeployRaffle.s.sol --rpc-url $RPC_URL --broadcast --verify -vvvv

6. **Create and Fund VRF Subscription**:
   ```bash
   forge script script/CreateSubscription.s.sol --rpc-url $RPC_URL --broadcast -vvvv
   forge script script/FundSubscription.s.sol --rpc-url $RPC_URL --broadcast -vvvv

7. **Add Consumer to Subscription**:
   ```bash
   forge script script/AddConsumer.s.sol --rpc-url $RPC_URL --broadcast -vvvv
   
## 🔄 How It Works

### User enters the raffle by calling enterRaffle() and sending ETH.

### Chainlink Automation checks every interval (e.g. 30 seconds) to see if conditions are met:

- Time interval has passed  
- At least 1 participant  
- ETH in contract  
- Raffle state is open  

### If yes, Automation triggers performUpkeep(), which calls Chainlink VRF to request randomness.

### VRF responds via fulfillRandomWords(), which:

- Picks a random winner from the players  
- Sends them the ETH  
- Resets the lottery  

  
## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
