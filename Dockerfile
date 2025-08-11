FROM snyk/snyk:linux

# Versions
ARG PYTHON_VERSION=3.11.9
ARG NODE_MAJOR=18
ARG MAVEN_VERSION=3.9.6
ARG GRADLE_VERSION=7.6.4

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/java/openjdk
ENV MAVEN_DIR=/opt/maven
ENV PATH=$JAVA_HOME/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin:$MAVEN_DIR/bin:$PATH

# Install dependencies: Python 3.11 (from source), Java 8, Node.js 18, Gradle, Maven, snyk-to-html
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget unzip gnupg ca-certificates \
    build-essential zlib1g-dev libssl-dev libncurses-dev \
    libffi-dev libsqlite3-dev libreadline-dev libbz2-dev xz-utils \
    openjdk-8-jdk \
    && \
    # Symlink JAVA_HOME to installed JDK for consistency
    mkdir -p /opt/java && ln -s /usr/lib/jvm/java-8-openjdk-amd64 /opt/java/openjdk && \
    \
    # Install Python 3.11
    curl -fsSL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz -o python.tgz && \
    tar -xzf python.tgz && cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && make -j"$(nproc)" && make altinstall && \
    cd .. && rm -rf python.tgz Python-${PYTHON_VERSION} && \
    ln -s /usr/local/bin/python3.11 /usr/local/bin/python && \
    ln -s /usr/local/bin/pip3.11 /usr/local/bin/pip && \
    \
    # Install Node.js 18
    curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get install -y nodejs && \
    \
    # Install Gradle
    curl -fsSL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt/gradle && \
    rm gradle.zip && \
    \
    # Install Maven
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz && \
    mkdir -p ${MAVEN_DIR} && \
    tar -xzf /tmp/maven.tar.gz -C ${MAVEN_DIR} --strip-components=1 && \
    rm -f /tmp/maven.tar.gz && \
    \
    # Install snyk-to-html
    npm install -g snyk-to-html && \
    \
    # Cleanup
    apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Confirm versions
RUN java -version && mvn -version && gradle --version && python --version && pip --version && node --version && snyk-to-html --help