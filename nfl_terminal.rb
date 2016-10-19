require 'net/http'
require 'json'

module NflTerminal
  def game_ids(teams = 'all')
    ongoing_games(teams).map { |game| game['eid'] }
  end

  def ongoing_games(teams = 'all')
    schedule['gms'].select { |game| ongoing?(game) && with_team?(game, teams) }
  end

  def schedule
    json_response(schedule_url)
  end

  def schedule_url
    'http://www.nfl.com/liveupdate/scorestrip/ss.json'
  end

  def json_response(url)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def with_team?(game, teams)
    return true if teams == 'all'
    (teams & [game['h'], game['v']]).any?
  end

  def ongoing?(game)
    !%w(P F FO).include?(game['q'])
  end
end
