LD64_VERSION                            ?= 954.16
PATCH_VERSION                           ?= -0
TAPI_VERSION                            ?= 1600.0.11.8

# Functions
unique                                   = $(if $1,$(firstword $1) $(call unique,$(filter-out $(firstword $1),$1)))
# XXX: Trying to escape paths here, but support for that in dependencies to far too poor to pursue this currently.
#escape                                   = '$(subst ','\'',$1)'

# Common
DIR_TARGETS                             :=

INC                                     := include
TAPI                                    := tapi
XAR                                     := xar
LD64                                    := ld64
LD64_INC                                := $(LD64)/include
LD64_SRC                                := $(LD64)/src
BUILD                                   := build
DIR_TARGETS                             += $(BUILD)

# Submodules
# NOTE: Do not use &> or <<< here. Systems with annoying default shells will throw a fit if you do.
ifndef IGNORE_SUBMODULE_HEAD
UNSYNCED_SUBMODULES                     := $(shell git config --file .gitmodules --get-regexp path | awk '{ print $$2 }' | while read -r module; do commit="$$(git ls-tree HEAD "$$module" | awk '{ print $$3 }')"; if [ -e "$$module/.git" ] && ! git --git-dir "$$module/.git" --work-tree "$$module" merge-base --is-ancestor "$$commit" HEAD; then printf '%s, ' "$$module"; fi; done | sed -E 's/, $$//')
ifneq ($(UNSYNCED_SUBMODULES),)
    $(error The following submodules are out of date: $(UNSYNCED_SUBMODULES). Either run "git submodule update" or set IGNORE_SUBMODULE_HEAD)
endif
endif

# Toolchain
TAR                                     ?= tar
ifndef TAR_FLAGS
    TAR_VERSION                         := $(shell $(TAR) --version)
    ifneq ($(findstring bsdtar,$(TAR_VERSION)),)
        TAR_FLAGS                       := --format gnutar --numeric-owner --uid 0 --gid 0 --no-xattrs
    else
    ifneq ($(findstring tar (GNU tar),$(TAR_VERSION)),)
        TAR_FLAGS                       := --format gnu --numeric-owner --owner 0 --group 0 --no-xattrs
    else
        $(error Unknown tar flavour. Either point TAR at gnutar or bsdtar, or set TAR_FLAGS to the equivalent of: --format gnutar --numeric-owner --uid 0 --gid 0 --no-xattrs)
    endif
    endif
endif

CMAKE                                   ?= cmake

ifdef LLVM_CONFIG
    LINUX_LLVM_CONFIG                   ?= $(LLVM_CONFIG)
endif

# ifdef+ifndef is ugly, but we really don't wanna use ?= when shell expansion is involved
ifdef LINUX_LLVM_CONFIG
ifndef LINUX_LLVM_BINDIR
    LINUX_LLVM_BINDIR                   := $(shell $(LINUX_LLVM_CONFIG) --bindir)
endif
endif

ifdef LLVM_BINDIR
    LINUX_LLVM_BINDIR                   ?= $(LLVM_BINDIR)
endif

ifdef LINUX_LLVM_BINDIR
    LINUX_CC                            ?= $(LINUX_LLVM_BINDIR)/clang
    LINUX_CXX                           ?= $(LINUX_LLVM_BINDIR)/clang++
    LINUX_LD                            ?= $(LINUX_LLVM_BINDIR)/ld.lld
    LINUX_AR                            ?= $(LINUX_LLVM_BINDIR)/llvm-ar
    LINUX_RANLIB                        ?= $(LINUX_LLVM_BINDIR)/llvm-ranlib
endif

CLANG                                   ?= clang
CLANGXX                                 ?= $(CLANG)++
LLD                                     ?= lld
LLVM_AR                                 ?= llvm-ar
LLVM_RANLIB                             ?= llvm-ranlib

LINUX_CC                                ?= $(CLANG)
LINUX_CXX                               ?= $(CLANGXX)
LINUX_LD                                ?= $(LLD)
LINUX_AR                                ?= $(LLVM_AR)
LINUX_RANLIB                            ?= $(LLVM_RANLIB)

ifdef ARM64_SDK
    LINUX_ARM64_SDK                     ?= $(ARM64_SDK)
endif
ifdef X86_64_SDK
    LINUX_X86_64_SDK                    ?= $(X86_64_SDK)
endif

ifdef LINUX_LD
    LINUX_LDFLAGS                       ?= --ld-path=$(LINUX_LD)
endif
ifdef LINUX_ARM64_SDK
    LINUX_ARM64_SDK_FLAGS               ?= --sysroot=$(LINUX_ARM64_SDK)
endif
ifdef LINUX_X86_64_SDK
    LINUX_X86_64_SDK_FLAGS              ?= --sysroot=$(LINUX_X86_64_SDK)
endif

