FROM ubuntu:22.04
LABEL maintainer="José Costa"

# ARGS
ARG PHP_VERSION='7.3'
ARG MYSQL_VERSION='5'

ARG NODE_VERSION=14.20.1
ARG NPM_VERSION=latest
ARG IONIC_VERSION=latest
ARG CORDOVA_VERSION=latest

ARG GRADLE_VERSION=7.5
ARG ANDROID_BUILD_TOOLS_VERSION=30.0.3
ARG ANDROID_PLATFORMS="android-30"
ARG ANDROID_PLATFORM_DEFAULT="android-30"
    
# environment variables
ENV TZ="UTC"
ENV WEBHOME="/code/html"
ENV BUILD_PHP_VERSION=$PHP_VERSION \
    DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer \
    COMPOSER_MAX_PARALLEL_HTTP=24 \
    WEBUSER_HOME="/code/html" \
    PUID=9999 \
    PGID=9999

ENV NVM_DIR='/usr/local/nvm'
ENV BUILD_NODE_VERSION=$NODE_VERSION

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$BUILD_NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$BUILD_NODE_VERSION/bin:$PATH
ENV ANDROID_HOME /opt/android-sdk-linux
ENV GRADLE_HOME /opt/gradle
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/buildtools


RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/code/.bash_history" \
    && echo "$SNIPPET" >> "/root/.bashrc"

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# initial setup files
RUN mkdir -p /root/.cache
RUN chmod 777 -R /root/
RUN mkdir -p /code
RUN echo '~/first-setup.sh' >> /root/.bashrc

# -----------------------------------------------------------------------------
# Install
# -----------------------------------------------------------------------------

# dependencies.
RUN apt update

# base
RUN apt install -y --no-install-recommends \
        apt-utils \
        build-essential \
        locales \
        libffi-dev \
        libyaml-dev \
        ca-certificates software-properties-common \
        rsyslog systemd systemd-cron sudo iproute2 \
        gpg-agent

# php
RUN add-apt-repository universe
RUN add-apt-repository -y ppa:ondrej/php
RUN apt install -y php${BUILD_PHP_VERSION}

# python3 & generic tools
RUN apt install -y python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
    python3-yaml \
    libssl-dev \
	gnupg2 \
    curl \
    git \
    wget \
    unzip

# Install Java
RUN apt-get install -y --no-install-recommends openjdk-8-jdk

# Download an install the latest Android SDK
RUN \
  mkdir -p $ANDROID_HOME && cd $ANDROID_HOME \
  && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip \
  && unzip *tools*linux*.zip \
  && rm *tools*linux*.zip

# Download an install nvm
# https://github.com/creationix/nvm#install-script
RUN mkdir -p $NVM_DIR
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# -----------------------------------------------------------------------------
# Post-install
# -----------------------------------------------------------------------------

# node and npm LTS
RUN source $NVM_DIR/nvm.sh \
    && nvm install $BUILD_NODE_VERSION \
    && nvm alias default $BUILD_NODE_VERSION \
    && nvm use default 


# Download and install Gradle
RUN \
    mkdir -p /tmp/gradle/dist \
    && cd /tmp/gradle \
    && wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -o gradle*.zip \
    && cd /tmp/gradle/gradle-$GRADLE_VERSION \
    && rm -rf /opt/gradle \
    ; ls -d */ | sed 's/\/*$//g' | xargs -I{} cp -r {} /tmp/gradle/dist \
    && mv /tmp/gradle/dist /opt/gradle 
   
# android sdk
RUN \
    yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses \
    && yes | sdkmanager --sdk_root=$ANDROID_HOME  "platform-tools" "platforms;${ANDROID_PLATFORM_DEFAULT}" \
    && yes | sdkmanager --sdk_root=$ANDROID_HOME  "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    && ln -s $ANDROID_HOME/build-tools/${ANDROID_BUILD_TOOLS_VERSION} $ANDROID_HOME/buildtools

# RUN \
#   for i in ${ANDROID_PLATFORMS}; do yes | sdkmanager --sdk_root=$ANDROID_HOME "platforms;$i"; done
  
#profile & alias
RUN source $HOME/.profile

#node utils
RUN npm config set unsafe-perm=true \
    && npm install -g npm@"$NPM_VERSION" \
    && npm install -g cordova@"$CORDOVA_VERSION" ionic@"$IONIC_VERSION" qrcode-terminal npm i -g node-sass 

RUN cordova telemetry off

RUN php -S 0.0.0.0:80 > /code/logs/php.log 2>&1 &

# -----------------------------------------------------------------------------
# First setup
# -----------------------------------------------------------------------------
RUN curl --silent -o- https://raw.githubusercontent.com/josecosta-on/docker-setup/main/first-setup.sh > /code/.docker/first-setup.sh \
    && chmod +x /code/.docker/first-setup.sh;

EXPOSE 80 8100 35729 53703

CMD ["bash", "-l"]

# -----------------------------------------------------------------------------
# Clean up
# -----------------------------------------------------------------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man 
