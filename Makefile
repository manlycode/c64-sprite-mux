KICK_ASSEMBLER_URL := http://www.theweb.dk/KickAssembler/KickAssembler.zip

TMPDIR := $(shell mktemp -d /tmp/lean-tutorial.XXXX)

JAVA_RUNTIME := /usr/local/opt/openjdk/bin/java

KICK_DIR := /usr/local/opt/KickAssembler
KICK_ZIP := $(TMPDIR)/KickAss.zip
KICK_JAR := $(KICK_DIR)/KickAss.jar

DEBUG_ZIP := bin/C64Debugger.zip
DEBUG_DIR := /Applications
DEBUG_APP := $(DEBUG_DIR)/C64Debugger.app

.PHONY: bootstrap
bootstrap: /usr/local/opt/openjdk/bin/java $(KICK_JAR) $(DEBUG_APP) vendor/64spec
# https://phoenixnap.dl.sourceforge.net/project/c64-debugger/C64-65XE-Debugger-v0.64.58-MacOS.zip
#
.PHONY: clean
clean:
	-find . -type f -name '.source.txt' -exec rm {} +
	-find . -type f -name '*.sym' -exec rm {} +
	-find . -type f -name '*.prg' -exec rm {} +
	-find . -type f -name '*.vs' -exec rm {} +

.PHONY: clean-deps
clean-deps:
	-rm -rf $(DEBUG_APP)
	-rm -rf $(KICK_DIR)
	-rm -rf vendor/*
	touch vendor/.gitkeep

# vendor/64spec:

$(JAVA_RUNTIME):
	brew install openjdk

$(KICK_DIR):
	-mkdir -p $@

$(KICK_ZIP): $(KICK_DIR)
	curl -L $(KICK_ASSEMBLER_URL) -o $@

$(KICK_JAR): $(KICK_DIR) $(KICK_ZIP)
	unzip -o $(KICK_ZIP) -d $<

$(DEBUG_APP): $(DEBUG_DIR) $(DEBUG_ZIP)
	unzip -o $(DEBUG_ZIP) -d $<

vendor/64spec:
	git clone https://github.com/64bites/64spec.git $@

vendor/64spec/6502_tester: vendor/64spec
	pushd $<; make; popd
