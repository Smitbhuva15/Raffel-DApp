-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil deploy-local

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy-local      - Deploy contracts to local anvil network"
	@echo "  make deploy-sepolia    - Deploy contracts to Sepolia testnet"
	@echo "  make fund              - Fund deployed contracts if needed"
	@echo "  make anvil             - Start local Anvil node"

	# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install transmissions11/solmate@v6 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1



deploy-local:
	@forge script script/DeployRaffel.s.sol:DeployRaffel --broadcast --rpc-url http://127.0.0.1:8545 --private-key $(DEFAULT_ANVIL_KEY)

deploy-sepolia:
	@forge script script/DeployRaffel.s.sol:DeployRaffel  --private-key $(PRIVATE_KEY) --rpc-url $(SEPOLIA_URL) --broadcast


createSubscription:
	@forge script script/Interactions.s.sol:CreateSubscription $(NETWORK_ARGS)

addConsumer:
	@forge script script/Interactions.s.sol:AddConsumer $(NETWORK_ARGS)

fundSubscription:
	@forge script script/Interactions.s.sol:FundSubscription $(NETWORK_ARGS)