#!/usr/bin/env ruby
# frozen_string_literal: true

def to_frames(scores_csv)
  scores = scores_csv.split(',')
  frames = []
  frame = []
  current_frame = 1

  scores.each.with_index do |score, i|
    if current_frame == 10
      rest_of_scores = scores[i..-1]
      frames.push(rest_of_scores.map { |s| s == 'X' ? 10 : s.to_i })
      break
    end

    score == 'X' ? frame.push(10, 0) : frame.push(score.to_i)
    if frame.length == 2
      frames.push(frame)
      frame = []
      current_frame += 1
    end
  end

  frames
end

def calc_score(frames); end

# main
if __FILE__ == $PROGRAM_NAME
  score_csv = ARGV[0]
  frames = to_frames(score_csv)
  puts calc_score(frames)
end
