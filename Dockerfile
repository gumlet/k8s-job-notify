FROM golang:alpine AS builder

WORKDIR /go/src/github.com/gumlet/k8s-job-notify
ADD . /go/src/github.com/gumlet/k8s-job-notify
RUN go build -o /app .

FROM alpine

COPY --from=builder /app /app
ENTRYPOINT ["/app"]