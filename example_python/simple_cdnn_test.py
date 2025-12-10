#!/usr/bin/env python3

import time
import random
import os
from elasticapm import Client

# Setup APM Client
apm = Client({
    'SERVICE_NAME': os.getenv('ELASTIC_APM_SERVICE_NAME', 'cdnn'),
    'SERVER_URL': os.getenv('ELASTIC_APM_SERVER_URL', 'http://apm-server:8200'),
    'SECRET_TOKEN': os.getenv('ELASTIC_APM_SECRET_TOKEN'),
    'ENVIRONMENT': os.getenv('ELASTIC_APM_ENVIRONMENT', 'development'),
    'DEBUG': True
})

print("🤖 Simple CDNN Simulation with APM")
print("=" * 40)

def slow_function_1():
    """Simulate slow function 1 - Data Loading"""
    time.sleep(random.uniform(2.0, 4.0))
    return f"Loaded {random.randint(1000, 5000)} records"

def slow_function_2():
    """Simulate slow function 2 - ML Processing"""
    time.sleep(random.uniform(3.0, 7.0))
    return f"Processed {random.randint(32, 128)} samples with {random.uniform(0.8, 0.95):.2f} accuracy"

def slow_function_3():
    """Simulate slow function 3 - API Call"""
    time.sleep(random.uniform(1.0, 3.0))
    return f"API response time: {random.uniform(0.5, 2.0):.2f}s"

# Main process
try:
    print("🔄 Starting CDNN Process...")

    # Manual transaction tracking
    print("📊 Step 1: Loading data...")
    result1 = slow_function_1()
    print(f"   ✅ {result1}")

    print("🧠 Step 2: ML Processing...")
    result2 = slow_function_2()
    print(f"   ✅ {result2}")

    print("🌐 Step 3: API Call...")
    result3 = slow_function_3()
    print(f"   ✅ {result3}")

    print("🎉 CDNN Process Completed Successfully!")

    # Capture success
    apm.capture_message("CDNN pipeline completed successfully", level='info')

except Exception as e:
    print(f"❌ Error: {str(e)}")
    # Capture error
    apm.capture_exception()

print("\n📊 Check Kibana APM at: http://localhost:5601/app/apm")
print("🔍 Look for service: 'cdnn'")