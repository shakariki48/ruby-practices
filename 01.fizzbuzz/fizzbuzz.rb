#!/usr/bin/env ruby

def fizzbuzz
  from = 1
  to = 20
  (from..to).each { |x|
    if x % 15 == 0
      puts 'FizzBuzz'
    elsif x % 3 == 0
      puts 'Fizz'
    elsif x % 5 == 0
      puts 'Buzz'
    else
      puts x
    end
  }
end

fizzbuzz