ifdef CFLAGS
    LINUX_CFLAGS                        ?= $(CFLAGS)
endif
ifdef CXXFLAGS
    LINUX_CXXFLAGS                      ?= $(CXXFLAGS)
endif
ifdef LDFLAGS
    LINUX_LDFLAGS                       ?= $(LDFLAGS)
endif

# Common
LINUX_BASE_FLAGS                        := -pthread -flto -O3 -D_GNU_SOURCE -ffunction-sections -fdata-sections
LINUX_CC_FLAGS                          := -std=gnu17 $(LINUX_CFLAGS)
LINUX_CXX_FLAGS                         := -std=gnu++20 $(LINUX_CXXFLAGS)
LINUX_LD_FLAGS                          := -Wl,--gc-sections -Wl,--strip-all $(LINUX_LDFLAGS)

LINUX_TAPI_CC_FLAGS                     :=
LINUX_TAPI_CXX_FLAGS                    :=
LINUX_TAPI_LD_FLAGS                     :=
LINUX_TAPI_VARS                         := PKG_CONFIG_PATH=''
LINUX_TAPI_FLAGS                        := -DCMAKE_SYSTEM_NAME:STRING=Linux -DCMAKE_C_COMPILER:STRING='$(LINUX_CC)' -DCMAKE_CXX_COMPILER:STRING='$(LINUX_CXX)' -DCMAKE_ASM_COMPILER:STRING='$(LINUX_CC)' -DCMAKE_AR:STRING='$(LINUX_AR)' -DCMAKE_RANLIB:STRING='$(LINUX_RANLIB)' -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=ONLY -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH:BOOL=OFF -DLLVM_ENABLE_PROJECTS:STRING='clang;tapi' -DTAPI_REPOSITORY_STRING:STRING='tapi-$(TAPI_VERSION)' -DLIBTAPI_BUILD_STATIC:BOOL=ON

LINUX_XAR_CC_FLAGS                      :=
LINUX_XAR_LD_FLAGS                      :=
LINUX_XAR_FLAGS                         := --enable-static --disable-shared CC='$(LINUX_CC)' LD='$(LINUX_LD)' AR='$(LINUX_AR)' RANLIB='$(LINUX_RANLIB)'

LINUX_LD64_BASE_FLAGS                   := -fblocks
LINUX_LD64_CC_CXX_FLAGS                 := -Wno-gnu-folding-constant -isystem$(INC) -isystem$(LD64_INC) -iquote$(LD64_SRC) -iquote$(LD64_SRC)/abstraction -iquote$(LD64_SRC)/ld -iquote$(LD64_SRC)/ld/parsers -iquote$(LD64_SRC)/mach_o
LINUX_LD64_CC_FLAGS                     := $(LINUX_LD64_BASE_FLAGS) $(LINUX_LD64_CC_CXX_FLAGS)
LINUX_LD64_CXX_FLAGS                    := $(LINUX_LD64_BASE_FLAGS) $(LINUX_LD64_CC_CXX_FLAGS) -isystem$(TAPI)/llvm/include -isystem$(TAPI)/tapi/include
LINUX_LD64_LD_FLAGS                     := $(LINUX_LD64_BASE_FLAGS) -ltapi -ltapiCore -lLLVMTextAPI -lLLVMSupport -lLLVMBinaryFormat -lLLVMTargetParser -lxar -lz -lxml2 -lcrypto -luuid -ldl -lBlocksRuntime
LINUX_LD64_C                            := $(shell find $(LD64_SRC) -not -path '$(LD64_SRC)/other/*' -type f -name '*.c')
LINUX_LD64_H                            := $(shell find $(LD64_SRC) -not -path '$(LD64_SRC)/other/*' -type f -name '*.h') $(shell find $(LD64_INC) -not -path '$(LD64_SRC)/other/*' -type f -name '*.h') $(shell find $(INC) -not -path '$(LD64_SRC)/other/*' -type f -name '*.h')
LINUX_LD64_CPP                          := $(shell find $(LD64_SRC) -not -path '$(LD64_SRC)/other/*' -type f -name '*.cpp')
LINUX_LD64_HPP                          := $(shell find $(LD64_SRC) -not -path '$(LD64_SRC)/other/*' -type f -name '*.hpp')

# arm64
LINUX_ARM64                             := $(BUILD)/arm64
LINUX_ARM64_BASE_FLAGS                  := $(LINUX_BASE_FLAGS) $(LINUX_ARM64_SDK_FLAGS) --target=aarch64-linux-gnu
LINUX_ARM64_CC_FLAGS                    := $(LINUX_CC_FLAGS)
LINUX_ARM64_CXX_FLAGS                   := $(LINUX_CXX_FLAGS)
LINUX_ARM64_LD_FLAGS                    := $(LINUX_LD_FLAGS)
DIR_TARGETS                             += $(LINUX_ARM64)

