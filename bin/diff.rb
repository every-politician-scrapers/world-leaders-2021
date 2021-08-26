#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

header, *diffs = EveryPoliticianScraper::Comparison.new('data/wikidata.csv', 'data/wikipedia.csv').diff
puts header.to_csv, diffs.sort_by { |r| [r[1].to_s] }.map(&:to_csv)
