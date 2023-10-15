FROM lscr.io/linuxserver/blender:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    sudo \
    zip \
    xz-utils \
    libx11-dev \
    libxi-dev \
    libxxf86vm-dev \
    libfontconfig1 \
    libxrender1 \
    libgl1-mesa-glx

# Download and install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm ./aws/install

# Copy FFmpeg to the root of the container and unzip it
RUN curl "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz" -o "ffmpeg.tar.xz" && \
    tar -xvf ffmpeg.tar.xz --strip-components=1 -C /bin && \
    rm -rf ffmpeg.tar.xz && \
	  rm -rf ffmpeg

# Copy the script to the root of the container and give it permission to be executed
COPY ./render.sh /
RUN chmod +x /render.sh

ENTRYPOINT ["/render.sh"]
