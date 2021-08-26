#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'pry'

class Comparison < EveryPoliticianScraper::Comparison
  require 'set'

  COMPARE = %i[officeholder start_year end_year].freeze
  DISPLAY = %i[country position positionlabel officeholder officeholderlabel start_year end_year].freeze

  def wikidata_all
    @wikidata_all ||= CSV.table(wikidata_source, wikidata_csv_options)
  end

  def external_all
    @external_all ||= CSV.table(external_source, external_csv_options)
  end

  def wikidata_grouped
    @wikidata_grouped ||= wikidata_all.group_by { |row| row.values_at(*COMPARE) }
  end

  def external_grouped
    @external_grouped ||= external_all.group_by { |row| row.values_at(*COMPARE) }
  end

  def in_both
    (external_grouped.keys & wikidata_grouped.keys).to_set
  end

  def columns
    DISPLAY
  end

  def wikidata
    @wikidata ||= wikidata_all.delete_if { |row| in_both.include?(row.values_at(*COMPARE)) }
  end

  def external
    @external ||= external_all.delete_if { |row| in_both.include?(row.values_at(*COMPARE)) }
  end
end

header, *diffs = Comparison.new('data/wikidata.csv', 'data/wikipedia.csv').diff
puts header.to_csv, diffs.sort_by { |row| [row[1].to_s, row[3].to_s, row[6].to_s, row[5].to_s] }.map(&:to_csv)
