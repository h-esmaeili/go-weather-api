package weather

type Result struct {
	Forecast        string `json:"forecast"`
	TemperatureType string `json:"temperatureType"`
}

// ClassifyTemperature maps Fahrenheit to hot/moderate/cold
func ClassifyTemperature(tempF int) string {
	switch {
	case tempF >= 85:
		return "hot"
	case tempF <= 45:
		return "cold"
	default:
		return "moderate"
	}
}
