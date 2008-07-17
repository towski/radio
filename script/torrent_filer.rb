class TorrentFiler
	require 'rubygems'
	require 'mechanize'
	require 'logger'
	require 'breakpoint'
	require 'uri'
	require 'ftools'

	attr :torrents
  attr :agent
  attr :log

	Dir = '/music/'
	Torrent_dir = Dir + 'torrents/'
	Album_dir = Dir + 'albums/'
  Log_dir = Dir+'logs/'

	def initialize log_location = Torrent_dir
		@agent = WWW::Mechanize.new { |a| a.log = Logger.new(Torrent_dir+'torrents.log') }
		@agent.user_agent_alias='Mac Safari' 
		@log = Logger.new(Log_dir+'filer.log')
		torrent_string = File.open(Torrent_dir+'torrent_object','r').read
		@torrents = Marshal.load(torrent_string)
	end

	def login
		@log.info "Getting indietorrents..."
		@agent.get("http://www.indietorrents.com")
		link = @agent.current_page.links.href(/login/)
		@agent.click link

		form = @agent.current_page.forms[0]
		form.fields.name(/user/).value ="towski"
		form.fields.name(/pass/).value="s9m2b3"
		if @agent.submit(form)
      @browse_link = @agent.current_page.links.href(/browse/).first
      @logout_link = @agent.current_page.links.href(/logout/).first
      unless @logout_link
        raise "Cannot get a logout link from this page"
      end
		else
			return false
		end
	end

	def home
		@agent.click @agent.current_page.links.href(/home/).first
	end

  def parse_rss category
    require 'simple-rss'
    rss = SimpleRSS.parse 

    rss.channel.title # => "Slashdot"
    rss.channel.link # => "http://slashdot.org/"
    rss.items.first.link # => "http://books.slashdot.org/article.pl?sid=05/08/29/1319236&amp;from=rss"
  end

	def goto_most_seeders
		@agent.click browse_link
		@agent.click @agent.current_page.links.href(/orderby=seeders&desc=/).first
		@agent.click @agent.current_page.links.href(/orderby=seeders&desc=1/).first
	end

	def goto_most_recent
		@agent.click browse_link
	end

  def browse_link
		@agent.current_page.links.href(/browse/).first
  end

  def forum_link
		@agent.current_page.links.href(/forums/).first
  end

	def goto_highest_rated
		@agent.click browse_link
		@agent.click @agent.current_page.links.href(/orderby=avgrating&desc=/).first
		@agent.click @agent.current_page.links.href(/orderby=avgrating&desc=1/).first
	end

  def goto_friday_5
    @agent.click forum_link
		@agent.click @agent.current_page.links.href(/\?action=viewforum&forumid=5/).first
    t.agent.current_page.links.find("")
    t.agent.current_page.links.href(/details.php\?id=/).size
    #"Sticky: Friday Five"
  end

  def add_choice choice
  end

  def download_torrents
  end

	def download_current_page
		links = @agent.current_page.links.href(/download/)
		re = /\/download.php\/(\d*)\/(.*)/
		open_bracket = /\[/
		close_bracket = /\]/
		links.each do |a|
			href = a.href
			href.gsub!(open_bracket,"\91")
			href.gsub!(close_bracket,"\93")
			href = URI.escape(href)

			md = re.match(a.href)
			#key them by remote torrent id
			id = md[1]
			torrent_file = md[2]
			torrent_file = torrent_file.tr(' ','_').tr('\'','')
			#if the corresponding album already exists in our library, don't bother downloading the torrent
      album_file = torrent_file.gsub(/\.torrent/,'')
			if File.exists? Torrent_dir+torrent_file
        @torrents.delete id
      else
				begin
					@log.info "Getting:"+href+""
					@agent.get_file(href)
					@torrents[id] = torrent_file
					@agent.current_page.save_as(Torrent_dir+torrent_file)
				rescue URI::InvalidURIError
					@log.info "Bad URI.. skipping"
				end
			end
		end
	end

	def marshal_torrents
		torrent_string = Marshal.dump(@torrents)
		torrent_object = File.open(Torrent_dir+'torrent_object','w')
		torrent_object.write(torrent_string)
		torrent_object.close
		@log.info "Finished marshalling torrents to #{Torrent_dir}torrent_object. Going to sleep"
	end

	def logout
		@agent.click @logout_link
		@log.info "Signed out status is: "+@agent.current_page.code+""
	end

	def log_error exception
		@log.error(exception)
	end
end
