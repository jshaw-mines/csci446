class Album

  attr_accessor :rank, :title, :year

  def initialize(raw_string)
    @rank, @title, @year = raw_string.split(',')
  end

end