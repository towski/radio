class Artist < ActiveRecord::Base
  has_many :albums
  belongs_to :library
  validates_presence_of :name
end
