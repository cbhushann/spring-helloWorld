FROM debian:bullseye

ARG KUBECTL_VERSION
ARG GRADLE_VERSION=8.4

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl unzip git docker.io apt-transport-https ca-certificates gnupg lsb-release software-properties-common

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bullseye main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y azure-cli && rm microsoft.gpg

# Install kubectl (passed in via build arg)
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Gradle manually
RUN curl -sSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt/ && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm gradle.zip

# Create user
RUN useradd -ms /bin/bash gradle && usermod -aG docker gradle
USER gradle
