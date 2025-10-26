package com.example.weatherpush.service;

import com.example.weatherpush.entity.Weather;
import com.example.weatherpush.repository.WeatherRepository;
import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.Gauge;
import io.prometheus.client.exporter.PushGateway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class WeatherPushService {

    private final WeatherRepository weatherRepository;

    @Value("${pushgateway.url}")
    private String pushGatewayUrl;

    public WeatherPushService(WeatherRepository weatherRepository) {
        this.weatherRepository = weatherRepository;
    }

    @Scheduled(fixedRate = 600_000) // every 10 minutes
    public void pushWeatherMetrics() {
        // Fetch only the last 10 minutes of data
        LocalDateTime tenMinutesAgo = LocalDateTime.now().minusMinutes(10);
        List<Weather> recentWeather = weatherRepository.findByTimestampAfter(tenMinutesAgo);

        if (recentWeather.isEmpty()) {
            System.out.println("No new weather data to push.");
            return;
        }

        CollectorRegistry registry = new CollectorRegistry();

        Gauge temperatureGauge = Gauge.build()
                .name("weather_temperature")
                .help("Temperature of city")
                .labelNames("city_name")
                .register(registry);

        Gauge windSpeedGauge = Gauge.build()
                .name("weather_wind_speed")
                .help("Wind speed of city")
                .labelNames("city_name")
                .register(registry);

        Gauge windDirGauge = Gauge.build()
                .name("weather_wind_direction")
                .help("Wind direction of city")
                .labelNames("city_name")
                .register(registry);

        for (Weather w : recentWeather) {
            String city = w.getCity_name();
            temperatureGauge.labels(city).set(w.getTemperature());
            windSpeedGauge.labels(city).set(w.getWind_speed());
            windDirGauge.labels(city).set(w.getWind_direction());
        }

        try {
            // Correct way: convert String -> URL
            PushGateway pg = new PushGateway(new URL(pushGatewayUrl));
            pg.pushAdd(registry, "weather_job");

            System.out.println("Weather metrics pushed successfully. Rows: " + recentWeather.size());
        } catch (Exception e) {
            System.err.println("Error pushing weather metrics: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
