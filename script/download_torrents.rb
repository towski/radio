#!/usr/bin/ruby
require 'ftools'
require 'logger'


Home = '/music/'
Torrent_dir = Home + 'torrents/'
Album_dir = Home + 'albums/'
Download_dir = Home + 'downloads/'

log = Logger.new(Download_dir+'download.log')

begin
  threads = Array.new
  Dir.entries("/music/torrents").each do |torrent_file| 
    next if torrent_file =~ /^\.{1,2}$/ 
    next if torrent_file !~ /torrent$/ 
    album_download = torrent_file.gsub(/\.torrent/,'')
    p "Checking if #{Album_dir}#{album_download} exists"
    unless File.exists? Album_dir+album_download
      p "Downloading #{album_download} to #{Download_dir}"
      thread = Thread.new do 
        `screen btdownloadheadless '#{Torrent_dir+torrent_file}' --saveas '#{Download_dir+album_download}'`
        begin
          old_sum,new_sum = 0,0
          loop do
            sleep 120 
            old_sum = new_sum
            new_sum=0
            Dir.entries(Download_dir+album_download).each do |file|
              new_sum += File.size(Download_dir+album_download+"/"+file)
            end
            p(old_sum.to_s+" -> "+new_sum.to_s)

            if new_sum == old_sum
              sleep 24.hours
              p "Killing downloader"
              return
            end
          end
        rescue
          raise $!
          log.error( $! )
        end
      end
      threads << thread
      #thread.abort_on_exception = true
      p File.move(Download_dir+album_download,Album_dir+album_download, true)
    end
    p "Done with #{album_download}"
  end
  threads.each{|t| t.join }
rescue 
  log.error( $! )
  raise $!
end
