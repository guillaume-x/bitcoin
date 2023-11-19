# Bitcoin / BIP39 - Mnemonic code

script.rb calculate the last word (checksum) and show the 8 possibilities

## Test set

Mnemonic words - 23 first words list :

```txt
bonus critic meadow soft business adult shiver sail shaft cotton turtle myth midnight term major rice execute harbor select debris claw spin chaos
```

testing

```bash
ruby script.rb bonus critic meadow soft business adult shiver sail shaft cotton turtle myth midnight term major rice execute harbor select debris claw spin chaos
```

result

```txt
["axis", "capable", "excite", "keep", "middle", "romance", "slice", "tree"]
```

## References

* [https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki]
* [https://github.com/bitcoin/bips/blob/master/bip-0039/english.txt]
* [https://iancoleman.io/bip39/]