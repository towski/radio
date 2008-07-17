#!/usr/bin/ruby
#

transaction_pieces = [ "date", "desc", "amount", "balance" ]

require 'rubygems'
require 'mechanize'
require 'breakpoint'
require 'logger'


agent = WWW::Mechanize.new{ |a| 
	a.user_agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.4) Gecko/20070515 Firefox/1.5.0.9 " 
	a.log = Logger.new('octfcu.log')
}

log = Logger.new('/tmp/transaction.log')

loop {

	log.info "Starting daemon"
	agent.get("http://www.octfcu.org")
	log.info "Signed in status is: "+agent.current_page.code+"\n"
	form = agent.current_page.forms.name(/form1/).first
	form.fields.name(/MemberID/).value = "286393"
	form.fields.name(/Pass/).value = "s9m2b3"
	agent.submit(form)

	agent.click agent.current_page.links.text(/ACCESS CHECKING/)
	page = agent.current_page
	a =(page/"td/a").find{|a| a.inner_html =~ /Trans/ }
	outside_table = a.parent.parent.parent.parent.parent.parent
	our_table = outside_table.following
	trs = (our_table/"tr")

	transactions = Array.new
	trs.each do |tr|
		transaction = Hash.new
		i = 0
		(tr/"td").each do |td|
			unless td.children.size > 1
				if td.children_of_type 'text()'
					transaction[transaction_pieces[i]]= td.inner_html 
					i += 1
				end
			end
		end
		transactions.push transaction  
	end

	transaction_string = Marshal.dump(transactions)
	transaction_object = File.open('/tmp/transaction_object','w')
	transaction_object.write(transaction_string)
	transaction_object.close

	agent.click page.links.text(/Log Out/)
	log.info "Signed out status is: "+agent.current_page.code+"\n"

	log.info "Sleeping"
	sleep 60*60*24
}