LINUX_ARM64_TAPI_DIR                    := $(LINUX_ARM64)/.tapi
LINUX_ARM64_LIBTAPI                     := $(LINUX_ARM64_TAPI_DIR)/lib/libtapi.a
LINUX_ARM64_TAPI_CC_FLAGS               := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_CC_FLAGS) $(LINUX_TAPI_CC_FLAGS)
LINUX_ARM64_TAPI_CXX_FLAGS              := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_CXX_FLAGS) $(LINUX_TAPI_CXX_FLAGS)
LINUX_ARM64_TAPI_LD_FLAGS               := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_LD_FLAGS) $(LINUX_TAPI_LD_FLAGS)
LINUX_ARM64_TAPI_VARS                   := PKG_CONFIG_SYSROOT_DIR='$(LINUX_ARM64_SDK)' PKG_CONFIG_LIBDIR='$(LINUX_ARM64_SDK)/usr/lib/aarch64-linux-gnu/pkgconfig'
LINUX_ARM64_TAPI_FLAGS                  := -DCMAKE_C_COMPILER_TARGET:STRING=aarch64-linux-gnu -DCMAKE_CXX_COMPILER_TARGET:STRING=aarch64-linux-gnu -DCMAKE_ASM_COMPILER_TARGET:STRING=aarch64-linux-gnu -DCMAKE_C_FLAGS:STRING='$(LINUX_ARM64_TAPI_CC_FLAGS)' -DCMAKE_CXX_FLAGS:STRING='$(LINUX_ARM64_TAPI_CXX_FLAGS)' -DCMAKE_ASM_FLAGS:STRING='$(LINUX_ARM64_TAPI_CC_FLAGS)' -DCMAKE_EXE_LINKER_FLAGS:STRING='$(LINUX_ARM64_TAPI_LD_FLAGS)' -DCMAKE_SHARED_LINKER_FLAGS:STRING='$(LINUX_ARM64_TAPI_LD_FLAGS)' -DCMAKE_FIND_ROOT_PATH:STRING="$(LINUX_ARM64_SDK)"
DIR_TARGETS                             += $(LINUX_ARM64_TAPI_DIR)

LINUX_ARM64_XAR_DIR                     := $(LINUX_ARM64)/.xar
LINUX_ARM64_LIBXAR                      := $(LINUX_ARM64_XAR_DIR)/lib/libxar.a
LINUX_ARM64_XAR_CC_FLAGS                := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_CC_FLAGS) $(LINUX_XAR_CC_FLAGS)
LINUX_ARM64_XAR_LD_FLAGS                := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_LD_FLAGS) $(LINUX_XAR_LD_FLAGS)
LINUX_ARM64_XAR_FLAGS                   := --host=aarch64-linux-gnu CFLAGS='$(LINUX_ARM64_XAR_CC_FLAGS)' CPPFLAGS='$(LINUX_ARM64_XAR_CC_FLAGS)' LDFLAGS='$(LINUX_ARM64_XAR_LD_FLAGS)' $(LINUX_XAR_FLAGS) ac_cv_path_XML2_CONFIG='$(LINUX_ARM64_SDK)/usr/bin/xml2-config --prefix=$(LINUX_ARM64_SDK)/usr'
DIR_TARGETS                             += $(LINUX_ARM64_XAR_DIR)

LINUX_ARM64_LD64_DIR                    := $(LINUX_ARM64)/.ld64
LINUX_ARM64_LD64_INC                    := $(LINUX_ARM64_LD64_DIR)/include
LINUX_ARM64_LD64                        := $(LINUX_ARM64)/ld64
LINUX_ARM64_LD64_CC_CXX_FLAGS           := -iquote$(LINUX_ARM64_LD64_INC) -isystem$(LINUX_ARM64_XAR_DIR)/include
LINUX_ARM64_LD64_CC_FLAGS               := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_CC_FLAGS) $(LINUX_ARM64_LD64_CC_CXX_FLAGS) $(LINUX_LD64_CC_FLAGS)
LINUX_ARM64_LD64_CXX_FLAGS              := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_CXX_FLAGS) $(LINUX_ARM64_LD64_CC_CXX_FLAGS) $(LINUX_LD64_CXX_FLAGS) -isystem$(LINUX_ARM64_TAPI_DIR)/tools/clang/tools/tapi/include
LINUX_ARM64_LD64_LD_FLAGS               := $(LINUX_ARM64_BASE_FLAGS) $(LINUX_ARM64_LD_FLAGS) -L$(LINUX_ARM64_TAPI_DIR)/lib -L$(LINUX_ARM64_XAR_DIR)/lib $(LINUX_LD64_LD_FLAGS)
LINUX_ARM64_LD64_H                      := $(LINUX_ARM64_LD64_INC)/configure.h $(LINUX_ARM64_LD64_INC)/compile_stubs.h
LINUX_ARM64_LD64_O                      := $(patsubst $(LD64_SRC)/%.c,$(LINUX_ARM64_LD64_DIR)/%.o,$(LINUX_LD64_C))
DIR_TARGETS                             += $(LINUX_ARM64_LD64_DIR) $(LINUX_ARM64_LD64_INC) $(patsubst %/,%,$(call unique,$(dir $(LINUX_ARM64_LD64_O))))

