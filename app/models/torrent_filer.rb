class TorrentFiler
	require 'rubygems'
	require 'mechanize'
	require 'logger'
	require 'breakpoint'
	require 'uri'
	require 'ftools'

  attr :agent
  attr :log

	def initialize library, torrent_location = TORRENT_DIR
		@agent = WWW::Mechanize.new { |a| a.log = Logger.new(LOG_DIR+'torrent_browser.log') }
		@agent.user_agent_alias='Mac Safari' 
		@log = Logger.new(LOG_DIR+'filer.log')
    @library = library
	end

	def login_to_indietorrents
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
		#@agent.click browse_link
    @agent.get("/browse.php")
		@agent.click @agent.current_page.links.href(/orderby=avgrating&desc=/).first
		@agent.click @agent.current_page.links.href(/orderby=avgrating&desc=1/).first
	end

  def goto_friday_5
    @agent.click forum_link
		@agent.click @agent.current_page.links.href(/\?action=viewforum&forumid=5/).first
    t.agent.current_page.links.find{|l| l.href =~ /Friday 5/}
    t.agent.current_page.links.href(/details.php\?id=/).size
    #"Sticky: Friday Five"
  end

  def add_choice choice
  end

  def download_oink_torrent url
    link = @agent.current_page.links.href(url).first
    if link
      download_torrent link, 1000, Time.now, /\/downloadpk\/([^\/]*)\/(.*)/
    end
  end

  def download_torrent a, tracker_number, uploaded_at, re = /\/download.php\/(\d*)\/(.*)/
		open_bracket = /\[/
		close_bracket = /\]/
    href = a.href
    href.gsub!(open_bracket,"\91")
    href.gsub!(close_bracket,"\93")
    href = URI.escape(href)

    md = re.match(a.href)
    #key them by remote torrent id
    id = md[1]
    torrent_file = md[2]
    torrent_file = torrent_file.gsub('%20',' ').tr(' ','_').tr('\'','')
    #if the corresponding album already exists in our library, don't bother downloading the torrent
    album_file = torrent_file.gsub(/\.torrent/,'')
    if File.exists? TORRENT_DIR+torrent_file
      torrent = Torrent.find(:first, :conditions => ["path like ?",TORRENT_DIR+torrent_file])
      if torrent
        torrent.uploaded_at = uploaded_at
        torrent.tracker_number = tracker_number
        torrent.save
      else
        torrent = Torrent.create(:path => TORRENT_DIR+torrent_file, :uploaded_at => uploaded_at, :tracker_number => tracker_number, :library => @library)
      end
    else
      begin
        @log.info "Getting: "+href+""
        @agent.get_file(href)
        @agent.current_page.save_as(TORRENT_DIR+torrent_file)
        Torrent.create(:path => TORRENT_DIR+torrent_file, :uploaded_at => uploaded_at, :tracker_number => tracker_number, :library => @library)
      rescue URI::InvalidURIError
        @log.info "Bad URI.. skipping"
      end
    end
  end

	def download_current_page
		links = @agent.current_page.links.href(/download/)
    @log.info links.size.to_s+" download links"
		links.each do |a|
      td = a.node.parent.parent.parent.parent 
      string = td.next_sibling.next_sibling.next_sibling.next_sibling.inner_html
      string.gsub!(/<\/{0,1}nobr>/,'').gsub!("<br />",' ')
      uploaded_at = DateTime.parse(string)
      tracker_number = a.href.split('/')[2]
      begin
        download_torrent a, tracker_number, uploaded_at
      rescue WWW::Mechanize::ResponseCodeError
        "Ran out of permissions"
      end
		end
	end

	def logout
		@agent.click @logout_link
		@log.info "Signed out status is: "+@agent.current_page.code+""
	end

	def log_error exception
		@log.error(exception)
	end
end
