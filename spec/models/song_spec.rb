require File.dirname(__FILE__) + '/../spec_helper'

describe Song do
  before(:each) do
    Song.const_set "HOME_DIR", RAILS_ROOT + "/test/fixtures/"
    @song = Song.new :song_path => RAILS_ROOT + "/test/fixtures/song.mp3"
  end

  it "should get data out of the file after it is created" do
    @song.save
    @song.artist.should == "Amy Winehouse"
    @song.title.should == "Rehab"
    @song.length.floor.should == 215
    @song.track == 1
  end
end