LINUX_ARM64_DEB                         := $(LINUX_ARM64)/ld64_$(LD64_VERSION)$(PATCH_VERSION)_arm64.deb
LINUX_ARM64_DEB_DIR                     := $(LINUX_ARM64)/.deb
LINUX_ARM64_DEB_CONTROL_DIR             := $(LINUX_ARM64_DEB_DIR)/control
LINUX_ARM64_DEB_CONTROL                 := $(LINUX_ARM64_DEB_CONTROL_DIR)/control
LINUX_ARM64_DEB_DATA_DIR                := $(LINUX_ARM64_DEB_DIR)/data
LINUX_ARM64_DEB_LD64_DIR                := $(LINUX_ARM64_DEB_DATA_DIR)/usr/bin
LINUX_ARM64_DEB_LD64                    := $(LINUX_ARM64_DEB_LD64_DIR)/ld64
DIR_TARGETS                             += $(LINUX_ARM64_DEB_DIR) $(LINUX_ARM64_DEB_CONTROL_DIR) $(LINUX_ARM64_DEB_DATA_DIR) $(LINUX_ARM64_DEB_LD64_DIR)

# x86_64
LINUX_X86_64                            := $(BUILD)/x86_64
LINUX_X86_64_BASE_FLAGS                 := $(LINUX_BASE_FLAGS) $(LINUX_X86_64_SDK_FLAGS) --target=x86_64-linux-gnu
LINUX_X86_64_CC_FLAGS                   := $(LINUX_CC_FLAGS)
LINUX_X86_64_CXX_FLAGS                  := $(LINUX_CXX_FLAGS)
LINUX_X86_64_LD_FLAGS                   := $(LINUX_LD_FLAGS)
DIR_TARGETS                             += $(LINUX_X86_64)

LINUX_X86_64_TAPI_DIR                   := $(LINUX_X86_64)/.tapi
LINUX_X86_64_LIBTAPI                    := $(LINUX_X86_64_TAPI_DIR)/lib/libtapi.a
LINUX_X86_64_TAPI_CC_FLAGS              := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_CC_FLAGS) $(LINUX_TAPI_CC_FLAGS)
LINUX_X86_64_TAPI_CXX_FLAGS             := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_CXX_FLAGS) $(LINUX_TAPI_CXX_FLAGS)
LINUX_X86_64_TAPI_LD_FLAGS              := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_LD_FLAGS) $(LINUX_TAPI_LD_FLAGS)
LINUX_X86_64_TAPI_VARS                  := PKG_CONFIG_SYSROOT_DIR='$(LINUX_X86_64_SDK)' PKG_CONFIG_LIBDIR='$(LINUX_X86_64_SDK)/usr/lib/x86_64-linux-gnu/pkgconfig'
LINUX_X86_64_TAPI_FLAGS                 := -DCMAKE_C_COMPILER_TARGET:STRING=x86_64-linux-gnu -DCMAKE_CXX_COMPILER_TARGET:STRING=x86_64-linux-gnu -DCMAKE_ASM_COMPILER_TARGET:STRING=x86_64-linux-gnu -DCMAKE_C_FLAGS:STRING='$(LINUX_X86_64_TAPI_CC_FLAGS)' -DCMAKE_CXX_FLAGS:STRING='$(LINUX_X86_64_TAPI_CXX_FLAGS)' -DCMAKE_ASM_FLAGS:STRING='$(LINUX_X86_64_TAPI_CC_FLAGS)' -DCMAKE_EXE_LINKER_FLAGS:STRING='$(LINUX_X86_64_TAPI_LD_FLAGS)' -DCMAKE_SHARED_LINKER_FLAGS:STRING='$(LINUX_X86_64_TAPI_LD_FLAGS)' -DCMAKE_FIND_ROOT_PATH:STRING="$(LINUX_X86_64_SDK)"
DIR_TARGETS                             += $(LINUX_X86_64_TAPI_DIR)

