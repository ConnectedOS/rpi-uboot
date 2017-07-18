FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get install -y build-essential gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu device-tree-compiler bc
