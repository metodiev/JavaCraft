package com.javacraft.platform.catalog;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(CatalogController.class)
class CatalogControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @Test
    void catalogExposesPublicLearningContentWithoutHiddenTests() throws Exception {
        mockMvc.perform(get("/api/v1/catalog"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.challenge.slug").value("payment-race-condition"))
                .andExpect(jsonPath("$.challenge.hiddenTests").doesNotExist());
    }

    @Test
    void unknownTutorialReturnsNotFound() throws Exception {
        mockMvc.perform(get("/api/v1/tutorials/does-not-exist"))
                .andExpect(status().isNotFound());
    }
}
