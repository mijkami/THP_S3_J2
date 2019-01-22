require 'bundler'
require 'open-uri'
Bundler.require

$:.unshift File.expand_path("./../lib/app", __FILE__)
require 'scrapper'

Scrapper.new.choose_a_saving
