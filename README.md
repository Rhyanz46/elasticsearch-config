# Elastic Stack with APM Monitoring

Complete Elastic Stack setup with Application Performance Monitoring (APM) for Python and Go applications.

## 🚀 Project Structure

```
elastic/
├── 📁 example_python/          # Python APM applications (examples)
│   ├── simple_cdnn_test.py    # CDNN simulation with slow functions
│   ├── test_apm.py           # Basic APM testing
│   ├── simulate_cdnn.py      # Additional simulation
│   ├── Dockerfile            # Python Docker configuration
│   └── README.md             # Python documentation
├── 📁 example_go/             # Go APM applications (examples)
│   ├── simple_go.go          # CDNN HTTP service with APM
│   ├── main.go               # Alternative Go entrypoint
│   ├── go.mod                # Go module definition
│   ├── go.sum                # Go module checksums
│   ├── Dockerfile.go         # Go Docker configuration
│   └── README.md             # Go documentation
├── 🐳 docker-compose.yml     # Multi-service orchestration (clean & minimal)
├── 📄 .env.example           # Environment variables template
├── ⚙️ apm-server-ssl.yml     # APM server SSL configuration
├── 🛠️ restart.sh            # Service restart script
├── 📋 logs.sh                # Log viewing script
├── 🔧 reset-pw.sh           # Password reset utility
└── 📄 README.md             # This documentation
```

## 🏗️ Services

### Core Elastic Stack
- **Elasticsearch**: Data storage and search engine (port 9200)
- **Kibana**: Data visualization and dashboard (port 5601)
- **APM Server**: Application performance monitoring backend (port 8200)

### APM Applications
- **Python CDNN Service** (`python-cdnn`): Simulated ML pipeline with slow operations
- **Go CDNN Service** (`go-cdnn`): HTTP API with concurrent processing (port 8081)

## ⚙️ Configuration Overview

This project uses a **minimal and clean** configuration with only essential services:
- ✅ **5 active services** - no unused components
- ✅ **SSL/TLS enabled** - secure communication
- ✅ **Custom network** - isolated Docker environment
- ✅ **Environment-based** - easy configuration management

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
- **Secret Token**: Set in `.env` file (secure configuration)
- **Network**: Custom Docker network `elastic`

## 📊 APM Features

### Python Application (`python-cdnn` → service name: `cdnn`)
- **Data Loading**: 2-4 seconds operation (simulates large dataset processing)
- **ML Inference**: 3-7 seconds computation (simulates complex model training)
- **API Calls**: 1-3 seconds external requests (simulates third-party integrations)
- **Error Rate**: 10% random failures (for testing error handling)
- **Files**: `simple_cdnn_test.py`, `test_apm.py`, `simulate_cdnn.py`

### Go Application (`go-cdnn` → service name: `cdnn-go`)
- **HTTP Server**: REST API on port 8080 (exposed on host port 8081)
- **Concurrent Processing**: Multiple simultaneous requests handling
- **Transaction Tracing**: Full request lifecycle monitoring
- **Performance Metrics**: Detailed span timing for each operation
- **Files**: `simple_go.go`, `main.go` (alternative entrypoint)

### APM Integration
Both applications automatically send:
- ✅ Transaction traces (HTTP requests, function calls)
- ✅ Span timing (individual operations)
- ✅ Error tracking and reporting
- ✅ Custom metadata and labels
- ✅ Service health metrics

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

1. **Open Kibana**: http://localhost:5601
   - Login: `elastic` with password from `.env`
2. **Navigate to APM**: Click the rocket icon 🚀 or go to **Observability → APM**
3. **View Your Services**:
   - `cdnn` - Python application
   - `cdnn-go` - Go application
4. **Explore APM Features**:
   - **Service Overview**: Response times, throughput, error rates
   - **Transaction Traces**: Detailed execution paths
   - **Service Maps**: Dependencies between services
   - **Distributed Tracing**: End-to-end request tracking
   - **Error Analytics**: Root cause analysis
   - **Performance Metrics**: Resource usage monitoring

### Quick Monitoring Checklist
- ✅ Check service health status
- ✅ View recent transaction traces
- ✅ Monitor error rates and patterns
- ✅ Analyze response time distributions
- ✅ Set up alerts if needed

## 🛠️ Utility Scripts

- **`./restart.sh`**: Restart all services
- **`./logs.sh`**: View live logs
- **`./reset-pw.sh`**: Reset Elasticsearch passwords
- **`./start-apm-ssl.sh`**: Start APM server with SSL

## 📁 File Organization

### Core Configuration (Root Level)
- **`docker-compose.yml`** - Clean orchestration with 5 essential services
- **`.env.example`** - Environment variables template (copy to `.env`)
- **`apm-server-ssl.yml`** - APM server SSL configuration (active)
- **`README.md`** - This comprehensive documentation

