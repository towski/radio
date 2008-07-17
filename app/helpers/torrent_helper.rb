module TorrentHelper
  def downloaded_column(record)
    inner = if record.downloaded
      link_to_remote "seed", :update => "downloaded_span_#{record.id}", :url => {:action => :seed, :id => record.id}
    elsif record.requested
      if session[:bt] and session[:torrent_id].to_i == record.id
        percent = MiddleMan.get_worker(session[:bt]).percent
        "%.2f"%percent+"% done "+link_to_remote("stop", :update => "downloaded_span_#{record.id}", :url => {:action => :stop_download, :id => record.id})
      else
        "requested"
      end
    else
      if session[:bt]
        "no"
      elsif Seeder.find_by_torrent_id(record.id)
        "seeding"
      else
        link_to_remote "download", :update => "downloaded_span_#{record.id}", :url => {:action => :download, :id => record.id}
      end
    end
    "<span id='downloaded_span_#{record.id}'>"+inner+"</span>"
  end
  
  def torrent_name_column(record)
    link_to record.torrent_name, "http://www.indietorrents.com/details.php?id=#{record.tracker_number}"
  end
end
