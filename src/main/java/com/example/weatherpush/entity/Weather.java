package com.example.weatherpush.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "weather")
public class Weather {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String city_name;
    private Double temperature;
    private Integer wind_direction;
    private Double wind_speed;

    private LocalDateTime timestamp;

    // Getters
    public Long getId() { return id; }
    public String getCity_name() { return city_name; }
    public Double getTemperature() { return temperature; }
    public Integer getWind_direction() { return wind_direction; }
    public Double getWind_speed() { return wind_speed; }
    public LocalDateTime getTimestamp() { return timestamp; }

    // Setters
    public void setCity_name(String city_name) { this.city_name = city_name; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }
    public void setWind_direction(Integer wind_direction) { this.wind_direction = wind_direction; }
    public void setWind_speed(Double wind_speed) { this.wind_speed = wind_speed; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
}
