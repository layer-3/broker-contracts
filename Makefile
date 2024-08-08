SOLC = solc
ABIGEN = abigen
CONTRACT_PATH = ./src/vault/LiteVault.sol
BUILD_DIR = ./build
INTERFACE_DIR = ./vault
BASE_PATH = .
INCLUDE_PATH = ./node_modules

all: clean deps compile generate

clean:
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	mkdir -p $(INTERFACE_DIR)

deps:
	npm install @openzeppelin/contracts

compile:
	$(SOLC) --base-path $(BASE_PATH) --include-path $(INCLUDE_PATH) --abi --bin $(CONTRACT_PATH) -o $(BUILD_DIR)

generate:
	$(ABIGEN) --abi=$(BUILD_DIR)/LiteVault.abi --bin=$(BUILD_DIR)/LiteVault.bin --pkg=vault --out=$(INTERFACE_DIR)/vault.go

.PHONY: all clean deps compile generate
