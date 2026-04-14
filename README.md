# FundChain — Web3 Crowdfunding DApp

Decentralized crowdfunding on Ethereum. Campaigns are fully on-chain: funds held in the smart contract, automatically refunded if the goal isn't met.


## Quick Start

### 1. Install dependencies

```bash
npm install
```

### 2. Set up environment variables

```bash
cp .env.example .env.local
```

Edit `.env.local`:

```env
# Alchemy or Infura RPC URL
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY

# Deployer private key (never commit this!)
PRIVATE_KEY=0xabc123...

# Treasury wallet to receive 1% platform fees
FEE_RECIPIENT=0xYourTreasuryWallet

# WalletConnect project ID (get one free at cloud.walletconnect.com)
NEXT_PUBLIC_WC_PROJECT_ID=your_project_id

# Set after deployment
NEXT_PUBLIC_CONTRACT_ADDRESS=0xYourDeployedContract

# For Etherscan verification
ETHERSCAN_API_KEY=your_etherscan_key
```

### 3. Compile the contract

```bash
npm run compile
```

### 4. Test on Sepolia first (recommended)

```bash
npm run deploy:sepolia
```

Copy the deployed address into `NEXT_PUBLIC_CONTRACT_ADDRESS`.

### 5. Deploy to Ethereum mainnet

```bash
npm run deploy:mainnet
```

### 6. Verify on Etherscan

```bash
npx hardhat verify --network mainnet 0xYourDeployedContract "0xYourFeeRecipient"
```

### 7. Run the frontend

```bash
npm run dev
# Open http://localhost:3000
```

---

## Smart Contract: Key Functions

| Function | Who | When |
|----------|-----|------|
| `createCampaign(...)` | Anyone | Creates a new campaign |
| `contribute(id)` | Anyone | Send ETH to a live campaign |
| `withdraw(id)` | Creator | After deadline, if goal met (1% fee deducted) |
| `claimRefund(id)` | Contributor | After deadline, if goal NOT met |

### Security Properties

- **Non-custodial**: Funds held only in the contract, never by a third party
- **Atomic refunds**: All refunds are pull-based (contributor calls `claimRefund`)
- **No admin keys**: No owner can pause or drain campaigns
- **Goal-or-refund**: If `raised < goal` at deadline, all contributors get 100% back
- **Reentrancy-safe**: State updated before external calls

---

## Frontend: Wagmi Hooks

```typescript
// Read campaigns
const { data } = useCampaigns(count);          // fetch all
const { data } = useCampaign(id);              // fetch one

// Write
const { contribute } = useContribute();
await contribute(campaignId, "0.5");           // send 0.5 ETH

const { create } = useCreateCampaign();
await create({ title, description, category, goalEth: "10", durationDays: 30 });

const { withdraw } = useWithdraw();
await withdraw(campaignId);                    // creator withdraws after success

const { claimRefund } = useClaimRefund();
await claimRefund(campaignId);                 // contributor refund after failure
```

---

## Customization

- **Platform fee**: Change `FEE_BPS` in `FundChain.sol` (default: 100 = 1%)
- **Max duration**: Change the 365-day cap in `createCampaign`
- **Network**: Swap `mainnet` for `polygon`, `base`, or `arbitrum` in `hardhat.config.ts` and `page.tsx`
- **Theming**: All CSS variables in `globals.css`

---

## License

MIT