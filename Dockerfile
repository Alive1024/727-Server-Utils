# ===========================
# Dockerfile for "727-base"
# ===========================
FROM ubuntu:latest

# ======== Install necessary software ========
# - sudo
# - SSH
# - ffmpeg, libsm6, libxext6 are dependencies of opencv-python (cv2)
RUN apt update && \
    apt install --quiet --yes --no-install-recommends sudo openssh-client openssh-server ffmpeg libsm6 libxext6

# ======== Basic settings ========
# - change password of root
# - add new user "tensor"
# - set timezone
RUN echo "root:123456" | chpasswd && \
    useradd -ms /bin/bash -g sudo tensor && \
    echo "tensor:123456" | chpasswd && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' >/etc/timezone

# Declare port
EXPOSE 22

# Start SSH service and enter shell when `docker run ...`
ENTRYPOINT service ssh start && /bin/bash
