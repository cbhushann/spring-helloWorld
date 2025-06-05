# Use a Debian base image
FROM debian:bullseye

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Build arg for kubectl version
ARG KUBECTL_VERSION=v1.33.1

# Install core dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
        git \
        docker.io \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        python3-pip \
        openjdk-17-jdk \
        gradle && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME explicitly
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Azure CLI via pip
RUN pip3 install --upgrade pip && \
    pip3 install azure-cli

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Add user to run Jenkins agent
RUN useradd -ms /bin/bash gradle
USER gradle
WORKDIR /home/gradle
