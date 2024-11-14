# Burner Contracts

a burner contract is a contract that can only execute once.

you can send assets to an address that looks like an EOA but is actually a yet-to-be-deployed contract. nobody holds a private key to the burner address.

the address can be derived by predetermined parameters of the burner contract bytecode, constructor parameters & salt (and deployer, which can be the fixed Create3 contract) so a party can commit to a specific transaction (ie. the burner contract) and verify it offchain before it is deployed onchain.
