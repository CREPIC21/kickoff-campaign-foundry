# Decentralized Crowdfunding Platform

This Solidity project introduces a decentralized crowdfunding platform powered by smart contracts on the Ethereum blockchain and it is part of learning Solidity and blockchain technologies path. It is the same project as [KickoffCampaign](https://github.com/CREPIC21/kickoff-campaign). The difference is that here we are using Foundry as a development and testing environment to test/interact with the smart contracts, as well some new Solidity features such as:
- custom errors
- modifiers
- reverts instead of requires
- events

Project consists of two primary smart contracts: Factory Campaign Contract and individual Campaign Contract where the Factory Campaign Contract facilitates the deployment of new Campaign Contracts.

## Key Features

### 1. Campaign Contract

The Campaign Contract is the heart of the platform and serves as a crowdfunding campaign for various projects. Its core features include:

- **Project Creation**: Users can create online campaigns for the projects they want to execute.

- **Funding**: Individuals interested in supporting these projects can donate or invest money directly into the campaign's contract address.

- **Request Creation**: The campaign owner can create expenditure requests, specifying the purpose and amount. These requests are subject to approval by contributors.

- **Request Voting**: Contributors have the power to vote on expenditure requests, deciding whether the owner can spend money on the specified project-related expenses.

- **Finalization**: Once a request receives a majority of favorable votes, the request is finalized, and the owner can execute the expenditure.

### 2. Factory Campaign Contract

The Factory Campaign Contract allows users to create new Campaign Contracts, each corresponding to a distinct project or fundraising campaign. It streamlines the deployment process and ensures the creation of isolated crowdfunding environments for different projects.

## How It Works

1. Users deploy a individual Campaign Contracts for their specific projects. New Campaign Contracts is deployed by Factory Campaign Contract functionality.

2. The owner of the campaign can draft and submit expenditure requests, outlining how funds will be used for the project.

3. Contributors vote on expenditure requests, democratically deciding whether the project owner can spend funds as proposed.

4. Upon receiving a majority of favorable votes, the request is finalized and the owner can execute the expenditure according to the project plan.

## Getting Started

To get started with this decentralized crowdfunding platform, you'll need:

1. Foundry environment set up for Ethereum smart contract testing and development.

2. Access to an Ethereum wallet, like MetaMask, for interacting with the contracts.

3. The project's Solidity smart contract source code.

## Usage

### Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - run `git --version` for confirmation
- [foundry](https://getfoundry.sh/)
  - run `forge --version` for confirmation

### Quickstart
```shell
git clone https://github.com/CREPIC21/kickoff-campaign-foundry
cd kickoff-campaign-foundry
forge build
```

### Deploy

```shell
forge script script/DeployCampaign.s.sol
```
```shell
forge script script/DeployCampaignFactory.s.sol
```

### Testing
```shell
forge test
```

or 

```shell
forge test --match-test testFunctionName
```

or

```shell
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```shell
forge coverage
```

# Testnet or Mainnet Deployment

1. Setup environment variables in .env file
- `SEPOLIA_RPC_URL`
  - URL of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)
- `PRIVATE_KEY`
  - private key of your account, for example from [etamask](https://metamask.io/)
- `ETHERSCAN_API_KEY`
  - to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH
- [faucets.chain.link](https://faucets.chain.link/)

3. Deploy
```shell
forge script script/DeployCampaign.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

```shell
forge script script/DeployCampaignFactory.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

## Scripts

After deploying to a testnet or local net, you can run the scripts seperatly.

Using cast deployed locally example: 

```shell
cast send <CONTRACT_ADDRESS> "contribute()" --value 0.1ether --private-key <PRIVATE_KEY>
```

## Estimate gas

You can estimate how much gas things cost by running:

```shell
forge snapshot
```

And you'll see an output file called `.gas-snapshot`


# Formatting


To run code formatting:
```shell
forge fmt
```