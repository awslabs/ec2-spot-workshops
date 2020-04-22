FROM golang:alpine AS build

RUN apk --no-cache --update add git gcc musl-dev g++
RUN git clone -b 'v0.53' --single-branch --depth 1 https://github.com/gohugoio/hugo.git
WORKDIR /go/hugo
RUN go install --tags extended
WORKDIR /www
RUN git clone https://github.com/matcornic/hugo-theme-learn/ themes/learn
COPY . /www/
RUN /go/bin/hugo --destination /usr/share/nginx/html
CMD ["hugo", "server", "--bind", "0.0.0.0"]

FROM nginx:alpine
COPY --from=build /usr/share/nginx/html /usr/share/nginx/html