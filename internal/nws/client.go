package nws

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

const userAgent = "go-weather-api-takehome (youremail@example.com)"

type Client struct {
	HTTPClient *http.Client
}

func NewClient() *Client {
	return &Client{
		HTTPClient: &http.Client{Timeout: 10 * time.Second},
	}
}

type pointsResponse struct {
	Properties struct {
		Forecast string `json:"forecast"`
	} `json:"properties"`
}

type forecastResponse struct {
	Properties struct {
		Periods []struct {
			Temperature   int    `json:"temperature"`
			ShortForecast string `json:"shortForecast"`
		} `json:"periods"`
	} `json:"properties"`
}

// GetTodayForecast calls the NWS API and returns today's forecast and temperature
func (c *Client) GetTodayForecast(lat, lon string) (string, int, error) {
	// Step 1: Points API
	pointsURL := fmt.Sprintf("https://api.weather.gov/points/%s,%s", lat, lon)
	req, _ := http.NewRequest("GET", pointsURL, nil)
	req.Header.Set("User-Agent", userAgent)

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", 0, err
	}
	defer resp.Body.Close()

	var points pointsResponse
	if err := json.NewDecoder(resp.Body).Decode(&points); err != nil {
		return "", 0, err
	}

	// Step 2: Forecast API
	req, _ = http.NewRequest("GET", points.Properties.Forecast, nil)
	req.Header.Set("User-Agent", userAgent)

	resp, err = c.HTTPClient.Do(req)
	if err != nil {
		return "", 0, err
	}
	defer resp.Body.Close()

	var forecast forecastResponse
	if err := json.NewDecoder(resp.Body).Decode(&forecast); err != nil {
		return "", 0, err
	}

	if len(forecast.Properties.Periods) == 0 {
		return "", 0, fmt.Errorf("no forecast data")
	}

	today := forecast.Properties.Periods[0]
	return today.ShortForecast, today.Temperature, nil
}
