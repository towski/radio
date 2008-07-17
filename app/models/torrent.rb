class Torrent < ActiveRecord::Base
  has_one :album
  belongs_to :library

  def torrent_name
    File.basename(self.path).sub(/\.torrent$/,'').gsub(/_/,' ')
  end

  validates_presence_of :path

  def download
    initial_screens = `ps -e | grep screen`.split("\n")
    `cd /music/downloads; screen -m -d btdownloadheadless #{path} --saveas #{DOWNLOAD_DIR+File.basename(path).sub(/\.torrent/,'')}`
    sleep 3
    after_screens = `ps -e | grep screen`.split("\n")
    new_screen_pid = (after_screens - initial_screens).first.split(" ").first
    sleep 72000
    puts "pid:" + new_screen_pid.to_s
    `kill #{new_screen_pid}`
    finish
  end

  def finish
    destination = DOWNLOAD_DIR+File.basename(path).sub(/\.torrent/,'')
    l = Library.find(:first)
    FileUtils.move(destination, ALBUM_DIR+File.basename(destination))
    l.add_to_library((ALBUM_DIR + File.basename(destination)), self)
    self.downloaded = true
    save!
  end

  def seed
    initial_screens = `ps -e | grep screen`.split("\n")
    `cd /music/albums; screen -m -d btdownloadheadless #{path} --saveas #{ALBUM_DIR+File.basename(path).sub(/\.torrent/,'')}`
    sleep 3
    after_screens = `ps -e | grep screen`.split("\n")
    new_screen_pid = (after_screens - initial_screens).first.split(" ").first
    sleep 72000
    puts "pid:" + new_screen_pid.to_s
    `kill #{new_screen_pid}`
  end
end
