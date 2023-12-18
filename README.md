## Fart Rescue

The farts could have been saved, either by using an access list or by using the method I demonstrated here.

Basically, we need to warm up the SAFE wallet address before executing our transfer.

This can be done by using an access list, or by executing the `withdrawToPurple` function from the SAFE wallet itself.

This Repo demos the second option.

## Rescue Steps

1. Transfer token ownership to the SAFE wallet
2. Queue a transaction that calls `withdrawToPurple` from the SAFE owner address
3. Execute that transaction

Results:
<img width="526" alt="Screenshot 2023-12-18 at 12 49 52 AM" src="https://github.com/z80dev/fartrescue/assets/83730246/f5a6b764-ac8e-4318-8eab-1a7decc513db">


### Run this yourself

the `foundry.toml` file already has the fork block number set up, you just need to provide an RPC endpoint when you call forge test as follows:

` forge test --fork-url <RPC_URL> --match-test testRescueFarts -vvv`
