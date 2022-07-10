# Rollette-Simple-Contract

Simple contract, in which you can add money and finally the owner "spins" the rollette and the winner is chosen randomly.

# Set up

Install dependencies:

1. Yarn

```bash
yarn
```

2. Npm

```bash
npm install
```

# Deployment

Use deploy/index.js for contract deployment:

```bash
node deploy/index.js
```

# Compile

Use yarn script commant to compile the contract and get `.abi` and `.bin` files:

```bash
yarn compile ./contracts/Rollette.sol --output-dir ./compiled
```
