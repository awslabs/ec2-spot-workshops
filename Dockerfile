FROM golang:alpine

RUN apk --no-cache --update add git gcc musl-dev g++
RUN git clone -b 'v0.58.3' --single-branch --depth 1 https://github.com/gohugoio/hugo.git
WORKDIR /go/hugo
RUN go install --tags extended
WORKDIR /www
RUN git clone https://github.com/matcornic/hugo-theme-learn/ themes/learn
COPY . /www/
ENTRYPOINT ["hugo", "server", "--bind", "0.0.0.0"]
CMD [""]