#!/usr/bin/env python3

from elasticapm import Client
import time
import os

# Setup APM Client with secret token and service name 'cdnn'
apm = Client({
    'SERVICE_NAME': 'cdnn',
    'SERVER_URL': 'http://172.18.0.2:8200',
    'SECRET_TOKEN': 'Sk90WUI1c0JWLWZPczMxdWpMMjY6WkNiUlNRYUVkVDFLR2JBeHA1d0F6QQ==',
    'ENVIRONMENT': 'development',
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