package com.javacraft.platform.catalog;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1")
public class CatalogController {
    private final CatalogService catalog;

    public CatalogController(CatalogService catalog) {
        this.catalog = catalog;
    }

    @GetMapping("/catalog")
    public CatalogService.CatalogResponse catalog() {
        return catalog.getCatalog();
    }

    @GetMapping("/tutorials")
    public List<CatalogService.TutorialSummary> tutorials() {
        return catalog.listTutorials();
    }

    @GetMapping("/tutorial-categories")
    public List<CatalogService.TutorialCategory> tutorialCategories() {
        return catalog.listCategories();
    }

    @GetMapping("/challenges")
    public List<CatalogService.ChallengeSummary> challenges() {
        return catalog.listChallenges();
    }

    @GetMapping("/tutorials/{slug}")
    public CatalogService.Tutorial tutorial(@PathVariable String slug) {
        return catalog.findTutorial(slug)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }

    @GetMapping("/challenges/{slug}")
    public CatalogService.Challenge challenge(@PathVariable String slug) {
        return catalog.findChallenge(slug)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
    }
}
