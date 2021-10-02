# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  # === 05.ls/test ディレクトリで実行する ===
  def test_get_filenames
    assert_equal(
      %w[lib test],
      get_filenames('..')
    )
    assert_equal(
      ['../lib/ls.rb'],
      get_filenames('../lib/ls.rb')
    )
    assert_equal(
      [],
      get_filenames('../lib/ls')
    )
  end

  def test_format
    num_columns = 3

    # 1列の文字数は (最長のファイル名の長さ) + 1

    filenames = %w[lib test]
    expected = 'lib  test'
    assert_equal(expected, format(filenames, num_columns))

    filenames = ['../lib/ls.rb']
    expected = '../lib/ls.rb'
    assert_equal(expected, format(filenames, num_columns))

    filenames = [
      'Gemfile', 'Gemfile.lock', 'Procfile', 'README.md',
      'babel.config.js', 'bin', 'config', 'config.ru',
      'log', 'package.json', 'postcss.config.js'
    ]
    expected = <<~TEXT.chomp
      Gemfile           babel.config.js   log
      Gemfile.lock      bin               package.json
      Procfile          config            postcss.config.js
      README.md         config.ru
    TEXT
    assert_equal(expected, format(filenames, num_columns))
  end
end
