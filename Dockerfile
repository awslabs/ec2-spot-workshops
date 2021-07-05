FROM golang:alpine

RUN apk --no-cache --update add git gcc musl-dev g++ wget
WORKDIR /tmp
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.53/hugo_0.53_Linux-64bit.tar.gz && \
    tar -xf hugo_0.53_Linux-64bit.tar.gz hugo && \
    rm -rf hugo_0.53_Linux-64bit.tar.gz && \
    cp hugo /usr/bin/hugo
WORKDIR /www
RUN git clone https://github.com/matcornic/hugo-theme-learn/ themes/learn
COPY . /www/
ENTRYPOINT ["hugo", "server", "--bind", "0.0.0.0"]
CMD [""]