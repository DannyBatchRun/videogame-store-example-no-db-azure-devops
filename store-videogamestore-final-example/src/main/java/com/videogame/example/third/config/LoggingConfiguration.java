package com.videogame.example.third.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LoggingConfiguration {
    private final Logger LOG = LoggerFactory.getLogger(LoggingConfiguration.class);

    public LoggingConfiguration() {
        LOG.info("LoggingConfiguration initialized");
    }
}
