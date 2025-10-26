package com.example.weatherpush.repository;

import com.example.weatherpush.entity.Weather;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface WeatherRepository extends JpaRepository<Weather, Long> {

    // Fetch rows after a given LocalDateTime
    List<Weather> findByTimestampAfter(LocalDateTime timestamp);
}
