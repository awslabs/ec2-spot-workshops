FROM golang:alpine AS build

RUN apk --no-cache --update add git gcc musl-dev g++
RUN git clone -b 'v0.53' --single-branch --depth 1 https://github.com/gohugoio/hugo.git
WORKDIR /go/hugo
RUN go install --tags extended
WORKDIR /www
RUN git clone https://github.com/matcornic/hugo-theme-learn/ themes/learn
COPY . /www/
CMD ["hugo", "server", "-D", "--bind", "0.0.0.0", "--watch"]

FROM alpine
## TODO: Are all those headers really neccessary?
RUN apk --no-cache --update add gcc g++ musl-dev ca-certificates
COPY --from=build /go/bin/hugo /hugo
COPY --from=build /www/themes/learn /www/themes/learn
WORKDIR /www
COPY . /www
CMD ["/hugo", "server", "-D", "--bind", "0.0.0.0"]