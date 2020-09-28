## First stage will build hugo
FROM golang:alpine AS hugo

# ARG can be changed at build-time; will be in the environment within `docker build` context, not afterwards
ARG HUGO_VER="v0.53"

RUN apk --no-cache --update add git gcc musl-dev g++
RUN git clone -b ${HUGO_VER} --single-branch --depth 1 https://github.com/gohugoio/hugo.git
WORKDIR /go/hugo
RUN go install --tags extended
WORKDIR /www
RUN git clone https://github.com/matcornic/hugo-theme-learn/ themes/learn
CMD ["hugo", "server", "--bind", "0.0.0.0"]

## Second stage will use the hugo container to build the website
FROM hugo AS build
COPY . /www/
RUN /go/bin/hugo --destination /output

## Final step serves the static website
FROM nginx:alpine
COPY --from=build /output /usr/share/nginx/html