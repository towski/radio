class Album < ActiveRecord::Base
  belongs_to :artist
  belongs_to :torrent
  has_many :songs
  validates_presence_of :name
end
