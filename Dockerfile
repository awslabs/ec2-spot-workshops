FROM golang:alpine AS hugo

RUN apk --no-cache --update add git gcc musl-dev g++
RUN git clone -b 'v0.53' --single-branch --depth 1 https://github.com/gohugoio/hugo.git
WORKDIR /go/hugo
RUN go install --tags extended
WORKDIR /www
RUN git clone https://github.com/matcornic/hugo-theme-learn/ themes/learn
CMD ["hugo", "server", "--bind", "0.0.0.0"]

FROM hugo AS build
COPY . /www/
RUN /go/bin/hugo --destination /output

FROM nginx:alpine
COPY --from=build /output /usr/share/nginx/html