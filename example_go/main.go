package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"

	"go.elastic.co/apm/module/apmechov8"
	"go.elastic.co/apm/module/apmotransport"
	"go.elastic.co/apm/v2"
)

type CDNNService struct {
	apm *apm.Tracer
}

func NewCDNNService() *CDNNService {
	// Initialize APM tracer with our secret token
	tracer, err := apm.NewTracer("cdnn-go")
	if err != nil {
		log.Fatalf("Failed to create APM tracer: %v", err)
	}

	// Set secret token for authentication
	os.Setenv("ELASTIC_APM_SECRET_TOKEN", "Sk90WUI1c0JWLWZPczMxdWpMMjY6WkNiUlNRYUVkVDFLR2JBeHA1d0F6QQ==")

	return &CDNNService{
		apm: tracer,
	}
}

func (s *CDNNService) SlowDataLoading(ctx context.Context) (int, error) {
	span, ctx := s.apm.StartSpanOptions(ctx, "data_loading", "app", apm.SpanOptions{})
	defer span.End()

	// Simulate slow data loading with progress tracking
	totalRecords := rand.Intn(4000) + 1000
	span.SetLabel("total_records", totalRecords)

	// Simulate loading chunks
	for i := 0; i < 5; i++ {
		select {
		case <-ctx.Done():
			return 0, ctx.Err()
		default:
			time.Sleep(time.Duration(rand.Intn(3)+2) * time.Second)
			progress := float64(i+1) / 5.0 * 100
			span.SetLabel("progress_percent", progress)
			log.Printf("Data loading progress: %.1f%%", progress)
		}
	}

	span.SetLabel("loaded_records", totalRecords)
	return totalRecords, nil
}

func (s *CDNNService) SlowMLInference(ctx context.Context, batch int) (float64, error) {
	span, ctx := s.apm.StartSpanOptions(ctx, "ml_inference", "ml", apm.SpanOptions{})
	defer span.End()

	// Set ML-specific labels
	span.SetLabel("model_name", "cdnn-go-v1.0")
	span.SetLabel("framework", "tensorflow-go")
	span.SetLabel("batch_size", batch)
	span.SetLabel("gpu_utilization", fmt.Sprintf("%.1f%%", rand.Float64()*35+60))

	// Model loading
	time.Sleep(2 * time.Second)

	// Inference computation (the slow part)
	inferenceTime := time.Duration(rand.Intn(6)+4) * time.Second
	time.Sleep(inferenceTime)

	// Post-processing
	time.Sleep(500 * time.Millisecond)

	accuracy := 0.8 + rand.Float64()*0.15
	span.SetLabel("accuracy", accuracy)
	span.SetLabel("inference_time_ms", inferenceTime.Milliseconds())

	return accuracy, nil
}

func (s *CDNNService) SlowAPICall(ctx context.Context) error {
	span, ctx := s.apm.StartSpanOptions(ctx, "external_api_call", "http", apm.SpanOptions{})
	defer span.End()

	// Simulate network latency
	time.Sleep(time.Duration(rand.Intn(2)+1) * time.Second)

	// Simulate API response processing
	time.Sleep(500 * time.Millisecond)

	// Randomly fail 10% of the time
	if rand.Float32() < 0.1 {
		err := fmt.Errorf("external API timeout after 30 seconds")
		span.SetLabel("error_type", "timeout")
		return err
	}

	responseTime := rand.Float64()*2 + 0.5
	span.SetLabel("response_time_ms", responseTime*1000)
	span.SetLabel("status", "success")

	log.Printf("API call successful in %.2fs", responseTime)
	return nil
}

func (s *CDNNService) CDNNPipeline(ctx context.Context) (map[string]interface{}, error) {
	// Start main transaction
	tx := s.apm.StartTransaction("cdnn-pipeline", "request")
	defer tx.End()

	// Set transaction context
	tx.SetUserContext("user", "system")
	tx.SetLabel("service", "cdnn-go")
	tx.SetLabel("environment", "development")

	start := time.Now()
	var loadedRecords int
	var accuracy float64
	var err error

	// Step 1: Data Loading
	log.Println("📊 Step 1: Starting data loading...")
	loadedRecords, err = s.SlowDataLoading(tx.Context())
	if err != nil {
		tx.Result = apm.ResultFailure
		return nil, fmt.Errorf("data loading failed: %w", err)
	}
	log.Printf("✅ Loaded %d records", loadedRecords)

	// Step 2: ML Inference
	log.Println("🧠 Step 2: Starting ML inference...")
	batch := rand.Intn(64) + 32
	accuracy, err = s.SlowMLInference(tx.Context(), batch)
	if err != nil {
		tx.Result = apm.ResultFailure
		return nil, fmt.Errorf("ML inference failed: %w", err)
	}
	log.Printf("✅ Processed %d samples with accuracy: %.2f%%", batch, accuracy*100)

	// Step 3: External API Call
	log.Println("🌐 Step 3: Making API call...")
	if err := s.SlowAPICall(tx.Context()); err != nil {
		// Log error but don't fail the pipeline
		log.Printf("⚠️ API call failed (non-critical): %v", err)
		s.apm.CaptureError(fmt.Errorf("API call failed: %w", err))
	}

	// Response formatting
	response := map[string]interface{}{
		"status":        "success",
		"duration_ms":   time.Since(start).Milliseconds(),
		"loaded_records": loadedRecords,
		"batch_size":     batch,
		"accuracy":      accuracy,
	}

	log.Printf("✅ CDNN Pipeline completed in %v", time.Since(start))
	tx.Result = apm.ResultSuccess

	// Send custom event/metrics
	s.apm.SendEvent("CDNN pipeline completed", "info", apm.Event{
		Message: fmt.Sprintf("Pipeline completed with %d records, accuracy %.2f%%", loadedRecords, accuracy*100),
	})

	return response, nil
}

func (s *CDNNService) StartHTTPServer() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("🚀 HTTP request received from %s", r.RemoteAddr)

		// Start transaction for HTTP request
		tx := s.apm.StartTransactionOptions(r.Context(), "http-request", "request")
		defer tx.End()

		// Add HTTP request context
		tx.SetLabel("http_method", r.Method)
		tx.SetLabel("http_url", r.URL.String())
		tx.SetLabel("http_user_agent", r.UserAgent())

		// Run CDNN pipeline
		result, err := s.CDNNPipeline(tx.Context())
		if err != nil {
			log.Printf("❌ Pipeline failed: %v", err)
			tx.Result = apm.ResultFailure
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

	log.Println("🤖 CDNN Service with APM Monitoring Started")
	log.Println("🔍 Service name: cdnn-go")
	log.Println("📊 APM Server: http://172.18.0.2:8200")
	log.Println("🔑 Secret Token: Configured")
	log.Println("=" * 50)

	// Start HTTP server (this will run forever)
	service.StartHTTPServer()
}