#!/bin/bash

# =============================================================================
# APM Data Cleanup Script for Elastic Stack
# Author: Claude Code Assistant
# Description: Clean all APM data from Elasticsearch including
#              service inventory, metrics, traces, and configurations
# =============================================================================

# Configuration
ELASTIC_USER="elastic"
ELASTIC_PASSWORD="nG2z1mHH*BN7RRPN3bxW"
ELASTIC_URL="https://localhost:9200"
CACERT="/dev/null"  # Use /dev/null for self-signed certs

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check connection to Elasticsearch
check_connection() {
    log_info "Checking connection to Elasticsearch..."

    if curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cluster/health" > /dev/null; then
        log_success "Connected to Elasticsearch successfully"
        return 0
    else
        log_error "Cannot connect to Elasticsearch at ${ELASTIC_URL}"
        log_error "Please check if Elasticsearch is running and credentials are correct"
        exit 1
    fi
}

# List current APM indices
list_apm_indices() {
    log_info "Current APM-related indices:"

    local apm_indices=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices?v" | \
        grep -E "(apm|service|cdn)" | \
        awk '{print "  - " $3 " (" $7 " docs)"}')

    if [[ -n "$apm_indices" ]]; then
        echo "$apm_indices"
    else
        echo "  No APM-related indices found"
    fi
}

# Delete APM data streams
delete_apm_data_streams() {
    log_info "Deleting APM data streams..."

    local data_streams=(
        "logs-apm.error-default"
        "metrics-apm.service_transaction.1m-default"
        "metrics-apm.service_summary.1m-default"
        "metrics-apm.internal-default"
        "metrics-apm.transaction.1m-default"
        "traces-apm-default"
    )

    for ds in "${data_streams[@]}"; do
        log_info "Deleting data stream: $ds"
        local response=$(curl -s -w "%{http_code}" -X DELETE \
            -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
            --cacert "${CACERT}" -k "${ELASTIC_URL}/_data_stream/$ds")

        local http_code="${response: -3}"
        if [[ "$http_code" == "200" ]]; then
            log_success "✓ Deleted data stream: $ds"
        else
            log_warning "⚠ Data stream not found or couldn't delete: $ds"
        fi
    done
}

# Delete APM indices directly
delete_apm_indices() {
    log_info "Deleting APM indices..."

    # Get all indices containing 'apm'
    local apm_indices=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
        grep -i apm | awk '{print $3}')

    for index in $apm_indices; do
        log_info "Deleting index: $index"
        local response=$(curl -s -w "%{http_code}" -X DELETE \
            -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
            --cacert "${CACERT}" -k "${ELASTIC_URL}/$index")

        local http_code="${response: -3}"
        if [[ "$http_code" == "200" ]]; then
            log_success "✓ Deleted index: $index"
        else
            log_warning "⚠ Index not found or couldn't delete: $index"
        fi
    done
}

# Delete external service indices
delete_external_services() {
    log_info "Deleting external service indices..."

    local service_patterns=(
        "cloud_cdn-*"
        "ai-cdn-services-*"
        "*cdn*"
        "*service*"
    )

    for pattern in "${service_patterns[@]}"; do
        local indices=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
            --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
            grep "$pattern" | awk '{print $3}')

        for index in $indices; do
            # Skip internal APM metrics that should remain
            if [[ "$index" == *"apm.internal-default"* ]]; then
                log_info "Skipping internal APM metrics: $index"
                continue
            fi

            log_info "Deleting external service index: $index"
            local response=$(curl -s -w "%{http_code}" -X DELETE \
                -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
                --cacert "${CACERT}" -k "${ELASTIC_URL}/$index")

            local http_code="${response: -3}"
            if [[ "$http_code" == "200" ]]; then
                log_success "✓ Deleted external service index: $index"
            else
                log_warning "⚠ Could not delete index: $index (HTTP $http_code)"
            fi
        done
    done
}

# Force delete remaining service-related data streams
force_delete_service_data() {
    log_info "Force deleting remaining service data streams..."

    local service_streams=(
        "metrics-apm.service_summary.1m-default"
        "metrics-apm.service_transaction.1m-default"
        "metrics-apm.transaction.1m-default"
    )

    for stream in "${service_streams[@]}"; do
        log_info "Force deleting service data stream: $stream"

        # First try to delete as data stream
        local response=$(curl -s -w "%{http_code}" -X DELETE \
            -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
            --cacert "${CACERT}" -k "${ELASTIC_URL}/_data_stream/$stream")

        local http_code="${response: -3}"

        if [[ "$http_code" != "200" ]]; then
            # If data stream deletion fails, try to delete the underlying index
            log_warning "Data stream deletion failed, trying index deletion..."

            # Find the actual index name for this data stream
            local actual_index=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
                --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
                grep "$stream" | awk '{print $3}' | head -1)

            if [[ -n "$actual_index" ]]; then
                log_info "Deleting actual index: $actual_index"
                response=$(curl -s -w "%{http_code}" -X DELETE \
                    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
                    --cacert "${CACERT}" -k "${ELASTIC_URL}/$actual_index")

                http_code="${response: -3}"
                if [[ "$http_code" == "200" ]]; then
                    log_success "✓ Deleted index: $actual_index"
                else
                    log_warning "⚠ Could not delete index: $actual_index"
                fi
            fi
        else
            log_success "✓ Deleted data stream: $stream"
        fi
    done
}

