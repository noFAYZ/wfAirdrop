# ETH/MATIC (EVM) Airdrop Smart contract and Server to generate Holder's list and Airdrop them ETH/Matic to their wallets.

### Features

#### Server:
- Generate Complete list of unique NFT holders of a collection on EVM based Chains.
(Endpoint: https://yourdomain.com/getHoldersAddresses) JSON output.

- Generate Complete list of amount of NFTs held by holders of a collection. (Sorted according to the holders list)
(Endpoint: https://yourdomain.com/getHoldersAmount) JSON output.

#### Smart Contract:
- ***addHolders(address[], amounts[])* ** => Admin can add NFT Holders to the smart contract using this function limit is 250.

-  ***airDropAmounts()*** => Admin/Chainlink automation can use this function to airdrop tokens(ETH/MATIC) availavble in Smart Contract to list of addresses **according to no. of NFTs they hold**. Equally.

- *** airDrop(address[])*** => Admin/Chainlink automation can use this function to airdrop tokens(ETH/MATIC) available in Smart Contract to list of addresses provided in the function equally.



**Table of Contents**

[TOCM]

### Setup Server:

#### 1- Edit Variables
Go to `/index.js`

On line no# 20-23

    const MORALIS_API_KEY = "Enter your Moralis API Key"
    const address = "Enter Contract Address of Your Collection"
    const chain = EvmChain.{Enter Chain i.e POLYGON, MUMBAI. etc}
    const total = {Enter Total no. of NFTs in collection i.e 5000};

#### 2- Create Google storage bucket
Setup Google storage and create a bucket named **"hwmc"**

#### 3- Install dependencies
`yarn` & `yarn start`


### Setup Smart Contract:

#### 1- Deploy
Go to `Remix IDE` (https://remix.ethereum.org/).

1- Copy the contarct from `/airdropnew.sol`

2- Connect your Metamask wallet and select desired network.

3- Deploy.

#### 2- Verify Smart Contract

In Remix IDE activate the ***Flattner*** plugin and flatten the Contract.
Headover to the blockchain explorer i.e. mumbai.polygonscan.org etc 
and Verify according to the parameters you deployed.

#### 3- Chainlink Automation

Go to Chain Link Automation App. (https://automation.chain.link/)

1- Connect Wallet & Register a new Upkeep.

2- Select `Time based` & enter the deployed Contarct address.

3- In Contract Call select ***airDropAmounts()***

4- In Cron expresson write the time logic according to your requriements.

Example: https://crontab.guru/

