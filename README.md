# Foundry Raffle-DApp

# Usage

## Start a local node

```
make anvil
```

## Deploy

This will default to your local node. You need to have it running in another terminal in order for it to deploy.

```
make deploy
```
## Testing

```
forge test
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```
forge coverage
```

# Deployment to a testnet or mainnet

1. Setup environment variables
2. Get testnet ETH 
3. Deploy
4. Chainlink Automation Upkeep

## Scripts

deployed locally:

```
cast send <RAFFLE_CONTRACT_ADDRESS> "enterRaffle()" --value 0.1ether --private-key <PRIVATE_KEY> --rpc-url $RPC_URL
```


## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```


# Formatting

To run code formatting:

```
forge fmt
```