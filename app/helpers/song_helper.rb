module SongHelper
  def length_column(record)
    ("%d:%d"%[record.length/60,record.length%60])
  end
end
