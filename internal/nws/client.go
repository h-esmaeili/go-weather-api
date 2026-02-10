package nws

import (
	"net/http"
	"time"
)

type Client struct {
	HTTPClient *http.Client
}

func NewClient() *Client {
	return &Client{
		HTTPClient: &http.Client{Timeout: 10 * time.Second},
	}
}

// Placeholder for future GetTodayForecast function
func (c *Client) GetTodayForecast(lat, lon string) (string, int, error) {
	// TODO: implement NWS API call
	return "Partly Cloudy", 72, nil
}
