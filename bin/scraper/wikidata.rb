#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT DISTINCT (STRAFTER(STR(?countryItem), STR(wd:)) AS ?countryid) ?country
                  (STRAFTER(STR(?positionItem), STR(wd:)) AS ?position) ?positionLabel
                  (STRAFTER(STR(?officeholderItem), STR(wd:)) AS ?officeholder) ?officeholderLabel
    (YEAR(?start) AS ?start_year) (YEAR(?end) AS ?end_year)
  WHERE {
    ?countryItem wdt:P31 wd:Q3624078 ; p:P1313|p:P1906 ?os .
    ?os a wikibase:BestRank ; ps:P1313|ps:P1906 ?positionItem .
    FILTER NOT EXISTS { ?os pq:P582 [] }

    ?officeholderItem wdt:P31 wd:Q5 ; p:P39 ?ps .
    ?ps ps:P39 ?positionItem ; pq:P580 ?start .
    OPTIONAL { ?ps pq:P582 ?end }
    FILTER(!BOUND(?end) || YEAR(?end)=2021)

    SERVICE wikibase:label {
      bd:serviceParam wikibase:language "en".
      ?countryItem rdfs:label ?country.
      ?positionItem rdfs:label ?positionLabel .
      ?officeholderItem rdfs:label ?officeholderLabel .
    }
  }
  ORDER BY ?country ?positionLabel ?startYear
SPARQL

agent = 'every-politican-scrapers/world=leaders-2021'
puts EveryPoliticianScraper::WikidataQuery.new(query, agent).csv
