#!/bin/bash

# Generate certificates inside container
echo "Generating SSL certificates for APM server..."

# Create directories
mkdir -p /usr/share/apm-server/certs/ca
mkdir -p /usr/share/apm-server/certs/apm-server

# Generate CA
openssl genrsa -out /usr/share/apm-server/certs/ca/ca.key 2048
openssl req -x509 -new -nodes -key /usr/share/apm-server/certs/ca/ca.key -sha256 -days 3650 -out /usr/share/apm-server/certs/ca/ca.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=APM-CA"

# Generate server certificate
openssl genrsa -out /usr/share/apm-server/certs/apm-server/apm-server.key 2048
openssl req -new -key /usr/share/apm-server/certs/apm-server/apm-server.key -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" -out /usr/share/apm-server/certs/apm-server/apm-server.csr
openssl x509 -req -in /usr/share/apm-server/certs/apm-server/apm-server.csr -CA /usr/share/apm-server/certs/ca/ca.crt -CAkey /usr/share/apm-server/certs/ca/ca.key -CAcreateserial -out /usr/share/apm-server/certs/apm-server/apm-server.crt -days 3650 -sha256

# Set permissions
chmod 600 /usr/share/apm-server/certs/apm-server/apm-server.key
chmod 644 /usr/share/apm-server/certs/apm-server/apm-server.crt
chmod 644 /usr/share/apm-server/certs/ca/ca.crt

echo "SSL certificates generated successfully!"

# Create APM config
cat > /usr/share/apm-server/apm-server.yml << EOF
apm-server:
  host: "0.0.0.0:8200"
  ssl:
    enabled: true
    certificate: "/usr/share/apm-server/certs/apm-server/apm-server.crt"
    key: "/usr/share/apm-server/certs/apm-server/apm-server.key"
    certificate_authorities: ["/usr/share/apm-server/certs/ca/ca.crt"]
    verification_mode: certificate

output.elasticsearch:
  hosts: ["https://es01:9200"]
  username: "elastic"
  password: "nG2z1mHH*BN7RRPN3bxW"
  ssl:
    verification_mode: none

logging:
  level: info
  to_files: false
  to_stderr: true
EOF

echo "Starting APM server with SSL..."
exec /usr/share/apm-server/apm-server run -e