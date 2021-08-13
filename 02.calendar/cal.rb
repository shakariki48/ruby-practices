#!/usr/bin/env ruby

require 'date'
require 'optparse'

def print_in_inveted_color(text)
  print "\e[7m" + text + "\e[m"
end

def print_calendar(year:, month:)
  raise "invalid argument: #{month} is not a month number (1..12)" if month < 1 || month > 12

  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1)

  puts "      #{month}月 #{year}"
  puts '日 月 火 水 木 金 土'

  print '   ' * first_day.wday
  (first_day..last_day).each { |date|
    str_day = date.day.to_s.rjust(2)
    if date == Date.today
      print_in_inveted_color str_day
    else
      print str_day
    end
    print date.saturday? ? "\n" : ' '
  }
  puts
end

def parse_options
  option_parser = OptionParser.new
  option_parser.banner = 'Usage: cal.rb [options]'
  option_parser.on('-m MONTH', Integer, 'select month')
  option_parser.on('-y YEAR', Integer, 'select year')
  option_parser.parse(ARGV)
  option_parser.getopts(ARGV, 'y:m:')
rescue => e
  raise e.message + "\n" + option_parser.help
end

begin
  TODAY = Date.today
  options = parse_options
  year = options['y'] ? options['y'].to_i : TODAY.year
  month = options['m'] ? options['m'].to_i : TODAY.month
  print_calendar(year: year, month: month)
rescue => e
  puts e.message
end