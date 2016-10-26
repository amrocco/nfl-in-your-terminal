#!/usr/bin/env ruby
require 'optparse'
require_relative './nfl_schedule.rb'
require_relative './nfl_game.rb'

class NflLiveUpdates
  extend NflSchedule

  def initialize(game_id, update_type)
    @game = NflGame.new(game_id.to_s)
    @update_type = update_type
    @clock = nil
  end

  def stream
    until @game.over?
      print_updates
      @game.update
      sleep(60)
    end
  end

  def self.stream
    @update_type = 'play_by_play'
    @teams = 'all'
    parse_options
    threads = game_ids(@teams).map { |game_id| create_thread(game_id) }
    threads.each(&:join)
    print_no_games_message if threads.empty?
  end

  private

  def print_updates
    new_timestamps(all_timestamps).each do |time|
      printf send("#{@update_type}_update", time) + "\n"
      @clock = time
    end
  end

  def play_by_play_update(time)
    @game.plays_for_current_drive[time]['desc']
  end

  def scoring_update(time)
    "(#{@game.scoring_summary[time]['type']}) #{@game.scoring_summary[time]['desc']}"
  end

  def all_timestamps
    if @update_type == 'scoring'
      @game.scoring_summary.keys
    else
      @game.plays_for_current_drive.keys
    end
  end

  def new_timestamps(timestamps)
    index = timestamps.index(@clock)
    index.nil? ? timestamps : timestamps[index..-1].drop(1)
  end

  class << self
    private

    def parse_options
      OptionParser.new do |opts|
        opts.banner = 'Usage: nfl_live_updates.rb [options]'
        opts.on('-s', '--scoring-plays-only',
                'Only plays that result in a score will be displayed') do
          @update_type = 'scoring'
        end
        opts.on('-t', '--teams BUF,NE', 'Takes a comma delimited list of team
                abbreviations. Only updates for these teams will be displayed.
                By default updates for all live games are displayed.') do |v|
          @teams = v.split(',')
        end
        opts.on('-a', '--team-abbreviations',
                'Prints team abbreviations to the console') do
          print_team_abbreviations
          exit
        end
      end.parse!
    end

    def create_thread(game_id)
      Thread.new { NflLiveUpdates.new(game_id, @update_type).stream }
    end

    def print_team_abbreviations
      puts `cat nfl_team_abbreviations.txt`
    end

    def print_no_games_message
      if @teams == 'all'
        puts 'There are currently no ongoing games.'
      else
        puts "There are currently no ongoing #{@teams.join(',')} games."
      end
    end
  end
end

NflLiveUpdates.stream
