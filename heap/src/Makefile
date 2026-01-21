# Unified Makefile for simpleheap with static-linked jemalloc
#
# Usage:
#   make VERSION=5.3.0 ARCH=amd64
#   make VERSION=4.5.0 ARCH=i386
#   make VERSION=5.3.0 ARCH=arm64
#   make VERSION=5.3.0 ARCH=arm32
#
# Parameters:
#   VERSION - jemalloc version (default: 5.3.0)
#   ARCH    - target architecture: amd64, i386, arm64, or arm32 (default: amd64)

# Configuration parameters with defaults
VERSION ?= 5.3.0
ARCH ?= amd64

# Validate ARCH
ifneq ($(ARCH),amd64)
ifneq ($(ARCH),i386)
ifneq ($(ARCH),arm64)
ifneq ($(ARCH),arm32)
$(error ARCH must be amd64, i386, arm64, or arm32, got: $(ARCH))
endif
endif
endif
endif

# Directories
JEMALLOC_DIR = jemalloc
JEMALLOC_BUILD = $(JEMALLOC_DIR)
JEMALLOC_LIB = $(JEMALLOC_BUILD)/lib/libjemalloc.a
JEMALLOC_INCLUDE = $(JEMALLOC_BUILD)/include

# Detect host architecture
HOST_ARCH := $(shell uname -m)

# Compiler and flags
CC = gcc

# Architecture-specific flags
ifeq ($(ARCH),i386)
CC = gcc
ARCH_CFLAGS = -m32
ARCH_LDFLAGS = -m32
AUTOGEN_ENV = CFLAGS="-m32" CXXFLAGS="-m32" LDFLAGS="-m32"
AUTOGEN_ARGS = --host=i686-pc-linux-gnu
else ifeq ($(ARCH),arm64)
# Use native gcc if on arm64, otherwise cross-compile
ifeq ($(HOST_ARCH),aarch64)
CC = gcc
ARCH_CFLAGS =
ARCH_LDFLAGS =
AUTOGEN_ENV =
AUTOGEN_ARGS =
else
CC = aarch64-linux-gnu-gcc
CXX = aarch64-linux-gnu-g++
ARCH_CFLAGS =
ARCH_LDFLAGS =
AUTOGEN_ENV = CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++
AUTOGEN_ARGS = --host=aarch64-linux-gnu
endif
else ifeq ($(ARCH),arm32)
# Use native gcc if on arm32, otherwise cross-compile
ifeq ($(filter arm%,$(HOST_ARCH)),$(HOST_ARCH))
CC = gcc
ARCH_CFLAGS =
ARCH_LDFLAGS =
AUTOGEN_ENV =
AUTOGEN_ARGS =
else
CC = arm-linux-gnueabihf-gcc
CXX = arm-linux-gnueabihf-g++
ARCH_CFLAGS =
ARCH_LDFLAGS =
AUTOGEN_ENV = CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++
AUTOGEN_ARGS = --host=arm-linux-gnueabihf
endif
else
CC = gcc
ARCH_CFLAGS =
ARCH_LDFLAGS =
AUTOGEN_ENV =
AUTOGEN_ARGS =
endif

CFLAGS = $(ARCH_CFLAGS) -g -O0 -DUSE_JEMALLOC -I$(JEMALLOC_INCLUDE)
LDFLAGS = $(ARCH_LDFLAGS) $(JEMALLOC_LIB) -lpthread -ldl -lm

# Targets
TARGET = simpleheap
SRC = simpleheap.c

.PHONY: all clean jemalloc-clean jemalloc-configure jemalloc-build rebuild jemalloc-clone help

all: $(TARGET)

# Clone jemalloc and checkout specified version
$(JEMALLOC_DIR)/configure:
	@if [ ! -d $(JEMALLOC_DIR)/.git ]; then \
		git clone https://github.com/jemalloc/jemalloc $(JEMALLOC_DIR); \
	fi
	cd $(JEMALLOC_DIR) && git checkout $(VERSION)
	cd $(JEMALLOC_DIR) && autoconf
	@echo "Jemalloc v$(VERSION) ready"

jemalloc-clone: $(JEMALLOC_DIR)/configure

# Build simpleheap
$(TARGET): $(SRC) $(JEMALLOC_LIB)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	@echo "Built $(TARGET) successfully ($(ARCH), static, jemalloc $(VERSION))"

# Configure jemalloc
$(JEMALLOC_BUILD)/Makefile: $(JEMALLOC_DIR)/configure
	cd $(JEMALLOC_DIR) && $(AUTOGEN_ENV) ./autogen.sh $(AUTOGEN_ARGS)
	@echo "Jemalloc configured ($(ARCH))"

# Build jemalloc
$(JEMALLOC_LIB): $(JEMALLOC_BUILD)/Makefile
	$(MAKE) -C $(JEMALLOC_DIR)
	@echo "Jemalloc built successfully"

# Convenience targets
jemalloc-configure: $(JEMALLOC_BUILD)/Makefile

jemalloc-build: $(JEMALLOC_LIB)

# Clean targets
clean:
	rm -f $(TARGET)

jemalloc-clean:
	$(MAKE) -C $(JEMALLOC_DIR) clean || true

distclean: clean jemalloc-clean
	cd $(JEMALLOC_DIR) && git clean -fdx || true

# Rebuild everything from scratch
rebuild: distclean all

# Help
help:
	@echo "Unified Makefile for simpleheap with jemalloc (static linking)"
	@echo ""
	@echo "Usage:"
	@echo "  make [VERSION=x.y.z] [ARCH=amd64|i386|arm64|arm32] [target]"
	@echo ""
	@echo "Parameters:"
	@echo "  VERSION  - jemalloc version to use (default: 5.3.0)"
	@echo "  ARCH     - target architecture: amd64, i386, arm64, or arm32 (default: amd64)"
	@echo ""
	@echo "Current settings:"
	@echo "  VERSION  = $(VERSION)"
	@echo "  ARCH     = $(ARCH)"
	@echo ""
	@echo "Targets:"
	@echo "  all              - Build simpleheap (default)"
	@echo "  jemalloc-clone   - Clone jemalloc from GitHub"
	@echo "  jemalloc-configure - Configure jemalloc"
	@echo "  jemalloc-build   - Build jemalloc library"
	@echo "  clean            - Remove simpleheap binary"
	@echo "  jemalloc-clean   - Clean jemalloc build"
	@echo "  distclean        - Clean everything including jemalloc"
	@echo "  rebuild          - Rebuild from scratch"
	@echo "  help             - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make VERSION=5.3.0 ARCH=amd64"
	@echo "  make VERSION=4.5.0 ARCH=i386"
	@echo "  make VERSION=5.3.0 ARCH=arm64"
	@echo "  make VERSION=5.3.0 ARCH=arm32"
	@echo "  make VERSION=4.5.0 ARCH=amd64 rebuild"
