module ArtistHelper
  def name_column(record)
    record.name.titleize
  end
end
