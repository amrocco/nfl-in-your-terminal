class NflGame
  def initialize(game_id)
    @game_id = game_id
  end

  def over?
    json['qtr'].downcase.include?('final')
  end

  def update
    @json = nil
    json
  end

  def scoring_summary
    json['scrsummary']
  end

  def plays_for_current_drive
    json['drives'][current_drive]['plays']
  end

  def current_drive
    json['drives']['crntdrv'].to_s
  end

  private

  def json
    @json ||= json_response
  end

  def json_response
    uri = URI(game_url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)[@game_id]
  end

  def game_url
    url = 'http://www.nfl.com/liveupdate/game-center/%d/%d_gtd.json'
    format(url, @game_id, @game_id)
  end
end
