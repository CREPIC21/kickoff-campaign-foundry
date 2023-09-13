# In the context of Solidity, a Makefile is used to automate tasks related to the development and deployment of Ethereum smart contracts written in Solidity. 
# It provides a convenient way to streamline common development tasks, such as compiling Solidity code, deploying contracts to an Ethereum network, running tests, and more
# installing make: sudo apt install make

-include .env

.PHONY: all test deploy

build:; forge build
test:; forge test
deploy-factory-sepolia:; forge script script/DeployCampaignFactory.s.sol:DeployCampaignFactory --rpc-url $(SEPOLIA_ALCHEMY_RPC_URL) --private-key $(METAMASK_SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
deploy-factory-anvil:; forge script script//DeployCampaignFactory.s.sol:DeployCampaignFactory --rpc-url $(ANVILE_RPC_URL) --private-key $(ANVILE_PRIVATE_KEY)  --broadcast -vvvv
deploy-campaign-sepolia:; forge script script/DeployCampaignFactory.s.sol:DeployCampaignFactory --rpc-url $(SEPOLIA_ALCHEMY_RPC_URL) --private-key $(METAMASK_SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
deploy-campaign-anvil:; forge script script//DeployCampaignFactory.s.sol:DeployCampaignFactory --rpc-url $(ANVILE_RPC_URL) --private-key $(ANVILE_PRIVATE_KEY)  --broadcast -vvvv