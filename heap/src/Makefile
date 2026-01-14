# Unified Makefile for simpleheap with static-linked jemalloc
#
# Usage:
#   make -f Makefile-jemalloc VERSION=5.3.0 ARCH=x64
#   make -f Makefile-jemalloc VERSION=4.5.0 ARCH=x32
#
# Parameters:
#   VERSION - jemalloc version (default: 5.3.0)
#   ARCH    - target architecture: x64 or x32 (default: x64)

# Configuration parameters with defaults
VERSION ?= 5.3.0
ARCH ?= x64

# Validate ARCH
ifneq ($(ARCH),x64)
ifneq ($(ARCH),x32)
$(error ARCH must be x64 or x32, got: $(ARCH))
endif
endif

# Directories
JEMALLOC_DIR = jemalloc
JEMALLOC_BUILD = $(JEMALLOC_DIR)
JEMALLOC_LIB = $(JEMALLOC_BUILD)/lib/libjemalloc.a
JEMALLOC_INCLUDE = $(JEMALLOC_BUILD)/include

# Compiler and flags
CC = gcc

# Architecture-specific flags
ifeq ($(ARCH),x32)
ARCH_CFLAGS = -m32
ARCH_LDFLAGS = -m32
AUTOGEN_ENV = CFLAGS="-m32" CXXFLAGS="-m32" LDFLAGS="-m32"
AUTOGEN_ARGS = --host=i686-pc-linux-gnu
else
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
	git clone https://github.com/jemalloc/jemalloc $(JEMALLOC_DIR)
	cd $(JEMALLOC_DIR) && git checkout $(VERSION)
	@echo "Jemalloc v$(VERSION) cloned and checked out"

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
	@echo "  make -f Makefile-jemalloc [VERSION=x.y.z] [ARCH=x64|x32] [target]"
	@echo ""
	@echo "Parameters:"
	@echo "  VERSION  - jemalloc version to use (default: 5.3.0)"
	@echo "  ARCH     - target architecture: x64 or x32 (default: x64)"
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
	@echo "  make -f Makefile-jemalloc VERSION=5.3.0 ARCH=x64"
	@echo "  make -f Makefile-jemalloc VERSION=4.5.0 ARCH=x32"
	@echo "  make -f Makefile-jemalloc VERSION=4.5.0 ARCH=x64 rebuild"
