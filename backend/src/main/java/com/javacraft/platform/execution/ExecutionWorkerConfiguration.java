package com.javacraft.platform.execution;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@Profile("execution-worker")
@ConditionalOnProperty(name = "app.execution.worker-enabled", havingValue = "true")
@EnableScheduling
public class ExecutionWorkerConfiguration {}