LINUX_X86_64_XAR_DIR                    := $(LINUX_X86_64)/.xar
LINUX_X86_64_LIBXAR                     := $(LINUX_X86_64_XAR_DIR)/lib/libxar.a
LINUX_X86_64_XAR_CC_FLAGS               := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_CC_FLAGS) $(LINUX_XAR_CC_FLAGS)
LINUX_X86_64_XAR_LD_FLAGS               := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_LD_FLAGS) $(LINUX_XAR_LD_FLAGS)
LINUX_X86_64_XAR_FLAGS                  := --host=x86_64-linux-gnu CFLAGS='$(LINUX_X86_64_XAR_CC_FLAGS)' CPPFLAGS='$(LINUX_X86_64_XAR_CC_FLAGS)' LDFLAGS='$(LINUX_X86_64_XAR_LD_FLAGS)' $(LINUX_XAR_FLAGS) ac_cv_path_XML2_CONFIG='$(LINUX_X86_64_SDK)/usr/bin/xml2-config --prefix=$(LINUX_X86_64_SDK)/usr'
DIR_TARGETS                             += $(LINUX_X86_64_XAR_DIR)

LINUX_X86_64_LD64_DIR                   := $(LINUX_X86_64)/.ld64
LINUX_X86_64_LD64_INC                    := $(LINUX_X86_64_LD64_DIR)/include
LINUX_X86_64_LD64                       := $(LINUX_X86_64)/ld64
LINUX_X86_64_LD64_CC_CXX_FLAGS          := -iquote$(LINUX_X86_64_LD64_INC) -isystem$(LINUX_X86_64_XAR_DIR)/include
LINUX_X86_64_LD64_CC_FLAGS              := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_CC_FLAGS) $(LINUX_X86_64_LD64_CC_CXX_FLAGS) $(LINUX_LD64_CC_FLAGS)
LINUX_X86_64_LD64_CXX_FLAGS             := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_CXX_FLAGS) $(LINUX_X86_64_LD64_CC_CXX_FLAGS) $(LINUX_LD64_CXX_FLAGS) -isystem$(LINUX_X86_64_TAPI_DIR)/tools/clang/tools/tapi/include
LINUX_X86_64_LD64_LD_FLAGS              := $(LINUX_X86_64_BASE_FLAGS) $(LINUX_X86_64_LD_FLAGS) -L$(LINUX_X86_64_TAPI_DIR)/lib -L$(LINUX_X86_64_XAR_DIR)/lib $(LINUX_LD64_LD_FLAGS)
LINUX_X86_64_LD64_H                     := $(LINUX_X86_64_LD64_INC)/configure.h $(LINUX_X86_64_LD64_INC)/compile_stubs.h
LINUX_X86_64_LD64_O                     := $(patsubst $(LD64_SRC)/%.c,$(LINUX_X86_64_LD64_DIR)/%.o,$(LINUX_LD64_C))
DIR_TARGETS                             += $(LINUX_X86_64_LD64_DIR) $(LINUX_X86_64_LD64_INC) $(patsubst %/,%,$(call unique,$(dir $(LINUX_X86_64_LD64_O))))

LINUX_X86_64_DEB                        := $(LINUX_X86_64)/ld64_$(LD64_VERSION)$(PATCH_VERSION)_amd64.deb
LINUX_X86_64_DEB_DIR                    := $(LINUX_X86_64)/.deb
LINUX_X86_64_DEB_CONTROL_DIR            := $(LINUX_X86_64_DEB_DIR)/control
LINUX_X86_64_DEB_CONTROL                := $(LINUX_X86_64_DEB_CONTROL_DIR)/control
LINUX_X86_64_DEB_DATA_DIR               := $(LINUX_X86_64_DEB_DIR)/data
LINUX_X86_64_DEB_LD64_DIR               := $(LINUX_X86_64_DEB_DATA_DIR)/usr/bin
LINUX_X86_64_DEB_LD64                   := $(LINUX_X86_64_DEB_LD64_DIR)/ld64
DIR_TARGETS                             += $(LINUX_X86_64_DEB_DIR) $(LINUX_X86_64_DEB_CONTROL_DIR) $(LINUX_X86_64_DEB_DATA_DIR) $(LINUX_X86_64_DEB_LD64_DIR)


.PHONY: all arm64 x86_64 clean always

# Preserve all dependencies, and rebuild if they're missing
.NOTINTERMEDIATE:

# Disable implicit rules
.SUFFIXES:

all: arm64 x86_64

arm64: $(LINUX_ARM64_DEB)

x86_64: $(LINUX_X86_64_DEB)


.SECONDEXPANSION:


$(LINUX_ARM64_LIBTAPI): $(LINUX_ARM64_TAPI_DIR)/Makefile
	$(MAKE) -C $(LINUX_ARM64_TAPI_DIR) libtapi

$(LINUX_X86_64_LIBTAPI): $(LINUX_X86_64_TAPI_DIR)/Makefile
	$(MAKE) -C $(LINUX_X86_64_TAPI_DIR) libtapi

