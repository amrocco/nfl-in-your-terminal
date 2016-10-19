require_relative './nfl_terminal.rb'

module NflScores
  extend NflTerminal

  class << self
    def print_scores
      puts game_scores.map { |score| stringify_game_score(score) }.join('  ')
    end

    private

    def stringify_game_score(score)
      "#{stringify_home_score(score[:home])}/#{stringify_visitor_score(score[:visitor])}"
    end

    def game_scores
      ongoing_games.map { |game| game_score(game) }
    end

    def game_score(game)
      { home: home_score(game), visitor: visitor_score(game) }
    end

    # home_score(game)
    # visitor_score(game)
    # stringify_home_score(score)
    # stringify_visitor_score(score)
    %w(home visitor).each do |team|
      define_method("#{team}_score") do |game|
        { team: game[team[0]], score: game["#{team[0]}s"] }
      end

      define_method("stringify_#{team}_score") do |score|
        "#{score[:team]} #{score[:score]}"
      end
    end
  end
end

NflScores.print_scores
