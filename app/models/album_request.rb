class AlbumRequest < Request
  def get_request
    album = Album.find(self.request_id)
    song = album.songs.find(:all)[rand(album.songs.count)]
  end

  def request_string
    album = Album.find(self.request_id)
    "album \""+album.name.titleize+"\" by "+album.artist.name.titleize
  end
end
