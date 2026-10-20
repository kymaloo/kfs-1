
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TARGET=i686-elf
ENV PREFIX=/opt/cross
ENV PATH="/opt/cross/bin:${PATH}"

# Tools for compilation and creation of ISO
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bison \
    flex \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    texinfo \
    wget \
    xz-utils \
    ca-certificates \
    grub-pc-bin \
    grub-common \
    xorriso \
    mtools \
    make \
    nasm \
    file \
    binutils \
    && rm -rf /var/lib/apt/lists/*

# Linked Toolchain
ARG BINUTILS_VERSION=2.45
ARG GCC_VERSION=15.2.0
ARG JOBS=2

WORKDIR /tmp/toolchain

# Binutils for i686-elf
RUN wget -q \
    https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
    -O binutils.tar.xz \
    && tar -xf binutils.tar.xz \
    && mkdir build-binutils \
    && cd build-binutils \
    && ../binutils-${BINUTILS_VERSION}/configure \
       --target=${TARGET} \
       --prefix=${PREFIX} \
       --with-sysroot \
       --disable-nls \
       --disable-werror \
    && make -j${JOBS} \
    && make install

# GCC bare bones
RUN wget -q \
    https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
    -O gcc.tar.xz \
    && tar -xf gcc.tar.xz \
    && mkdir build-gcc \
    && cd build-gcc \
    && ../gcc-${GCC_VERSION}/configure \
       --target=${TARGET} \
       --prefix=${PREFIX} \
       --disable-nls \
       --enable-languages=c \
       --without-headers \
       --with-newlib \
       --disable-shared \
       --disable-hosted-libstdcxx \
    && make -j${JOBS} all-gcc \
    && make install-gcc \
    && make -j${JOBS} all-target-libgcc \
    && make install-target-libgcc

WORKDIR /workspace

CMD ["/bin/bash"]