$(LINUX_ARM64_TAPI_DIR)/Makefile: always | $(LINUX_ARM64_TAPI_DIR)
	cd $(LINUX_ARM64_TAPI_DIR) && \
	$(LINUX_TAPI_VARS) $(LINUX_ARM64_TAPI_VARS) $(CMAKE) $(CMAKE_FLAGS) ../../../$(TAPI)/llvm -C ../../../$(TAPI)/tapi/cmake/caches/apple-tapi.cmake $(LINUX_TAPI_FLAGS) $(LINUX_ARM64_TAPI_FLAGS)

$(LINUX_X86_64_TAPI_DIR)/Makefile: always | $(LINUX_X86_64_TAPI_DIR)
	cd $(LINUX_X86_64_TAPI_DIR) && \
	$(LINUX_TAPI_VARS) $(LINUX_X86_64_TAPI_VARS) $(CMAKE) $(CMAKE_FLAGS) ../../../$(TAPI)/llvm -C ../../../$(TAPI)/tapi/cmake/caches/apple-tapi.cmake $(LINUX_TAPI_FLAGS) $(LINUX_X86_64_TAPI_FLAGS)

$(LINUX_ARM64_LIBXAR): $(LINUX_ARM64_XAR_DIR)/Makefile always | $(LINUX_ARM64_XAR_DIR)
	$(MAKE) -C $(LINUX_ARM64_XAR_DIR) $(patsubst $(LINUX_ARM64_XAR_DIR)/%,%,$@)

$(LINUX_X86_64_LIBXAR): $(LINUX_X86_64_XAR_DIR)/Makefile always | $(LINUX_X86_64_XAR_DIR)
	$(MAKE) -C $(LINUX_X86_64_XAR_DIR) $(patsubst $(LINUX_X86_64_XAR_DIR)/%,%,$@)

$(LINUX_ARM64_XAR_DIR)/Makefile: Makefile $(XAR)/xar/configure $(XAR)/xar/Makefile.in | $(LINUX_ARM64_XAR_DIR)
	cd $(LINUX_ARM64_XAR_DIR) && \
	../../../$(XAR)/xar/configure $(LINUX_ARM64_XAR_FLAGS)

$(LINUX_X86_64_XAR_DIR)/Makefile: Makefile $(XAR)/xar/configure $(XAR)/xar/Makefile.in | $(LINUX_X86_64_XAR_DIR)
	cd $(LINUX_X86_64_XAR_DIR) && \
	../../../$(XAR)/xar/configure $(LINUX_X86_64_XAR_FLAGS)

$(LINUX_ARM64_LD64_INC)/configure.h: Makefile | $(LINUX_ARM64_LD64_INC)
	( echo '#ifndef LD64_CONFIGURE_H'; \
	  echo '#define LD64_CONFIGURE_H'; \
	  echo '#define SUPPORT_ARCH_i386       1'; \
	  echo '#define SUPPORT_ARCH_x86_64     1'; \
	  echo '#define SUPPORT_ARCH_x86_64h    1'; \
	  echo '#define SUPPORT_ARCH_armv4t     1'; \
	  echo '#define SUPPORT_ARCH_armv5      1'; \
	  echo '#define SUPPORT_ARCH_armv6      1'; \
	  echo '#define SUPPORT_ARCH_armv6m     1'; \
	  echo '#define SUPPORT_ARCH_armv7      1'; \
	  echo '#define SUPPORT_ARCH_armv7em    1'; \
	  echo '#define SUPPORT_ARCH_armv7f     1'; \
	  echo '#define SUPPORT_ARCH_armv7k     1'; \
	  echo '#define SUPPORT_ARCH_armv7m     1'; \
	  echo '#define SUPPORT_ARCH_armv7s     1'; \
	  echo '#define SUPPORT_ARCH_armv8      1'; \
	  echo '#define SUPPORT_ARCH_arm64      1'; \
	  echo '#define SUPPORT_ARCH_arm64v8    1'; \
	  echo '#define SUPPORT_ARCH_arm64e     1'; \
	  echo '#define SUPPORT_ARCH_arm64_32   1'; \
	  echo '#define SUPPORT_ARCH_riscv      1'; \
	  echo '#define ALL_SUPPORTED_ARCHS     "i386 x86_64 x86_64h armv4t armv5 armv6 armv6m armv7 armv7em armv7f armv7k armv7m armv7s armv8 arm64 arm64v8 arm64e arm64_32 riscv"'; \
	  echo '#define BITCODE_XAR_VERSION     "1.0"'; \
	  echo '#define LD64_VERSION_NUM        $(LD64_VERSION)'; \
	  echo '#define LD_PAGE_SIZE            0x1000'; \
	  echo 'const char ld_classicVersionString[] = "@(#)PROGRAM:ld  PROJECT:ld64-$(LD64_VERSION)\\n";'; \
	  echo '#endif'; \
	) > $@

