FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git

# Copy go mod files first
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY simple_go.go .

# Fix modules and build
RUN go mod tidy && CGO_ENABLED=0 go build -o cdnn-go .

# Final stage
FROM golang:1.21-alpine

WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/cdnn-go .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./cdnn-go"]