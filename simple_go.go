package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"go.elastic.co/apm/v2"
)

type CDNNService struct {
	tracer *apm.Tracer
}

func NewCDNNService() *CDNNService {
	// Initialize APM tracer with service name and environment
	tracer, err := apm.NewTracer("cdnn-go", "development")
	if err != nil {
		log.Fatalf("Failed to create APM tracer: %v", err)
	}

	return &CDNNService{
		tracer: tracer,
	}
}

func (s *CDNNService) SlowDataLoading(ctx context.Context) (int, error) {
	span := s.tracer.StartSpan("data_loading", "custom", apm.SpanID{}, apm.SpanOptions{})
	defer span.End()

	// Simulate slow data loading
	time.Sleep(time.Duration(rand.Intn(3)+2) * time.Second)
	records := rand.Intn(4000) + 1000

	return records, nil
}

func (s *CDNNService) SlowMLInference(ctx context.Context) (float64, error) {
	span := s.tracer.StartSpan("ml_inference", "custom", apm.SpanID{}, apm.SpanOptions{})
	defer span.End()

	// Model loading
	time.Sleep(2 * time.Second)

	// Inference computation
	inferenceTime := time.Duration(rand.Intn(5)+3) * time.Second
	time.Sleep(inferenceTime)

	// Post-processing
	time.Sleep(500 * time.Millisecond)

	accuracy := 0.8 + rand.Float64()*0.15

	return accuracy, nil
}

func (s *CDNNService) SlowAPICall(ctx context.Context) error {
	span := s.tracer.StartSpan("external_api_call", "http", apm.SpanID{}, apm.SpanOptions{})
	defer span.End()

	// Simulate network latency
	time.Sleep(time.Duration(rand.Intn(2)+1) * time.Second)

	// Simulate API response processing
	time.Sleep(500 * time.Millisecond)

	// Randomly fail 10% of the time
	if rand.Float32() < 0.1 {
		return fmt.Errorf("external API timeout")
	}

	return nil
}

func (s *CDNNService) CDNNPipeline(ctx context.Context) (map[string]interface{}, error) {
	// Start transaction
	tx := s.tracer.StartTransaction("cdnn-pipeline", "request")
	defer tx.End()

	start := time.Now()

	// Step 1: Data Loading
	log.Println("📊 Step 1: Starting data loading...")
	loadedRecords, err := s.SlowDataLoading(ctx)
	if err != nil {
		tx.Result = "failure"
		return nil, fmt.Errorf("data loading failed: %w", err)
	}
	log.Printf("✅ Loaded %d records", loadedRecords)

	// Step 2: ML Inference
	log.Println("🧠 Step 2: Starting ML inference...")
	accuracy, err := s.SlowMLInference(ctx)
	if err != nil {
		tx.Result = "failure"
		return nil, fmt.Errorf("ML inference failed: %w", err)
	}
	log.Printf("✅ ML inference completed with accuracy: %.2f%%", accuracy*100)

	// Step 3: External API Call
	log.Println("🌐 Step 3: Making API call...")
	if err := s.SlowAPICall(ctx); err != nil {
	// Log error but don't fail the pipeline
		log.Printf("⚠️ API call failed (non-critical): %v", err)
	}

	response := map[string]interface{}{
		"status":        "success",
		"duration_ms":   time.Since(start).Milliseconds(),
		"loaded_records": loadedRecords,
		"accuracy":      accuracy,
	}

	log.Printf("✅ CDNN Pipeline completed in %v", time.Since(start))
	tx.Result = "success"

	return response, nil
}

func (s *CDNNService) StartHTTPServer() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("🚀 HTTP request from %s", r.RemoteAddr)

	// Start transaction for HTTP request
	transaction := s.tracer.StartTransaction("http-request", "request")
		defer transaction.End()

		// Run CDNN pipeline
		result, err := s.CDNNPipeline(context.Background())
		if err != nil {
			transaction.Result = "failure"
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Send response
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"message": "CDNN processed successfully", "result": %v}`, result)

		log.Printf("✅ HTTP request completed")
	})

	log.Println("🌐 Starting HTTP server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func main() {
	rand.Seed(time.Now().UnixNano())

	// Initialize CDNN service with APM
	service := NewCDNNService()

	log.Println("🤖 CDNN Go Service with APM Monitoring Started")
	log.Println("🔍 Service name: cdnn-go")
	log.Println("📊 Environment: development")
	log.Println("🔑 APM Server: http://172.18.0.2:8200")
	log.Println("🔑 Secret Token: Environment configured")
	log.Println(strings.Repeat("=", 50))

	// Start HTTP server
	service.StartHTTPServer()
}