# Comprehensive cleanup of all APM service data
comprehensive_cleanup() {
    log_info "Performing comprehensive APM service data cleanup..."

    # Get ALL indices containing any APM-related terms
    local all_apm_indices=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
        grep -i -E "(apm|service|transaction|trace|metric)" | \
        awk '{print $3}')

    for index in $all_apm_indices; do
        # Keep internal APM metrics and system indices
        if [[ "$index" == *"internal-default"* ]] || \
           [[ "$index" == *".internal.alerts"* ]] || \
           [[ "$index" == *"metrics-endpoint"* ]]; then
            log_info "Preserving system index: $index"
            continue
        fi

        # Delete all other APM-related indices
        log_info "Comprehensive cleanup - deleting: $index"
        local response=$(curl -s -w "%{http_code}" -X DELETE \
            -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
            --cacert "${CACERT}" -k "${ELASTIC_URL}/$index")

        local http_code="${response: -3}"
        if [[ "$http_code" == "200" ]]; then
            log_success "✓ Deleted: $index"
        else
            log_warning "⚠ Could not delete: $index"
        fi
    done
}

# Stop APM applications (optional)
stop_apm_applications() {
    log_info "Stopping APM applications to prevent new data..."

    if command -v docker-compose &> /dev/null; then
        if docker-compose ps python-cdnn | grep -q "Up"; then
            log_info "Stopping Python APM application..."
            docker-compose stop python-cdnn
        fi

        if docker-compose ps go-cdnn | grep -q "Up"; then
            log_info "Stopping Go APM application..."
            docker-compose stop go-cdnn
        fi
    fi
}

# Restart APM services to clear cache
restart_apm_services() {
    log_info "Restarting APM services to clear cache..."

    if command -v docker-compose &> /dev/null; then
        log_info "Restarting APM Server..."
        docker-compose restart apm-server

        log_info "Restarting Kibana to clear APM UI cache..."
        docker-compose restart kibana

        log_info "Waiting for services to be ready..."
        sleep 10
    fi
}

# Verify cleanup
verify_cleanup() {
    log_info "Verifying cleanup results..."

    local remaining_apm=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
        grep -E "(service|cdn)" | wc -l)

    local apm_internal=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
        grep -E "metrics-apm.internal|alerts-observability.apm" | wc -l)

    if [[ "$remaining_apm" -eq 0 ]]; then
        log_success "✅ All service inventory data has been cleared!"
    else
        log_warning "⚠ Found $remaining_apm remaining service-related indices"
    fi

    if [[ "$apm_internal" -gt 0 ]]; then
        log_info "ℹ️ $apm_internal internal APM indices remain (this is normal)"
    fi
}

# Show final index count
show_final_status() {
    log_info "Final index status:"

    local total_indices=$(curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | wc -l)

    echo -e "${GREEN}Total indices remaining: $total_indices${NC}"

    echo -e "\n${BLUE}Remaining APM-related indices:${NC}"
    curl -s -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
        --cacert "${CACERT}" -k "${ELASTIC_URL}/_cat/indices" | \
        grep -i apm || echo "  None found"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "==================================================================="
    echo "     APM Data Cleanup Script for Elastic Stack"
    echo "==================================================================="
    echo -e "${NC}"

    # Warning prompt
    echo -e "${YELLOW}⚠️  WARNING: This will delete ALL APM data including:${NC}"
    echo "   - Service inventory and dependencies"
    echo "   - Transaction traces and metrics"
    echo "   - Error logs and performance data"
    echo "   - External service integrations"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled by user"
        exit 1
    fi

    # Execute cleanup steps
    check_connection
    list_apm_indices
    echo ""

    stop_apm_applications
    delete_apm_data_streams
    delete_apm_indices
    delete_external_services
    force_delete_service_data
    comprehensive_cleanup
    restart_apm_services
    verify_cleanup
    show_final_status

    echo ""
    log_success "🎉 APM data cleanup completed successfully!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Access Kibana: http://localhost:5601"
    echo "2. Navigate to Observability → APM → Services"
    echo "3. You should see an empty Service Inventory"
    echo "4. Start your applications to begin fresh monitoring"
    echo ""
}

# Execute main function
main "$@"