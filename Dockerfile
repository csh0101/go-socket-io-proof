# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.18 as builder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies using go mod.
# This allows the container build to be cached.
# Copy the go mod and sum files.
COPY go.mod go.sum ./
# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed.
ENV GOPROXY="https://goproxy.cn,direct"
ENV GO111MODULE="on"
RUN go mod download

# Copy local code to the container image.
COPY . .

# Build the binary.
# -o myapp specifies the output file name, change as needed.
RUN CGO_ENABLED=0 GOOS=linux go build -v -o myapp

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/
# Use the official Alpine image for a lean production container.
# https://hub.docker.com/_/alpine
# Only copy the compiled application from the builder stage.
FROM alpine:latest as runtime
WORKDIR /root/

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/myapp .

# Copy any other files or directories you need for the application to run.
# For example, if you have static files or templates, make sure to copy them.
# COPY --from=builder /app/public /root/public
# COPY --from=builder /app/templates /root/templates

# Run the web service on container startup.
CMD ["./myapp"]


