#require 'rubygems'
#require_gem 'activerecord'

#ActiveRecord::Base.logger = Logger.new(STDOUT)

#conn = ActiveRecord::Base.establish_connection(
#:adapter => 'mysql',
#:host => 'localhost',
#:database => 'radio_dev',
#:username => 'root',
#:password => 'alimander-83')

class Migrations < ActiveRecord::Migration
	def self.create_all
		self.create_building
	end

  def self.create_building
		create_table :buildings do |t|
			t.column :id, :int, :default => nil
			t.column :data, :text, :default => nil
		end
	end

  def self.drop_all
		tables.each{ |t| drop_table t }
  end
end
