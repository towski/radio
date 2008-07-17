class SongController < ApplicationController
  active_scaffold :song do |config|
    config.list.sorting = {:track => 'ASC'}
    config.list.columns = [ :track, :title, :length]
    config.actions = [:list, :nested, :search]
    request_link = ActiveScaffold::DataStructures::ActionLink.new("request")
    request_link.type = :record
    request_link.action = "make_request" # "download"
    config.action_links << request_link
  end

  def make_request
    unless params[:id].empty?
      SongRequest.create(:request_id => params[:id])
    end
  end
end
