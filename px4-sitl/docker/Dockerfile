FROM ubuntu:22.04
LABEL description="ROS2 Humble + Gazebo Harmonic + PX4 SITL"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Mexico_City
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DISPLAY=:99
ENV RUNS_IN_DOCKER=true
ENV ROS_DISTRO=humble

EXPOSE 14556/udp
EXPOSE 14557/udp

RUN apt-get update && apt-get install -y \
    curl wget git vim \
    build-essential cmake ninja-build ccache \
    python3 python3-pip \
    lsb-release gnupg2 ca-certificates \
    software-properties-common \
    xvfb \
    libgl1-mesa-glx libgl1-mesa-dri libegl-mesa0 \
    libgles2-mesa libdrm2 libva2 \
    libx11-6 libxext6 libxrender1 libxi6 \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://packages.osrfoundation.org/gazebo.gpg \
        -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
        http://packages.osrfoundation.org/gazebo/ubuntu-stable jammy main" \
        > /etc/apt/sources.list.d/gazebo-stable.list && \
    apt-get update && apt-get install -y gz-harmonic \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
        | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
        http://packages.ros.org/ros2/ubuntu jammy main" \
        > /etc/apt/sources.list.d/ros2.list && \
    apt-get update && apt-get install -y \
        ros-humble-desktop \
        ros-humble-ros-gzharmonic \
        python3-colcon-common-extensions \
        python3-rosdep \
        python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true && rosdep update

RUN pip3 install \
    empy==3.3.4 \
    jinja2 \
    pyros-genmsg \
    pyulog \
    toml \
    packaging \
    kconfiglib \
    jsonschema \
    future

RUN git clone -b v2.4.3 https://github.com/eProsima/Micro-XRCE-DDS-Agent.git /tmp/xrce && \
    cmake -B /tmp/xrce/build /tmp/xrce && \
    cmake --build /tmp/xrce/build --parallel $(nproc) && \
    cmake --install /tmp/xrce/build && \
    ldconfig && \
    rm -rf /tmp/xrce

ENV LIBGL_ALWAYS_SOFTWARE=0
ENV MESA_GL_VERSION_OVERRIDE=4.5
ENV GALLIUM_DRIVER=iris
ENV GZ_VERSION=harmonic

RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc

RUN git config --global --add safe.directory '*'
RUN mkdir -p /px4 /ros2_ws/src /gz_models
WORKDIR /px4

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
