# Python APM Simulation

This folder contains Python applications for APM (Application Performance Monitoring) simulation with Elastic Stack.

## Files

- `simple_cdnn_test.py` - CDNN simulation with slow functions for APM testing
- `test_apm.py` - Basic APM agent testing
- `simulate_cdnn.py` - Additional CDNN simulation script

## Configuration

- **Service Name**: `cdnn`
- **Secret Token**: Configured via environment variable
- **APM Server**: `http://apm-server:8200`

## Running

```bash
# Run basic APM test
python test_apm.py

# Run CDNN simulation
python simple_cdnn_test.py

# Run additional simulation
python simulate_cdnn.py
```

## Requirements

```bash
pip install elastic-apm
```

## Performance Simulation

The CDNN simulation includes:
- **Data Loading**: 2-4 seconds
- **ML Inference**: 3-7 seconds
- **API Calls**: 1-3 seconds
- **Random Errors**: 10% failure rate

All transactions and spans are automatically sent to APM server for visualization in Kibana.