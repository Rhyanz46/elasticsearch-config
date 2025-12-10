# Elastic Stack with APM Monitoring

Complete Elastic Stack setup with Application Performance Monitoring (APM) for Python and Go applications.

## 🚀 Project Structure

```
elastic/
├── 📁 python/                 # Python APM applications
│   ├── simple_cdnn_test.py    # CDNN simulation with slow functions
│   ├── test_apm.py           # Basic APM testing
│   ├── simulate_cdnn.py      # Additional simulation
│   ├── Dockerfile            # Python Docker configuration
│   └── README.md             # Python documentation
├── 📁 go/                     # Go APM applications
│   ├── simple_go.go          # CDNN HTTP service with APM
│   ├── main.go               # Alternative Go entrypoint
│   ├── go.mod                # Go module definition
│   ├── go.sum                # Go module checksums
│   ├── Dockerfile.go         # Go Docker configuration
│   └── README.md             # Go documentation
├── 🐳 docker-compose.yml     # Multi-service orchestration
├── 📄 .env.example           # Environment template
├── ⚙️ apm-server*.yml       # APM server configurations
├── 🛠️ restart.sh            # Service restart script
├── 📋 logs.sh                # Log viewing script
└── 🔧 reset-pw.sh           # Password reset utility
```

## 🏗️ Services

### Core Elastic Stack
- **Elasticsearch**: Data storage and search engine
- **Kibana**: Data visualization and dashboard
- **APM Server**: Application performance monitoring backend

### APM Applications
- **Python CDNN Service** (`cdnn`): Simulated ML pipeline with slow operations
- **Go CDNN Service** (`cdnn-go`): HTTP API with concurrent processing

## ⚙️ Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   # Edit .env with your passwords and settings
   ```

2. **Start all services:**
   ```bash
   docker compose up -d
   ```

3. **Monitor logs:**
   ```bash
   ./logs.sh
   ```

4. **Access services:**
   - Kibana: http://localhost:5601
   - Go API: http://localhost:8081
   - APM Server: http://localhost:8200

## 🔐 Default Configuration

- **License**: Basic (upgrade to trial if needed)
- **SSL/TLS**: Enabled for all services
- **Secret Token**: `Sk90WUI1c0JWLWZPczMxdWpMMjY6WkNiUlNRYUVkVDFLR2JBeHA1d0F6QQ==`
- **Network**: Custom Docker network `elastic`

## 📊 APM Features

### Python Application (`cdnn`)
- **Data Loading**: 2-4 seconds operation
- **ML Inference**: 3-7 seconds computation
- **API Calls**: 1-3 seconds external requests
- **Error Rate**: 10% random failures for testing

### Go Application (`cdnn-go`)
- **HTTP Server**: REST API on port 8080
- **Concurrent Processing**: Multiple simultaneous requests
- **Transaction Tracing**: Full request lifecycle monitoring
- **Performance Metrics**: Detailed span timing

## 🧪 Testing

### Python APM Test
```bash
# Test Python APM manually
docker compose exec python-cdnn python simple_cdnn_test.py
```

### Go API Test
```bash
# Test Go API manually
curl http://localhost:8081/
```

### Concurrent Load Test
```bash
# Test multiple concurrent requests
for i in {1..5}; do curl http://localhost:8081/ & done; wait
```

## 📈 Monitoring in Kibana

1. Open Kibana: http://localhost:5601
2. Navigate to **APM** (or click the rocket icon 🚀)
3. View services:
   - `cdnn` - Python application
   - `cdnn-go` - Go application
4. Explore:
   - Service maps
   - Transaction traces
   - Performance metrics
   - Error rates

## 🛠️ Utility Scripts

- **`./restart.sh`**: Restart all services
- **`./logs.sh`**: View live logs
- **`./reset-pw.sh`**: Reset Elasticsearch passwords
- **`./start-apm-ssl.sh`**: Start APM server with SSL

## 📁 File Organization

### Configuration Files
- `.env.example` - Environment variables template
- `docker-compose.yml` - Multi-service orchestration
- `apm-server*.yml` - APM server configurations

### Application Code
- `python/` - All Python APM simulation code
- `go/` - All Go APM application code

### Certificates & Security
- Generated automatically by setup service
- Stored in Docker volumes
- SSL/TLS enabled for all services

## 🔒 Security Notes

- ⚠️ **Never commit `.env`** file with real passwords
- 🔑 Use `.env.example` as template only
- 🛡️ All services use SSL/TLS by default
- 🚫 Default passwords should be changed in production

## 📝 Environment Variables

Key variables in `.env`:
- `ELASTIC_PASSWORD` - Elasticsearch user password
- `KIBANA_PASSWORD` - Kibana system user password
- `APM_SECRET_TOKEN` - APM authentication token
- `LICENSE` - Set to `trial` for 30-day trial features
- `STACK_VERSION` - Elastic products version

## 🐛 Troubleshooting

1. **Services not starting:**
   ```bash
   docker compose logs <service-name>
   ```

2. **APM data not appearing:**
   - Check APM server logs
   - Verify secret token matches
   - Check network connectivity

3. **Certificate issues:**
   ```bash
   docker compose down
   docker volume prune
   docker compose up -d
   ```

## 📚 Documentation

- [Elastic APM Documentation](https://www.elastic.co/guide/en/apm/get-started/current/index.html)
- [Python APM Agent](https://www.elastic.co/guide/en/apm/agent/python/current/index.html)
- [Go APM Agent](https://www.elastic.co/guide/en/apm/agent/go/current/index.html)

---

🤖 **Generated with [Claude Code](https://claude.com/claude-code)**