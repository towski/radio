class SongRequest < Request
  def get_request
    Song.find(self.request_id)
  end

  def request_string
    song = Song.find(self.request_id)
    "song \""+song.title.titleize+"\" on album "+song.album.name.titleize+" by "+song.album.artist.name.titleize
  end
end
