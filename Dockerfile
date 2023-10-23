# Use the official Ubuntu 20.04 base image
FROM --platform=linux/amd64 ubuntu:20.04

# Avoid prompts from apt.
ENV DEBIAN_FRONTEND=noninteractive

# Update and install standard linux packages
RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY /deployment_files/ home/deployment_files/

RUN apt-get update && apt-get install -y curl && \
    apt-get install -y wget && apt install -y lsb-core && \
    apt-get install -y build-essential git libtool libtool-bin unzip && \
    apt-get install -y python2.7

# following https://hub.docker.com/r/solsson/svn-httpd/dockerfile
RUN apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates libserf-1-1 && \
    apt-get install -y --no-install-recommends bzip2 gcc libpcre++-dev && \
    apt-get install -y --no-install-recommends libssl-dev make libsqlite3-dev zlib1g-dev && \
    apt-get install -y --no-install-recommends libneon27-dev libserf-dev

# get SVN source files and unpack in src/svn
# also install packages needed for installation
RUN wget https://archive.apache.org/dist/subversion/subversion-1.10.8.tar.bz2 && \
    mkdir -p src/svn && \
    tar -xvf subversion-1.10.8.tar.bz2 -C src/svn --strip-components=1 && \
    apt-get install -y --no-install-recommends libutf8proc-dev apache2 apache2-dev && \
    cd src/svn

EXPOSE 80 443 3690

# (Optional) Set a default command for the container.
CMD ["sleep", "infinity"]
