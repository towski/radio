class ArtistRequest < Request
  def get_request
    artist = Artist.find(self.request_id)
    album = artist.albums.find(:all)[rand(artist.albums.count)]
    if album
      song = album.songs.find(:all)[rand(album.songs.count)]
    end
  end

  def request_string
    "artist "+Artist.find(self.request_id).name.titleize
  end
end
