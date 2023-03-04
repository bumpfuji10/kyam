# syntax = docker/dockerfile:experimental

# Dockerfile used to build a deployable image for a Rails application.
# Adjust as required.
#
# Common adjustments you may need to make over time:
#  * Modify version numbers for Ruby, Bundler, and other products.
#  * Add library packages needed at build time for your gems, node modules.
#  * Add deployment packages needed by your application
#  * Add (often fake) secrets needed to compile your assets

#######################################################################

# Learn more about the chosen Ruby stack, Fullstaq Ruby, here:
#   https://github.com/evilmartians/fullstaq-ruby-docker.
#
# We recommend using the highest patch level for better security and
# performance.

ARG RUBY_VERSION=2.7.4
ARG VARIANT=jemalloc-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

LABEL fly_launch_runtime="rails"

ARG NODE_VERSION=16.15.1
ARG YARN_VERSION=1.22.19
ARG BUNDLER_VERSION=2.4.4

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH ${BUNDLE_PATH}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

RUN mkdir /app
WORKDIR /app
RUN mkdir -p tmp/pids

RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:/usr/local/bin:$PATH
RUN volta install node@${NODE_VERSION} yarn@${YARN_VERSION} && \
    gem update --system --no-document && \
    gem install -N bundler -v ${BUNDLER_VERSION}

#######################################################################

# install packages only needed at build time

FROM base as build_deps

ARG BUILD_PACKAGES="git build-essential libpq-dev wget vim curl gzip xz-utils libsqlite3-dev"
ENV BUILD_PACKAGES ${BUILD_PACKAGES}

RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${BUILD_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

#######################################################################

# install gems

FROM build_deps as gems

COPY Gemfile* ./
RUN bundle install && rm -rf vendor/bundle/ruby/*/cache

#######################################################################

FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG IM_VERSION=7.1.0-62
ARG LIB_HEIF_VERSION=1.15.1
ARG LIB_AOM_VERSION=3.6.0
ARG LIB_WEBP_VERSION=1.3.0
ARG LIBJXL_VERSION=0.8.1

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends git make pkg-config autoconf curl cmake clang libomp-dev ca-certificates automake \
    # libaom
    yasm \
    # libheif
    libde265-0 libde265-dev libjpeg62-turbo libjpeg62-turbo-dev x265 libx265-dev libtool \
    # libwebp
    libsdl1.2-dev libgif-dev \
    # libjxl
    libbrotli-dev \
    # IM
    libpng16-16 libpng-dev libjpeg62-turbo libjpeg62-turbo-dev libgomp1 ghostscript libxml2-dev libxml2-utils libtiff-dev libfontconfig1-dev libfreetype6-dev fonts-dejavu liblcms2-2 liblcms2-dev \
    # Install manually to prevent deleting with -dev packages
    libxext6 libbrotli1 && \
    export CC=clang CXX=clang++ && \
    # Building libjxl
    git clone -b v${LIBJXL_VERSION} https://github.com/libjxl/libjxl.git --depth 1 --recursive --shallow-submodules && \
    cd libjxl && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF .. && \
    cmake --build . -- -j$(nproc) && \
    cmake --install . && \
    cd ../../ && \
    rm -rf libjxl && \
    ldconfig /usr/local/lib && \
    # Building libwebp
    git clone -b v${LIB_WEBP_VERSION} --depth 1 https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && \
    ./autogen.sh && ./configure --enable-shared --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux --enable-static=no && \
    make && make install && \
    ldconfig /usr/local/lib && \
    cd ../ && rm -rf libwebp && \
    # Building libaom
    git clone -b v${LIB_AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom && \
    mkdir build_aom && \
    cd build_aom && \
    cmake ../aom/ -DENABLE_TESTS=0 -DBUILD_SHARED_LIBS=1 && make && make install && \
    ldconfig /usr/local/lib && \
    cd .. && \
    rm -rf aom && \
    rm -rf build_aom && \
    # Building libheif
    curl -L https://github.com/strukturag/libheif/releases/download/v${LIB_HEIF_VERSION}/libheif-${LIB_HEIF_VERSION}.tar.gz -o libheif.tar.gz && \
    tar -xzvf libheif.tar.gz && cd libheif-${LIB_HEIF_VERSION}/ && ./autogen.sh && ./configure && make && make install && cd .. && \
    ldconfig /usr/local/lib && \
    rm -rf libheif-${LIB_HEIF_VERSION} && rm libheif.tar.gz && \
    # Building ImageMagick
    git clone -b ${IM_VERSION} --depth 1 https://github.com/ImageMagick/ImageMagick.git && \
    cd ImageMagick && \
    ./configure --without-magick-plus-plus --disable-docs --disable-static --with-tiff --with-jxl && \
    make && make install && \
    ldconfig /usr/local/lib && \
    apt-get remove --autoremove --purge -y make cmake clang clang-11 curl yasm git autoconf automake pkg-config libpng-dev libjpeg62-turbo-dev libde265-dev libx265-dev libxml2-dev libtiff-dev libfontconfig1-dev libfreetype6-dev liblcms2-dev libsdl1.2-dev libgif-dev libbrotli-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /ImageMagick

WORKDIR /imgs

ENTRYPOINT ["convert"]

#######################################################################

# install node modules

FROM build_deps as node_modules

COPY package*json ./
COPY yarn.* ./
RUN yarn install

#######################################################################

# install deployment packages

FROM base

ARG DEPLOY_PACKAGES="postgresql-client file vim curl gzip libsqlite3-0"
ENV DEPLOY_PACKAGES=${DEPLOY_PACKAGES}

RUN --mount=type=cache,id=prod-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=prod-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    ${DEPLOY_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# copy installed gems
COPY --from=gems /app /app
COPY --from=gems /usr/lib/fullstaq-ruby/versions /usr/lib/fullstaq-ruby/versions
COPY --from=gems /usr/local/bundle /usr/local/bundle

# copy installed node modules
COPY --from=node_modules /app/node_modules /app/node_modules

#######################################################################

# Deploy your application
COPY . .

# Adjust binstubs to run on Linux and set current working directory
RUN chmod +x /app/bin/* && \
    sed -i 's/ruby.exe\r*/ruby/' /app/bin/* && \
    sed -i 's/ruby\r*/ruby/' /app/bin/* && \
    sed -i '/^#!/aDir.chdir File.expand_path("..", __dir__)' /app/bin/*

# The following enable assets to precompile on the build server.  Adjust
# as necessary.  If no combination works for you, see:
# https://fly.io/docs/rails/getting-started/existing/#access-to-environment-variables-at-build-time
ENV SECRET_KEY_BASE 1
# ENV AWS_ACCESS_KEY_ID=1
# ENV AWS_SECRET_ACCESS_KEY=1

# Run build task defined in lib/tasks/fly.rake
ARG BUILD_COMMAND="bin/rails fly:build"
RUN ${BUILD_COMMAND}

# Default server start instructions.  Generally Overridden by fly.toml.
ENV PORT 8080
ARG SERVER_COMMAND="bin/rails fly:server"
ENV SERVER_COMMAND ${SERVER_COMMAND}
CMD ${SERVER_COMMAND}
