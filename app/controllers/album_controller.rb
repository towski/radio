class AlbumController < ApplicationController
  active_scaffold :album do |config|
    config.list.columns =  [:name, :songs,:rating]
    config.actions = [:list, :nested, :search]
    request_link = ActiveScaffold::DataStructures::ActionLink.new("request")
    request_link.type = :record
    request_link.action = "make_request" # "download"
    config.action_links << request_link
  end

  def make_request
    unless params[:id].empty?
      AlbumRequest.create(:request_id => params[:id])
    end
  end
end
