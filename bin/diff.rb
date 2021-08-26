#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'pry'

diff = EveryPoliticianScraper::Comparison.new('data/wikidata.csv', 'data/wikipedia.csv').diff
csv = CSV.parse(diff.map(&:to_csv).join, headers:true)
puts csv.headers.to_csv
puts csv.sort_by { |row| [row[1],row[3],row[6],row[4]] }.map(&:to_s)
