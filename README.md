# Burner Contracts

a burner contract is a contract that can only execute once.

you can send assets to an address that looks like an EOA but is actually a yet-to-be-deployed contract. nobody holds a private key to the burner address.

the address can be derived by predetermined parameters of the burner contract bytecode, constructor parameters & salt (and deployer, which can be the fixed Create3 contract) so a party can commit to a specific transaction (ie. the burner contract) and verify it offchain before it is deployed onchain.

```sh
> forge test -vvv

Ran 1 test for test/Burner.t.sol:BurnerTest
[PASS] test_Burner() (gas: 1056945762)
Logs:
  burner params:
  |- salt              = 0xcafebabe
  |- bytecodeHash      = 0x55c4db97882ce1d442c232a6a53baf910eaa3615e8d2a6dccd8be31e962c388c
  |- deployer          = 0xc9C7DbFaBc3aF9E7FD10549590E7e294bc82982C
  |-----------------
  |- callback address  = 0xD355bE26336bb61424B18e31e07B62D3597Ff80C
  |- callback data     = onBurn(uint256(0x1), uint256(0x2))
  \_ burner contract   = 0x2BF806BD73dF19e172FBE0a03eDDfE5d515ecA6C

  onBurn() called:
  |- burner deployer   = 0xc9C7DbFaBc3aF9E7FD10549590E7e294bc82982C
  |- burner contract   = 0x2BF806BD73dF19e172FBE0a03eDDfE5d515ecA6C
  \_ data length       = 64

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 966.80µs (542.70µs CPU time)

Ran 1 test suite in 8.75ms (966.80µs CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

see [lightBurner function in Burner.t.sol](test/Burner.t.sol#L24)
