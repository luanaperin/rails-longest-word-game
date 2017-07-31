class GamesController < ApplicationController


  def game
    @grid = generate_grid(10)
    @start_time = Time.now
  end

  def score
    # binding.pry
    @query = params[:query]
    @start_time = params[:start_time]
    @grid = params[:grid]
    # binding.pry
    @score = run_game(@query, JSON.parse(@grid), DateTime.parse(@start_time).to_time, Time.now())
  end






private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    letters = []
    grid_size.downto(1) do
    letters << (65 + rand(26)).chr
    end
   letters
  end


  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    result_hash = { time: end_time - start_time, translation: nil, score: 0, message: "" }
    serialized_response = JSON.parse(open(url).read)
    # Formato de resposta serialized_response["outputs"][0]["output"]
    if serialized_response.key?("term0") # It is a valid word if true
    # Check if word is uses only letters in the grid
      attempt.upcase.split('').each do |letter|
        if grid.include?(letter)
          grid.delete_at(grid.index(letter))
         else
           result_hash[:message] = "not in the grid"
           return result_hash
        end
      end

    # If the code gets here, the word is a valid word
      result_hash[:translation] = serialized_response["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
      result_hash[:score] = (attempt.length * 10.0) / (result_hash[:time] * 10.0)
      result_hash[:message] = "well done"
    else # If words are not equal, it is not a valid word
      result_hash[:message] = "not an english word"
    end

    return result_hash
  end


end
