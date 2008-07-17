require "rubytorrent"
require 'ftools'
# Put your code that runs your task inside the do_work method
# it will be run automatically in a thread. You have access to
# all of your rails models if you set load_rails to true in the
# config file. You also get @logger inside of this class by default.
class DownloaderWorker < BackgrounDRb::MetaWorker
  set_worker_name :downloader_worker

  def create(args)
    logger.info args.to_yaml
    begin
      torrent = Torrent.find(args)
      logger.info "heymofo"
      torrent.download
      logger.info "heyagain"
    rescue
      logger.info $!
    end
  end

  def percent
    "downloading"
  end
end
