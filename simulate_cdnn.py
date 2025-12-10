#!/usr/bin/env python3

import time
import random
from elasticapm import Client

# Setup APM Client
apm = Client({
    'SERVICE_NAME': 'cdnn',
    'SERVER_URL': 'http://172.18.0.2:8200',
    'SECRET_TOKEN': 'Sk90WUI1c0JWLWZPczMxdWpMMjY6WkNiUlNRYUVkVDFLR2JBeHA1d0F6QQ==',
    'ENVIRONMENT': 'development',
    'DEBUG': True
})

print("🤖 CDNN Simulation with APM Monitoring Started")
print("=" * 50)


def cdnn_main_process():
    """Main CDNN processing pipeline"""
    print("🔄 Starting CDNN Pipeline...")

    # Simple transaction with manual spans
    apm.begin_transaction('cdnn_pipeline', 'request')

    try:
        # Step 1: Data preprocessing
        apm.capture_span('data_preprocessing', 'app')
        print("📊 Step 1: Data Preprocessing")
        time.sleep(2.0)  # Simulate work
        preprocessing_samples = random.randint(1000, 5000)
        print(f"   ✅ Processed {preprocessing_samples} samples")

        # Step 2: Database query
        print("💾 Step 2: Database Query")
        time.sleep(3.0)  # Simulate slow query
        db_count = random.randint(100, 1000)
        print(f"   ✅ Retrieved {db_count} records")

        # Step 3: ML Model Inference
        print("🧠 Step 3: ML Model Inference")
        time.sleep(5.0)  # Simulate slow ML inference
        batch_size = random.randint(32, 128)
        accuracy = random.uniform(0.85, 0.98)
        print(f"   ✅ Processed {batch_size} samples")
        print(f"   📈 Accuracy: {accuracy:.2%}")

        # Step 4: External API call
        print("🌐 Step 4: External API Integration")
        time.sleep(1.5)  # Simulate API call
        print(f"   ✅ API call successful")

        # Response formatting
        time.sleep(0.5)
        response = {
            'status': 'success',
            'preprocessing_samples': preprocessing_samples,
            'db_records': db_count,
            'batch_size': batch_size,
            'accuracy': accuracy
        }

        print(f"✅ CDNN Pipeline completed successfully!")

        # End transaction
        apm.end_transaction('success')
        return response

    except Exception as e:
        # Capture exception and end transaction with error
        apm.capture_exception()
        apm.end_transaction('error')
        print(f"❌ CDNN Pipeline failed: {str(e)}")
        return {'status': 'error', 'message': str(e)}

# Run simulation multiple times
for i in range(3):
    print(f"\n🚀 Simulation Round {i+1}/3")
    print("=" * 30)

    # Run main process
    result = cdnn_main_process()

    # Wait between simulations
    if i < 2:
        print(f"⏳ Waiting 5 seconds before next simulation...")
        time.sleep(5)

print("\n🎉 All simulations completed!")
print("📊 Check Kibana APM at: http://localhost:5601/app/apm")
print("🔍 Look for service: 'cdnn'")