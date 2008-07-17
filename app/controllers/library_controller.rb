class LibraryController < ApplicationController
  require 'breakpoint'
  def index
    redirect_to :action => :list
  end

  #before_filter :get_library

  def list
    @library = get_library
    @artists = @library.artists.find(:all, :order => "name")
    @requests = @library.requests
  end

  def get_albums
    @albums = Album.find_all_by_artist_id(params["artist_id"])
  end

  def get_songs
    @songs = Song.find_all_by_album_id(params["album_id"], :order => "track")
  end

  def skip_song
    get_library.skip_song
  end

  def next_song
    if params[:secret] == "secret"
      if Request.count == 0
        @song = Song.find(:first, :order => 'rand()', :limit => 1 )
      else
				request = Request.find(:first,:order => :created_on)
        @song = request.get_request
        unless @song
          @song = Song.find(:first, :order => 'rand()', :limit => 1 )
        end
        request.destroy
      end
    else
      redirect_to :action => :list
    end
    render :layout => false
  end

  def update_library
    get_library.refresh
    redirect_to :action => :list
  end

  def album_request
    unless params[:album_id].empty?
      get_library.requests << AlbumRequest.create(:request_id => params[:album_id])
    end
    redirect_to :action => :list
  end

  def song_request
    unless params[:song_id].empty?
      get_library.requests << SongRequest.create(:request_id => params[:song_id])
    end
    redirect_to :action => :list
  end

  #private
  def get_library
    Library.find(:first)
  end

  def listen
    redirect_to "http://bymatthew.com:8000/ices.m3u"
  end

end
