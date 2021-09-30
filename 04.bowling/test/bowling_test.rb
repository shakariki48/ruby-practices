# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/bowling'

class BowlingTest < Minitest::Test
  def test_to_frames
    assert_equal(
      [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [6, 4, 5]],
      to_frames('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
    )
    assert_equal(
      [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [10, 10, 10]],
      to_frames('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
    )
    assert_equal(
      [[0, 10], [1, 5], [0, 0], [0, 0], [10, 0], [10, 0], [10, 0], [5, 1], [8, 1], [0, 4]],
      to_frames('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
    )
    assert_equal(
      [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10, 0], [9, 1], [8, 0], [10, 0], [10, 0, 0]],
      to_frames('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
    )
    assert_equal(
      [[10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 0], [10, 10, 10]],
      to_frames('X,X,X,X,X,X,X,X,X,X,X,X')
    )
  end
end
