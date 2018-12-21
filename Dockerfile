FROM gcc:7.3.0 as build

# Install things required to build opencv:
#
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git libgtk2.0-dev pkg-config libavcodec-dev \
    libavformat-dev libswscale-dev python-dev \
    python-numpy libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libdc1394-22-dev unzip
RUN mkdir -p /cmake/ \
    && cd /cmake/ \
    && wget -nc https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh \
    && chmod +x cmake-3.10.2-Linux-x86_64.sh \
    && mkdir cmake \
    && ./cmake-3.10.2-Linux-x86_64.sh --skip-license
RUN cd /cmake \
    && ln -s /cmake/bin/* /usr/local/bin/
RUN mkdir -p /opencv \
    && cd /opencv \
    && wget -nc https://github.com/opencv/opencv/archive/3.4.0.tar.gz \
    && tar -xvzf 3.4.0.tar.gz
RUN cd /opencv/opencv-3.4.0 \
    && mkdir -p release \
    && cd release \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j8 \
    && make install/strip
#Install glm for use in projects compiled with this container.
RUN mkdir -p /glm \
    && cd /glm \
    && wget -nc https://github.com/g-truc/glm/releases/download/0.9.8.5/glm-0.9.8.5.zip \
    && unzip glm-0.9.8.5.zip


# Create the actual image to use to build project
#
FROM gcc:7.2.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git libgtk2.0-dev pkg-config libavcodec-dev \
    libavformat-dev libswscale-dev python-dev \
    python-numpy libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libdc1394-22-dev

# Create target directories
RUN mkdir -p /cmake/bin \
    && mkdir -p /cmake/share \
    && mkdir -p /opencv/opencv-3.4.0 \
    && mkdir -p /glm

# Setup cmake from builder
COPY --from=build /cmake/bin /cmake/bin
COPY --from=build /cmake/share /cmake/share
RUN cd /cmake \
    && ln -s /cmake/bin/* /usr/local/bin/

# Setup opencv from builder
COPY --from=build /usr/local/include/opencv /usr/local/include/opencv
COPY --from=build /usr/local/include/opencv2 /usr/local/include/opencv2
COPY --from=build /usr/local/bin/opencv* /usr/local/bin/
COPY --from=build /usr/local/lib/libopencv* /usr/local/lib/
COPY --from=build /usr/local/share/OpenCV /usr/local/share/OpenCV

