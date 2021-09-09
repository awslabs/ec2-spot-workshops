FROM nytimes/blender:latest

RUN apt-get update && \
    apt-get install -y curl sudo zip
CMD /bin/bash
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm ./aws/install
COPY ./render.sh /
RUN chmod +x /render.sh
ENTRYPOINT ["/render.sh"]
