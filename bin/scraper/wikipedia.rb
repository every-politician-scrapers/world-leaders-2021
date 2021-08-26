#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
      doc.css('#Notes').xpath('following::*').remove
    end.to_s
  end
end

class OfficeTerm
  def initialize(str)
    @str = str
  end

  def start_date
    date_section.first
  end

  def end_date
    date_section.last
  end

  private

  def date_section
    str.match(/\(\D*\d+.*?\)/).to_s.split(/[–-]/).map { |str| str[/(\d{4})/, 1] }
  end

  attr_reader :str
end

class Leader < Scraped::HTML
  field :continent do
    noko.xpath('preceding::h2[1]/span[@class="mw-headline"]').text.tidy
  end

  field :country do
    # c = noko.xpath('ancestor::ul/parent::li').css('a').first.text
    noko.xpath('ancestor::ul/parent::li/*').map(&:text).map(&:tidy).reject(&:empty?).first
  end

  field :position do
    position_link.attr('wikidata').to_s.tidy
  end

  field :positionlabel do
    position_link.attr('title').to_s.tidy
  end

  field :officeholder do
    officeholder_link.attr('wikidata').to_s.tidy
  end

  field :officeholderlabel do
    officeholder_link.attr('title').to_s.tidy
  end

  field :start_year do
    term.start_date
  end

  field :end_year do
    term.end_date
  end

  private

  def position_link
    people.last
  end

  def officeholder_link
    people.first
  end

  def people
    noko.css('a')
  end

  def term
    @term = OfficeTerm.new(noko.text.tidy)
  end
end

class ListPage < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  field :leaders do
    leader_nodes.map { |node| fragment(node => Leader).to_h }
  end

  private

  def leader_nodes
    noko.css('#mw-content-text').xpath('.//li[not(.//li)][contains(string(),"(")]')
  end
end

url = 'https://en.wikipedia.org/wiki/List_of_state_leaders_in_2021'
data = ListPage.new(response: Scraped::Request.new(url: url).response).leaders

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
