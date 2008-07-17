class ArtistController < ApplicationController
  active_scaffold :artist do |config|
    list.sorting = { :name => 'ASC' }
    config.actions = [:list, :nested, :search]
    request_link = ActiveScaffold::DataStructures::ActionLink.new("request")
    request_link.type = :record
    request_link.action = "make_request" # "download"
    config.action_links << request_link
    skip = ActiveScaffold::DataStructures::ActionLink.new("Skip")
    skip.type = :table
    skip.action = "skip_song" # "download"
    skip.parameters = {:controller => "library"}
    config.action_links << skip
    download_link = ActiveScaffold::DataStructures::ActionLink.new("Download Torrents")
    download_link.type = :table
    download_link.action = "index" # "download"
    download_link.inline = false
    download_link.parameters = {:controller => "torrent"}
#    config.action_links << download_link
    list.columns.exclude :library
    #disable eager loading
    #config.columns[:albums].includes = nil
    #search by album name too
    config.columns[:albums].search_sql = 'albums.name'
    config.search.columns << :albums
    config.list.per_page = 10
  end

  def make_request
    unless params[:id].empty?
      ArtistRequest.create(:request_id => params[:id])
    end
  end
end
