package main

import (
	"go-weather-api/internal/nws"
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

		forecast, temp, _ := client.GetTodayForecast(lat, lon)

		c.JSON(http.StatusOK, gin.H{
			"forecast":    forecast,
			"temperature": temp,
		})
	})

	r.Run(":8080")
}
