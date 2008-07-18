require File.dirname(__FILE__) + '/../spec_helper'

describe SongRequest do
  it "should update song value for a request" do
    Song.const_set "HOME_DIR", RAILS_ROOT + "/test/fixtures/"
    song = Song.create! :song_path => RAILS_ROOT + "/test/fixtures/song.mp3"
    song.build_album(:name => "B").build_artist(:name => "A")
    SongRequest.create :request_id => song.id
    song.album.artist.value.should == 1
  end
end
