FROM debian:bullseye

# Accept build arguments
ARG KUBECTL_VERSION
ARG GRADLE_VERSION=8.4

USER root

# Install core dependencies
RUN apt-get update && apt-get install -y \
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
    openjdk-17-jdk

# Install Azure CLI via pip (cross-platform safe)
RUN pip3 install --upgrade pip && \
    pip3 install azure-cli

# Set JAVA_HOME so Gradle knows where Java is
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="${JAVA_HOME}/bin:$PATH"

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Gradle manually
RUN curl -sSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt/ && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle && \
    rm gradle.zip

# Create gradle user and assign Docker group
RUN useradd -ms /bin/bash gradle && usermod -aG docker gradle

USER gradle
