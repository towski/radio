require '/root/rails/ballerina/script/torrent_filer'

filer = TorrentFiler.new

loop do
	begin
    begin 
      filer.login
      filer.goto_most_seeders
      filer.download_torrents
      filer.goto_highest_rated
      filer.download_torrents
      filer.logout 
      filer.marshal_torrents
    rescue EOFError => e
      filer.log_error( $! )
    end
    sleep 60*60
	rescue 
		filer.log_error( $! )
    exit
	end
end
