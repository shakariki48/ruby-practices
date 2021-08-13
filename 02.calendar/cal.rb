#!/usr/bin/env ruby

require 'date'

def print_calendar(year:, month:)
  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1)

  puts "      #{month}月 #{year}"
  puts '日 月 火 水 木 金 土'

  print '   ' * first_day.wday
  (first_day..last_day).each { |date|
    print date.day.to_s.rjust(2)
    print date.saturday? ? "\n" : ' '
  }
  puts
end

TODAY = Date.today
year = TODAY.year
month = TODAY.month
print_calendar(year: year, month: month)