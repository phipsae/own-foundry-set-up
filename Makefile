-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --account sepoliaKey --sender 0x059e31ea8a88b62fe1603cce134ef7c1cc557395 --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-sepolia-pk:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-anvil:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url http://127.0.0.1:8545 --account defaultKey --broadcast -vvvv

run-interaction:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url http://127.0.0.1:8545  --account defaultKey   --broadcast  -vvvv