$(LINUX_ARM64_LD64_INC)/compile_stubs.h: $(LD64)/compile_stubs Makefile | $(LINUX_ARM64_LD64_INC)
	( echo '#ifndef LD64_COMPILE_STUBS_H'; \
	  echo '#define LD64_COMPILE_STUBS_H'; \
	  echo 'static const char *compile_stubs = '; \
	  cat $< | sed 's/\"/\\\"/g;s/^/\"/;s/$$/\\n\"/'; \
	  echo ';'; \
	  echo '#endif'; \
	) > $@

$(LINUX_ARM64_LD64_O): $(LINUX_ARM64_LD64_DIR)/%.o: $(LD64_SRC)/%.c $(LINUX_LD64_H) | $$(@D)
	$(LINUX_CC) -c -o $@ $(LINUX_ARM64_LD64_CC_FLAGS) $<

$(LINUX_ARM64_LD64): $(LINUX_ARM64_LD64_H) $(LINUX_ARM64_LD64_O) $(LINUX_LD64_CPP) $(LINUX_LD64_H) $(LINUX_LD64_HPP) $(LINUX_ARM64_LIBTAPI) $(LINUX_ARM64_LIBXAR) | $(LINUX_ARM64)
	$(LINUX_CXX) -o $@ $(LINUX_ARM64_LD64_O) $(LINUX_ARM64_LD64_CXX_FLAGS) $(LINUX_LD64_CPP) $(LINUX_ARM64_LD64_LD_FLAGS)

$(LINUX_X86_64_LD64_INC)/configure.h: Makefile | $(LINUX_X86_64_LD64_INC)
	( echo '#ifndef LD64_CONFIGURE_H'; \
	  echo '#define LD64_CONFIGURE_H'; \
	  echo '#define SUPPORT_ARCH_i386       1'; \
	  echo '#define SUPPORT_ARCH_x86_64     1'; \
	  echo '#define SUPPORT_ARCH_x86_64h    1'; \
	  echo '#define SUPPORT_ARCH_armv4t     1'; \
	  echo '#define SUPPORT_ARCH_armv5      1'; \
	  echo '#define SUPPORT_ARCH_armv6      1'; \
	  echo '#define SUPPORT_ARCH_armv6m     1'; \
	  echo '#define SUPPORT_ARCH_armv7      1'; \
	  echo '#define SUPPORT_ARCH_armv7em    1'; \
	  echo '#define SUPPORT_ARCH_armv7f     1'; \
	  echo '#define SUPPORT_ARCH_armv7k     1'; \
	  echo '#define SUPPORT_ARCH_armv7m     1'; \
	  echo '#define SUPPORT_ARCH_armv7s     1'; \
	  echo '#define SUPPORT_ARCH_armv8      1'; \
	  echo '#define SUPPORT_ARCH_arm64      1'; \
	  echo '#define SUPPORT_ARCH_arm64v8    1'; \
	  echo '#define SUPPORT_ARCH_arm64e     1'; \
	  echo '#define SUPPORT_ARCH_arm64_32   1'; \
	  echo '#define SUPPORT_ARCH_riscv      1'; \
	  echo '#define ALL_SUPPORTED_ARCHS     "i386 x86_64 x86_64h armv4t armv5 armv6 armv6m armv7 armv7em armv7f armv7k armv7m armv7s armv8 arm64 arm64v8 arm64e arm64_32 riscv"'; \
	  echo '#define BITCODE_XAR_VERSION     "1.0"'; \
	  echo '#define LD64_VERSION_NUM        $(LD64_VERSION)'; \
	  echo '#define LD_PAGE_SIZE            0x1000'; \
	  echo 'const char ld_classicVersionString[] = "@(#)PROGRAM:ld  PROJECT:ld64-$(LD64_VERSION)\\n";'; \
	  echo '#endif'; \
	) > $@

$(LINUX_X86_64_LD64_INC)/compile_stubs.h: $(LD64)/compile_stubs Makefile | $(LINUX_X86_64_LD64_INC)
	( echo '#ifndef LD64_COMPILE_STUBS_H'; \
	  echo '#define LD64_COMPILE_STUBS_H'; \
	  echo 'static const char *compile_stubs = '; \
	  cat $< | sed 's/\"/\\\"/g;s/^/\"/;s/$$/\\n\"/'; \
	  echo ';'; \
	  echo '#endif'; \
	) > $@

$(LINUX_X86_64_LD64_O): $(LINUX_X86_64_LD64_DIR)/%.o: $(LD64_SRC)/%.c $(LINUX_LD64_H) | $$(@D)
	$(LINUX_CC) -c -o $@ $(LINUX_X86_64_LD64_CC_FLAGS) $<

