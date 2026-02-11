# Go Weather API

A Go HTTP service that provides today's weather forecast and temperature classification using the National Weather Service (NWS) API.

---

## Features

- Accepts latitude and longitude coordinates
- Returns:
  - `forecast` (short description, e.g., "Sunny", "Partly Cloudy")
  - `temperature` classification (`hot`, `moderate`, `cold`)
  - `temperature_f` numeric temperature in Fahrenheit
  - `location` as "lat, lon"
- Uses **Gin framework** for HTTP server
- Includes unit tests for temperature classification
- Dockerfile included for easy local deployment

---

## Project Structure

```
go-weather-api/
├── cmd/
│   └── server/
│       └── main.go       # Gin HTTP server
├── internal/
│   ├── nws/
│   │   └── client.go     # NWS API client
│   └── weather/
│       ├── service.go    # temperature classification logic
│       └── service_test.go  # unit tests
├── go.mod
├── go.sum
├── Dockerfile
└── README.md
```

---

## Run Locally

### Prerequisites

- Go 1.22+
- Optional: Docker

### 1. Clone repository

```bash
git clone <your-repo-url>
cd go-weather-api
```

### 2. Run with Go

```bash
go mod tidy
go run ./cmd/server
```

Server runs on `http://localhost:8080`.

### 3. Run with Docker

```bash
docker build -t go-weather-api .
docker run -p 8080:8080 go-weather-api
```

---

## API Endpoints

### Health Check

```
GET /health
```

**Response:**

```json
{
  "status": "ok"
}
```

---

### Get Weather

```
GET /weather?lat={latitude}&lon={longitude}
```

**Parameters:**

- `lat` – latitude (required)  
- `lon` – longitude (required)

**Example Request:**

```bash
curl "http://localhost:8080/weather?lat=38.8894&lon=-77.0352"
```

**Example Response:**

```json
{
  "forecast": "Sunny",
  "temperature": "cold",
  "temperature_f": 46,
  "location": "38.8894, -77.0352"
}
```

---

## Unit Tests

Run all tests:

```bash
go test ./...
```

---

## Notes

- Uses **National Weather Service (NWS) API** as data source
- Temperature classification thresholds:
  - ≥ 85°F → hot
  - ≤ 45°F → cold
  - otherwise → moderate
- Fully structured for clean code and easy review

