package vn.chuongpl.badbook.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class GoogleWebClientConfig {

    @Bean
    public WebClient googleWebClient() {
        return WebClient.builder()
                .baseUrl("https://oauth2.googleapis.com")
                .defaultHeader("Content-Type", "application/json")
                .build();
    }
}
