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

def calc_score(frames)
  score = 0

  frames.each.with_index do |frame, i|
    score += frame.sum
    break if i + 1 == frames.length

    # spare or strike
    score += frames[i + 1][0] if frame.sum == 10

    # strike
    if frame[0] == 10
      score += if frames[i + 1][0] == 10 && i + 2 != frames.length
                 frames[i + 2][0]
               else
                 frames[i + 1][1]
               end
    end
  end

  score
end

# main
if __FILE__ == $PROGRAM_NAME
  score_csv = ARGV[0]
  frames = to_frames(score_csv)
  puts calc_score(frames)
end
