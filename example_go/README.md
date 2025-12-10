# Go APM Application

This folder contains a Go application with APM (Application Performance Monitoring) integration for Elastic Stack.

## Files

- `simple_go.go` - Main CDNN service application with APM monitoring
- `Dockerfile.go` - Docker configuration for building the Go application
- `go.mod` - Go module definition
- `go.sum` - Go module checksums

## Configuration

- **Service Name**: `cdnn-go`
- **Environment**: `development`
- **Secret Token**: Configured via environment variable
- **APM Server**: `http://apm-server:8200`
- **HTTP Port**: 8080

## Building and Running

### Build Docker Image
```bash
docker build -f Dockerfile.go -t cdnn-go .
```

### Run Container
```bash
docker run --rm -d --name cdnn-go-test \
  --network elastic \
  -p 8081:8080 \
  -e ELASTIC_APM_SECRET_TOKEN=Sk90WUI1c0JWLWZPczMxdWpMMjY6WkNiUlNRYUVkVDFLR2JBeHA1d0F6QQ== \
  -e ELASTIC_APM_SERVER_URL=http://apm-server:8200 \
  cdnn-go
```

### Test Application
```bash
curl http://localhost:8081/
```

## Performance Simulation

The CDNN service includes:
- **SlowDataLoading**: 2-5 seconds, loads 1000-5000 records
- **SlowMLInference**: 5-9.5 seconds, model loading + inference
- **SlowAPICall**: 1-2.5 seconds, external API simulation

## HTTP Endpoints

- `GET /` - Triggers complete CDNN pipeline with APM monitoring

## APM Integration

The application uses `go.elastic.co/apm/v2` for:
- Transaction tracking for HTTP requests
- Span monitoring for individual functions
- Error capture and reporting
- Performance metrics collection

All APM data is automatically sent to the APM server for visualization in Kibana.