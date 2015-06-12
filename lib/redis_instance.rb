class RedisInstance
  def self.instance
    @@redis ||= Redis.new
  end
end