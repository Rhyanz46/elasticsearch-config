#!/usr/bin/env python3

from elasticapm import Client
import time
import os

# Setup APM Client with secret token and service name 'cdnn'
apm = Client({
    'SERVICE_NAME': os.getenv('ELASTIC_APM_SERVICE_NAME', 'cdnn'),
    'SERVER_URL': os.getenv('ELASTIC_APM_SERVER_URL', 'http://apm-server:8200'),
    'SECRET_TOKEN': os.getenv('ELASTIC_APM_SECRET_TOKEN'),
    'ENVIRONMENT': os.getenv('ELASTIC_APM_ENVIRONMENT', 'development'),
    'DEBUG': True
})

print("APM Client created. Sending sample data...")

# Begin a transaction
client = apm
client.begin_transaction('request')

# Send a custom event
client.capture_message('Test message from APM', level='info')

# End the transaction
client.end_transaction('cdnn-process-request', 'success')

print("Sample transaction sent!")

print("APM test complete!")
apm.close()