# Python APM Application Dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir elastic-apm

# Copy Python scripts
COPY simple_cdnn_test.py .
COPY test_apm.py .
COPY simulate_cdnn.py .

# Default command - run basic APM test
CMD ["python", "test_apm.py"]