### Application Code
- **`example_python/`** - Complete Python APM simulation examples (3 scripts + Docker)
- **`example_go/`** - Complete Go APM application examples (2 binaries + modules + Docker)

### Utility Scripts
- **`restart.sh`** - Quick service restart
- **`logs.sh`** - Live log monitoring
- **`reset-pw.sh`** - Password management
- **`start-apm-ssl.sh`** - APM server manual start

### Security & Certificates
- **Auto-generated** by setup service on first run
- **Stored in** Docker volumes (not in repository)
- **SSL/TLS enabled** for all services
- **Custom CA** for secure inter-service communication

## 🔒 Security Notes

- ⚠️ **Never commit `.env`** file with real passwords or tokens
- 🔑 Use `.env.example` as template only - configure your own secure values
- 🛡️ All services use SSL/TLS by default with auto-generated certificates
- 🚫 Change default passwords before deploying to production
- 🔐 **Secret tokens** are configured via environment variables only
- 📝 Never hard-code credentials in application code or documentation

## 📝 Environment Variables

Key variables in `.env`:
- `ELASTIC_PASSWORD` - Elasticsearch user password
- `KIBANA_PASSWORD` - Kibana system user password
- `APM_SECRET_TOKEN` - APM authentication token
- `LICENSE` - Set to `trial` for 30-day trial features
- `STACK_VERSION` - Elastic products version

## 🐛 Troubleshooting

### Common Issues & Solutions

1. **Services Not Starting:**
   ```bash
   # Check specific service logs
   docker compose logs <service-name>

   # Check all services status
   docker compose ps
   ```

2. **APM Data Not Appearing in Kibana:**
   ```bash
   # Check APM server logs
   docker compose logs apm-server

   # Verify application logs
   docker compose logs python-cdnn
   docker compose logs go-cdnn
   ```
   - ✅ Verify secret token matches between applications and APM server
   - ✅ Check network connectivity between services
   - ✅ Wait 2-3 minutes for data to appear in Kibana

3. **Certificate or SSL Issues:**
   ```bash
   # Clean restart to regenerate certificates
   docker compose down -v
   docker compose up -d
   ```

4. **Port Conflicts:**
   ```bash
   # Check if ports are in use
   netstat -tulpn | grep -E ":(9200|5601|8200|8081)"

   # Kill conflicting processes if needed
   sudo kill -9 <PID>
   ```

5. **Memory Issues:**
   ```bash
   # Check memory limits in .env
   # Increase ES_MEM_LIMIT, KB_MEM_LIMIT if needed
   ```

## 📚 Documentation

- [Elastic APM Documentation](https://www.elastic.co/guide/en/apm/get-started/current/index.html)
- [Python APM Agent](https://www.elastic.co/guide/en/apm/agent/python/current/index.html)
- [Go APM Agent](https://www.elastic.co/guide/en/apm/agent/go/current/index.html)

## 🎯 Project Highlights

### ✨ What Makes This Setup Special

- **🚀 Production Ready**: Complete SSL/TLS setup with secure authentication
- **🧹 Minimal & Clean**: Only essential services, no bloatware (880+ lines removed)
- **📊 Real APM Data**: Actual slow-function simulations for realistic testing
- **🔄 Dual Language**: Both Python and Go implementations for comparison
- **📚 Well Documented**: Comprehensive guides and troubleshooting
- **🛠️ Easy Management**: Utility scripts for common operations

### 🔧 Technical Excellence

- **Multi-stage Docker builds** for optimized images
- **Custom Docker network** for isolated services
- **Auto-generated certificates** for secure communication
- **Environment-driven configuration** for flexibility
- **Health checks** for service reliability
- **Volume persistence** for data durability

### 📈 Performance Testing

The included APM simulations provide realistic performance scenarios:
- **Variable response times** (2-16 seconds total)
- **Concurrent request handling**
- **Error injection** (10% failure rate)
- **Resource utilization monitoring**
- **Distributed tracing** across service boundaries

---

## 🚀 Quick Reference

| Service | Port | Access | Purpose |
|---------|------|--------|---------|
| Elasticsearch | 9200 | HTTP API | Data storage & search |
| Kibana | 5601 | Web UI | Data visualization & APM |
| APM Server | 8200 | HTTP API | APM data ingestion |
| Go Application | 8081 | HTTP API | APM monitoring test |
| Python Application | - | Background | APM simulation runs |

**Default Credentials:**
- **Elasticsearch**: `elastic` (password from `.env`)
- **Kibana**: `kibana_system` (password from `.env`)
- **APM Token**: Configured in `.env` file (secure)

---

🤖 **Generated with [Claude Code](https://claude.com/claude-code)**