# Birthday Wonder Trade

A contract to implement a Pokémon wonder trade-like experience for Macci's birthday card NFT collection

## Deployement

require [ape framework](https://docs.apeworx.io/ape/stable/userguides/quickstart.html) and [foundry]()

Clone the repository and navigate into the repository folder.

Install the required ape plugin.
```
ape plugin install .
```

Compile the contract.
```
ape compile
```

Perform the tests.
```
ape test --network :mainnet-fork:foundry
```

Deploy it in a fork.
```
ape script deploy.py --network :mainnet-fork:foundry
```

Deploy it for real.
```
ape script deploy.py --network :mainnet:node
```