$(LINUX_X86_64_LD64): $(LINUX_X86_64_LD64_H) $(LINUX_X86_64_LD64_O) $(LINUX_LD64_CPP) $(LINUX_LD64_H) $(LINUX_LD64_HPP) $(LINUX_X86_64_LIBTAPI) $(LINUX_X86_64_LIBXAR) | $(LINUX_X86_64)
	$(LINUX_CXX) -o $@ $(LINUX_X86_64_LD64_O) $(LINUX_X86_64_LD64_CXX_FLAGS) $(LINUX_LD64_CPP) $(LINUX_X86_64_LD64_LD_FLAGS)

$(LINUX_ARM64_DEB): $(LINUX_ARM64_DEB_DIR)/debian-binary $(LINUX_ARM64_DEB_DIR)/control.tar.xz $(LINUX_ARM64_DEB_DIR)/data.tar.xz | $(LINUX_ARM64)
	$(LINUX_AR) -crDS --format=gnu $@ $^

$(LINUX_X86_64_DEB): $(LINUX_X86_64_DEB_DIR)/debian-binary $(LINUX_X86_64_DEB_DIR)/control.tar.xz $(LINUX_X86_64_DEB_DIR)/data.tar.xz | $(LINUX_X86_64)
	$(LINUX_AR) -crDS --format=gnu $@ $^

$(LINUX_ARM64_DEB_DIR)/data.tar.xz: $(LINUX_ARM64_DEB_LD64) | $(LINUX_ARM64_DEB_DIR)
	$(TAR) $(TAR_FLAGS) -cJf $@ -C $(LINUX_ARM64_DEB_DATA_DIR) .

$(LINUX_X86_64_DEB_DIR)/data.tar.xz: $(LINUX_X86_64_DEB_LD64) | $(LINUX_X86_64_DEB_DIR)
	$(TAR) $(TAR_FLAGS) -cJf $@ -C $(LINUX_X86_64_DEB_DATA_DIR) .

$(LINUX_ARM64_DEB_LD64): $(LINUX_ARM64_LD64) | $(LINUX_ARM64_DEB_LD64_DIR)
	cp $< $@

$(LINUX_X86_64_DEB_LD64): $(LINUX_X86_64_LD64) | $(LINUX_X86_64_DEB_LD64_DIR)
	cp $< $@

$(LINUX_ARM64_DEB_DIR)/control.tar.xz: $(LINUX_ARM64_DEB_CONTROL) | $(LINUX_ARM64_DEB_DIR)
	$(TAR) $(TAR_FLAGS) -cJf $@ -C $(LINUX_ARM64_DEB_CONTROL_DIR) .

$(LINUX_X86_64_DEB_DIR)/control.tar.xz: $(LINUX_X86_64_DEB_CONTROL) | $(LINUX_X86_64_DEB_DIR)
	$(TAR) $(TAR_FLAGS) -cJf $@ -C $(LINUX_X86_64_DEB_CONTROL_DIR) .

$(LINUX_ARM64_DEB_CONTROL): Makefile | $(LINUX_ARM64_DEB_CONTROL_DIR)
	( echo 'Package: ld64'; \
	  echo 'Maintainer: checkra1n Team'; \
	  echo 'Architecture: arm64'; \
	  echo 'Version: $(LD64_VERSION)$(PATCH_VERSION)'; \
	  echo 'Priority: optional'; \
	  echo 'Section: devel'; \
	  echo 'Depends: libc6 (>= 2.31), libgcc-s1 (>= 10.2.1), libstdc++6 (>= 10.2.1), libxml2 (>= 2.9.10), zlib1g (>= 1:1.2.11), libssl1.1 (>= 1.1.1), libuuid1 (>= 1.0), libblocksruntime0 (>= 0.4.1-1.1)'; \
	  echo 'Description: Apple ld64'; \
	) > $@

$(LINUX_X86_64_DEB_CONTROL): Makefile | $(LINUX_X86_64_DEB_CONTROL_DIR)
	( echo 'Package: ld64'; \
	  echo 'Maintainer: checkra1n Team'; \
	  echo 'Architecture: amd64'; \
	  echo 'Version: $(LD64_VERSION)$(PATCH_VERSION)'; \
	  echo 'Priority: optional'; \
	  echo 'Section: devel'; \
	  echo 'Depends: libc6 (>= 2.31), libgcc-s1 (>= 10.2.1), libstdc++6 (>= 10.2.1), libxml2 (>= 2.9.10), zlib1g (>= 1:1.2.11), libssl1.1 (>= 1.1.1), libuuid1 (>= 1.0), libblocksruntime0 (>= 0.4.1-1.1)'; \
	  echo 'Description: Apple ld64'; \
	) > $@

$(LINUX_ARM64_DEB_DIR)/debian-binary: | $(LINUX_ARM64_DEB_DIR)
	echo '2.0' >$@

$(LINUX_X86_64_DEB_DIR)/debian-binary: | $(LINUX_X86_64_DEB_DIR)
	echo '2.0' >$@

# Rest
$(DIR_TARGETS):
	mkdir -p $@

clean:
	rm -rf $(BUILD)
