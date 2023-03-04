# Chronicle Std Library • [![Unit Tests](https://github.com/chronicleprotocol/chronicle-std/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/chronicleprotocol/chronicle-std/actions/workflows/unit-tests.yml) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

The `Chronicle Std Library` provides a set of contracts used throughout the _Chronicle Protocol_.

## Contracts

```ml
auth
├─ Auth — "`auth` access control module"
├─ IAuth — "Auth's interface specification"
toll
├─ Toll — "`toll` access control module"
├─ IToll — "Toll's interface specification"
configurable
├─ Configurable — "File pattern module providing value configurability"
├─ IConfigurable — "Configurable's interface specification"
chaincheck
├─ ChaincheckTest — "`chaincheck` integration test specification"
```

## Installation

Install module via Foundry:
```bash
$ forge install chronicleprotocol/chronicle-std@v0.1
```

## Contributing

The project uses the Foundry toolchain. You can find installation instructions [here](https://getfoundry.sh/).

Setup:
```bash
$ git clone https://github.com/chronicleprotocol/chronicle-std
$ cd chronicle-std/
$ forge install
```

Run tests:
```bash
$ forge test
$ forge test -vvvv # Run with full stack traces
$ FOUNDRY_PROFILE=intense forge test # Run in intense mode
```

Lint:
```bash
$ forge fmt [--check]
```

Update gas snapshots:
```bash
$ forge snapshot [--check]
```
