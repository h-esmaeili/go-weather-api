package main

import (
	"fmt"
	"go-weather-api/internal/nws"
	"go-weather-api/internal/weather"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	client := nws.NewClient()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	r.GET("/weather", func(c *gin.Context) {
		lat := c.Query("lat")
		lon := c.Query("lon")

		if lat == "" || lon == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "lat and lon are required"})
			return
		}

		forecast, tempF, err := client.GetTodayForecast(lat, lon)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch weather"})
			return
		}

		result := gin.H{
			"forecast":      forecast,
			"temperature":   weather.ClassifyTemperature(tempF),
			"temperature_f": tempF,
			"location":      fmt.Sprintf("%s, %s", lat, lon),
		}

		c.JSON(http.StatusOK, result)
	})

	r.Run(":8080")
}
