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


### Run this yourself

the `foundry.toml` file already has the fork block number set up, you just need to provide an RPC endpoint when you call forge test as follows:

` forge test --fork-url <RPC_URL> --match-test testRescueFarts -vvv`
