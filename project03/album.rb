class Album

  attr_accessor :rank, :title, :year

  def initialize(raw_string)
    raw_rank, @title, @year = raw_string.split(',')
	@rank = raw_rank.to_i
  end

end