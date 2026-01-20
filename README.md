# ld64

Apple `ld64` for Debian.


### Structure

Sources are kept in separate submodules [ld64](https://github.com/checkra1n/ld64), [tapi](https://github.com/checkra1n/tapi) and [xar](https://github.com/checkra1n/xar), each with branches of raw imports from [Apple OSS](https://github.com/apple-oss-distributions/) and different branches with fixes on top. Changes in those repos are kept to an absolute minimum in order to keep forward-porting feasible.

This repo contains only the Makefile and custom headers required to bridge the gap between Darwin/BSD and Linux (headers ripped from Apple OSS go in the submodules).


### Building

The idea is to use the [checkra1n SDK](https://github.com/checkra1n/SDK)'s "dev" targets for consistency (i.e. we're always cross-compiling). Builds are done against arm64 and x86_64 Debian 11. checkra1n itself is built for a wider range of targets, but for the toolchain we have more strict requirements.

The final outputs are one `ld64` binary and one `.deb` package per architecture.  
The targets `arm64` and `x86_64` build everything for just one architecture, `all` builds for both (the default).

The Makefile has a whole bunch of env vars that can be used to customise the build, but usually these three should suffice:
- `LLVM_CONFIG`
- `ARM64_SDK`
- `X86_64_SDK`

Example (assuming you've already cloned this repo):

```
git clone https://github.com/checkra1n/SDK.git /tmp/SDK
/tmp/SDK/make.sh all-linux-gnu-dev all
git submodule update --init
LLVM_CONFIG=path/to/llvm-config ARM64_SDK=/tmp/SDK/build/arm64-linux-gnu-dev X86_64_SDK=/tmp/SDK/build/x86_64-linux-gnu-dev make
```


### Binaries

Binaries are available for arm64 and x86_64, built against Debian 11 (should be compatible with Ubuntu 20.04 or newer).

Builds are done via [Actions](https://github.com/checkra1n/ld64-build/actions) and uploaded to [Releases](https://github.com/checkra1n/ld64-build/releases) as well as the [checkra1n APT repo](https://checkra.in/linux).
