package vn.chuongpl.badbook;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class BadbookApplication {

	public static void main(String[] args) {
		SpringApplication.run(BadbookApplication.class, args);
	}

}
