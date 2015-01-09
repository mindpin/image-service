module TagMethods
  extend ActiveSupport::Concern 

  WRITE_TAGS_URL   = File.join ENV['TAGS_SERVICE'], "write_tags"
  READ_TAGS_URL    = File.join ENV['TAGS_SERVICE'], "read_tags"
  FIND_BY_TAGS_URL = File.join ENV['TAGS_SERVICE'], "find_by_tags"

  def add_tags(tags)
    return [] if tags.blank?
    raise 'url_info 还没有保存' if self.id.blank?
    param = {
      token: _user_token, 
      scope: ENV['TAG_SCOPE'],
      key: self.id.to_s,
      tags: tags
    }
    uri = URI.parse(WRITE_TAGS_URL)
    res = Net::HTTP.post_form(uri, param)
    raise '创建 tags 失败' if res.code != "200"
    info = JSON.parse(res.body)
    info["tags"]
  end

  def tags_array
    raise 'url_info 还没有保存' if self.id.blank?
    uri = URI.parse(_read_tags_url(_user_token))
    res = Net::HTTP.get_response(uri)
    raise '获取 tags 失败' if res.code != "200"
    info = JSON.parse(res.body)
    info["tags"]
  end

  private

  def _user_token
    return "anonymous" if user.blank?
    user.id.to_s
  end

  def _read_tags_url(token)
    "#{READ_TAGS_URL}?token=#{token}&scope=#{ENV['TAG_SCOPE']}&key=#{self.id}"
  end

  module ClassMethods
    def find_by_tags(user, tag_array)
      tags = tag_array*","
      uri = URI.parse(_find_by_tags_url(user.token, tags))
      res = Net::HTTP.get_response(uri)
      raise '获取失败' if res.code != "200"
      info = JSON.parse(res.body)
      info["keys"].map do |key_hash|
        UrlInfo.find(key_hash["key"])
      end
    end

    def _find_by_tags_url(token, tags)
      "#{FIND_BY_TAGS_URL}?token=#{token}&scope=#{ENV['TAG_SCOPE']}&tags=#{CGI.escape tags}"
    end
  end
end