# Burner Contracts

a burner contract is a contract that can only execute once.

you can send assets to an address that looks like an EOA but is actually a yet-to-be-deployed contract. nobody holds a private key to the burner address.

the address can be derived by predetermined parameters of the burner contract bytecode, constructor parameters & salt (and deployer, which can be the fixed Create3 contract) so a party can commit to a specific transaction (ie. the burner contract) and verify it offchain before it is deployed onchain.

```sh
> forge test -vvv

[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/Burner.t.sol:BurnerTest
[PASS] test_Burner() (gas: 73671)
Logs:
  burner deployer address: 0xc9C7DbFaBc3aF9E7FD10549590E7e294bc82982C
  burner target address: 0xD355bE26336bb61424B18e31e07B62D3597Ff80C
  onBurn() called from 0xc9C7DbFaBc3aF9E7FD10549590E7e294bc82982C with 64 bytes of additional data
  burner deployed at: 0x61cdCA5d8119C630356a9734ff2da9580908a1f4

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 948.50µs (416.60µs CPU time)

Ran 1 test suite in 6.99ms (948.50µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

see [lightBurner function in Burner.t.sol](test/Burner.t.sol#L24)
