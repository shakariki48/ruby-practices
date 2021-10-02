# frozen_string_literal: true

require 'minitest/autorun'
require 'set'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  # === 05.ls/test ディレクトリで実行する ===
  def test_get_filenames
    assert_equal(
      Set.new(['lib', 'test', '.gitkeep']),
      Set.new(get_filenames('..'))
    )
    assert_equal(
      Set.new(['../lib/ls.rb']),
      Set.new(get_filenames('../lib/ls.rb'))
    )
    assert_equal(
      Set.new([]),
      Set.new(get_filenames('../lib/ls'))
    )
  end
end
