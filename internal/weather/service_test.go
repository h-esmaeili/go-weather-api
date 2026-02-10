package weather

import "testing"

func TestClassifyTemperature(t *testing.T) {
	tests := []struct {
		temp int
		want string
	}{
		{90, "hot"},
		{85, "hot"},
		{70, "moderate"},
		{50, "moderate"},
		{45, "cold"},
		{30, "cold"},
	}

	for _, tt := range tests {
		got := ClassifyTemperature(tt.temp)
		if got != tt.want {
			t.Errorf("ClassifyTemperature(%d) = %s; want %s", tt.temp, got, tt.want)
		}
	}
}
