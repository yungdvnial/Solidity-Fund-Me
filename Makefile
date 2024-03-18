-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

SENDER_ADDRESS := <sender's address>

fund:
	@forge script script/Interactions.s.sol:FundFundMe --sender 0x8Bd31Ba252A94F5c161908257cc205136BE1bf15 --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender 0x8Bd31Ba252A94F5c161908257cc205136BE1bf15 --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY)