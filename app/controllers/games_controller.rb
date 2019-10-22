require 'open-uri'
class GamesController < ApplicationController
  VOWELS = %w(A E I O U Y)
  def new
    @letters = Array.new(5) { VOWELS.sample }
    @letters += Array.new(5) { (('A'..'Z').to_a - VOWELS).sample }
    @letters.shuffle!
    @start_time = Time.now
  end

  def in_grid?(word, letters)
    word.upcase.chars.all? { |letter| word.upcase.count(letter) <= letters.count(letter) }
  end

  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    serialized = open(url).read
    hash = JSON.parse(serialized)
    hash['found']
  end

  def score_and_message(word, letters, score)
    if in_grid?(word, letters)
      if english_word?(word)
        @result = "#{score}, Well done!"
      else
        @result = "Sorry but #{word} does not seem to be a valid English word"
      end
    else
      @result = "Sorry but #{word} can't be built out of [#{letters}]"
    end
  end

  def score
    # 1. Calculate the time
    start_time = params[:start_time].to_datetime
    end_time = Time.now.to_datetime
    time_result = (end_time - start_time).round(2)
     # 2. Calculate the score
    score = params[:word].size * (1.0 - (time_result / 10.0))
    score_and_message(params[:word], params[:letters], score)
  end
end
