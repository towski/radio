require 'find'
class Library < ActiveRecord::Base
  has_many :artists
  has_many :requests
  has_many :torrents

	def verify_tags
		Dir.foreach(HOME) do |album| 
			next if album =~ /\.{1,2}/ 
			Dir.foreach(album) do |song|
				#puts "Checking "+album+"/"+song
				next if song =~ /^\.{1,2}$/ 
				next if song !~ /mp3$/ 
				new_song = Song.new(album+"/"+song)
				puts song
				puts [new_song.artist,new_song.album,new_song.title,new_song.track].join('-')
				unless new_song.artist and new_song.album and new_song.title and new_song.track
					raise "Found an untagged file"
				end
			end
		end
		return true
	end

	def random_song
    artist = Artist.find(:first,'rand',1)
		album = artist.albums.find(:first,'rand',1)
    songs = album.songs.find(:first,'rand',1)
	end

  def skip_song
    `pkill -10 ices`
  end

	def next_song
		#modify_rating
    if self.requests.empty?
      return Song.find(:first, :order => 'rand()', :limit => 1 )
    else
      req = self.requests.find(:first)
      next_song = req.get_request
      req.destroy
      return next_song
    end
	end

	def modify_rating
	end
	
	def refresh dir
    Find.find(dir) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?.
          Find.prune       # Don't look any further into this directory.
        else
          next
        end
      else
				next if path !~ /mp3$/ 

        song_path = path
        unless Song.find(:first, :conditions => ["song_path like ?", song_path])
          begin
            new_song = Song.create(:song_path => song_path )
            artist = nil
            new_album = nil

            artist = Artist.find(:first, :conditions => ["name like ?",new_song.artist])
            unless artist
              artist = Artist.create(:name =>new_song.artist)
              self.artists << artist
            end

            new_album = artist.albums.find(:first, :conditions => ["name like ?",new_song.album_name])
            unless new_album
              new_album = Album.create(:name => new_song.album_name)
              artist.albums << new_album
            end

            unless new_album.songs.find(:first, :conditions => ["title like ?",new_song.title])
              new_album.songs << new_song
            end
            new_album.save
            artist.save
          rescue EmptyFile
          end
        end
      end
      #if we deleted all the mp3s in the directory, delete the dir
      #unless Dir.entries(Home+album).find_all{ |f| f =~ /mp3$/ }.size > 2
        #require 'fileutils'
        #FileUtils.remove_entry(Home+album)
      #end
      self.save
		end
	end

  def add_to_library dir, torrent
    Find.find(dir) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?.
          Find.prune       # Don't look any further into this directory.
        else
          next
        end
      else
        next if path !~ /mp3$/ 
        song_path = path.sub(/downloads/,'albums') 
        unless Song.find(:first, :conditions => ["song_path like ?", song_path])
          begin
            new_song = Song.create(:song_path => song_path)
            artist = nil
            new_album = nil

            artist = Artist.find(:first, :conditions => ["name like ?",new_song.artist])
            unless artist
              artist = Artist.create(:name =>new_song.artist)
              self.artists << artist
            end

            new_album = artist.albums.find(:first, :conditions => ["name like ?",new_song.album_name])
            unless new_album
              new_album = Album.create(:name => new_song.album_name)
              artist.albums << new_album
            end

            unless new_album.songs.find(:first, :conditions => ["title like ?",new_song.title])
              new_album.songs << new_song
            end
            new_album.torrent = torrent
            new_album.save
            artist.save
          end
        end
      end
    end
  end

end

class EmptyFile < Exception; end
