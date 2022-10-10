#!/usr/bin/env bash

echo "::group::Install dependencies"
apt-get --quiet update
apt-get --quiet --yes install \
  binutils-dev cmake g++ gcc clang \
  iperf3 iproute2 libbfd-dev libcurl4-openssl-dev libdw-dev \
  libfdt-dev libiberty-dev libssl-dev lsof make net-tools \
  pkgconf zlib1g-dev tzdata xz-utils flex bison \
  librust-kvm-bindings-dev curl file git lsof openssh-client
echo "::endgroup::"

target=aarch64-unknown-linux-musl

echo "::group::Set up Rust"
curl https://sh.rustup.rs -sSf \
  | sh -s -- -y --default-toolchain "1.52.1"
source $HOME/.cargo/env
rustup target add "$target"
echo "::endgroup::"

echo "::group::Build seccompiler"
cargo build \
  -p seccompiler \
  --bin seccompiler-bin \
  --target-dir ../build/seccompiler \
  --target "$target"
echo "::endgroup::"

echo "::group::Build firecracker"
cargo build \
  --target-dir ../build/cargo_target \
  --target "$target"
echo "::endgroup::"

echo "::group::Build jailer"
cargo build \
  -p jailer \
  --target-dir ../build/cargo_target \
  --target "$target"
echo "::endgroup::"
