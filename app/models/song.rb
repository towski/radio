require 'mp3info'
require 'id3lib'

class Song  < ActiveRecord::Base
  validates_presence_of :song_path
  belongs_to :album

  after_create :set_variables

	def set_variables
    Dir.chdir("/music/albums/")
    begin
      unless File.size(song_path) > 0
        File.unlink(song_path)
        raise EmptyFile, "Cannot create song, file is empty"
      end
      
      #if File.size(song_path) > 10000000
        #return
      #end
      @song_path = song_path

      mp3 = ID3Lib::Tag.new(song_path)
      if mp3
        self.artist = mp3.artist.gsub(/(\000|\377|\376)/,'') if mp3.artist
        self.title = mp3.title.gsub(/(\000|\377|\376)/,'') if mp3.title
        self.track = mp3.track.gsub(/(\000|\377|\376)/,'') if mp3.track
        self.album_name= mp3.album.gsub(/(\000|\377|\376)/,'') if mp3.album
        mp3 = Mp3Info.new(song_path)
        self.length = mp3.length
      else
        mp3 = Mp3Info.new(song_path)
        self.length = mp3.length
      end

      #if self.track
        #self.track = self.track.sub(/\/\d*/,'')
      #else
        #self.track =~ /^(\d*)/
        #self.track = $1
      #end
      
      self.save
    rescue
      raise $!
    end
  end

    #def_delegator :@info, :push, :enq
	#def_delegators :@mp3, :length, :artist, :track,:album,:title
	#, :title, :year, :shift, :size
		
end

