class TorrentController < ApplicationController
  active_scaffold :torrent do |config|
    #download_link.security_method = "torrent_downloaded?" # "download"
    list.sorting = { :uploaded_at => 'DESC' }
    update_torrents = ActiveScaffold::DataStructures::ActionLink.new("Update")
    update_torrents.type = :table
    update_torrents.action = "update_torrents"
    config.action_links << update_torrents
    update_torrents = ActiveScaffold::DataStructures::ActionLink.new("Artists")
    update_torrents.type = :table
    update_torrents.action = "index"
    update_torrents.inline = false
    update_torrents.parameters = {:controller => "artist"}
    config.action_links << update_torrents
    config.actions = [:list, :nested, :search]
    config.list.columns = []
    config.list.columns << :torrent_name
    config.list.columns << :created_on
    config.list.columns << :uploaded_at
    config.list.columns << :downloaded
  end

  def conditions_for_collection
    ["uploaded_at > '#{700.hours.ago.to_s(:db)}' "]
    #and library_id = #{session[:tracker]}"]
  end

  def update_torrents
    @filer = TorrentFiler.new(Library.find(:first))
    begin 
      @filer.login_to_indietorrents
      @filer.agent.click @filer.browse_link
      @filer.download_current_page
      @filer.logout 
    rescue EOFError => e
      @filer.log_error( $! )
    end
    render :layout => false, :nothing => true
  end

  def download
    torrent = Torrent.find(params[:id])
    MiddleMan.new_worker :worker => :downloader_worker, :job_key => torrent.id, :data => params[:id]
    torrent.requested = true
    torrent.save
  end

  def stop_download
      t = Torrent.find(session[:torrent_id])
      t.requested = false
      t.save
      MiddleMan.delete_worker(session[:bt])
  end

  def seed
    torrent = Torrent.find(params[:id])
    MiddleMan.new_worker :worker => :seeder_worker, :job_key => torrent.id, :data => params[:id]
    render :nothing => true
  end
end
