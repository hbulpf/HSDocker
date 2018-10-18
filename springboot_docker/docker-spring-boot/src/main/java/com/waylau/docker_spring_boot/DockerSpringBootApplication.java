package com.waylau.docker_spring_boot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DockerSpringBootApplication {

	@RequestMapping(value = "/",method = RequestMethod.GET)
	public String home() {
		return "Hello Docker World."
				+ "<br />Welcome to <a href='http://waylau.com'>waylau.com</a></li>";
	}

	public static void main(String[] args) {
		SpringApplication.run(DockerSpringBootApplication.class, args);
	}
}
