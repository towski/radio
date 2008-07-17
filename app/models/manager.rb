require_gem 'activerecord'

ActiveRecord::Base.logger = Logger.new(STDOUT)

conn = ActiveRecord::Base.establish_connection(
:adapter => 'mysql',
:host => 'localhost',
:database => 'library',
:username => 'library',
:password => 'library')

library = Libraries.find(:first)
