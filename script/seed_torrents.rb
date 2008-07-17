#!/usr/bin/ruby
require 'ftools'

Home = '/music/'
Torrent_dir = Home + 'torrents/'
Album_dir = Home + 'albums/'
Download_dir = Home + 'downloads/'
threads = Array.new

begin
  Dir.entries("/music/torrents")[2,3].each do |torrent_file| 
    next if torrent_file =~ /^\.{1,2}$/ 
    next if torrent_file !~ /torrent$/ 
    album_download = torrent_file.sub(/\.torrent/,'')
    if File.exists? Album_dir+album_download
      p "btdownloadheadless '#{Torrent_dir+torrent_file}' --saveas '#{Album_dir+album_download}'"
      #thread.abort_on_exception = true
      t = Thread.new do
        `btdownloadheadless '#{Torrent_dir+torrent_file}' --saveas '#{Album_dir+album_download}'`
      end
      threads.push t
    end
  end
rescue 
  raise $!
end
