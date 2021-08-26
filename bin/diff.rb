#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'pry'

DIFF = %i[officeholder start_year end_year]
DISPLAY = %i[
  country position positionlabel officeholder officeholderlabel start_year end_year
]

wd = CSV.table('data/wikidata.csv')
wp = CSV.table('data/wikipedia.csv')

wdg = wd.group_by { |row| row.values_at(*DIFF) }
wpg = wp.group_by { |row| row.values_at(*DIFF) }

wd_only = wdg.reject { |k, _| wpg.keys.include? k }
wp_only = wpg.reject { |k, _| wdg.keys.include? k }

wd_out = wd_only.values.flatten(1).map { |row| ["---", *row.values_at(*DISPLAY)] }
wp_out = wp_only.values.flatten(1).map { |row| ["+++", *row.values_at(*DISPLAY)] }

puts DISPLAY.to_csv
puts (wd_out + wp_out).sort_by { |row| [row[1].to_s, row[3].to_s, row[6].to_s, row[5].to_s] }.map(&:to_csv)
