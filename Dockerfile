FROM soedinglab/mmseqs2 as mmseqs

FROM golang:alpine as mmseqs-web-builder
RUN apk add --no-cache git gcc g++ musl-dev make zlib-dev bzip2-dev

RUN go get -u github.com/kardianos/govendor
WORKDIR /opt/mmseqs-web
ADD . .
RUN make all

FROM alpine:latest
LABEL maintainer="Milot Mirdita <milot@mirdita.de>"
RUN apk add --no-cache libstdc++ libgomp libbz2 zlib gawk bash ca-certificates tini

COPY --from=mmseqs /usr/local/bin/mmseqs_sse42 /usr/local/bin/mmseqs_sse42
COPY --from=mmseqs /usr/local/bin/mmseqs_avx2 /usr/local/bin/mmseqs_avx2
COPY --from=mmseqs /usr/local/bin/mmseqs /usr/local/bin/mmseqs

COPY --from=mmseqs-web-builder /opt/mmseqs-web/build/mmseqs-backend /usr/local/bin/mmseqs-web

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/mmseqs-web"]