require 'open-uri'

filename = 'test-01-3.mp3'
code = Qiniu::Utils.urlsafe_base64_encode("#{ENV['QINIU_BUCKET']}:test-128k.mp3")
fops = 'avthumb/mp3/ab/128k|saveas/' + code

bucket = URI::encode(ENV['QINIU_BUCKET'])
key = URI::encode(filename)
fops = URI::encode(fops)

url_params = {
  :bucket => bucket,
  :key => key,
  :fops => fops
}

p url_params
# rx = Net::HTTP.post_form(URI.parse(url), url_params)

# body = rx.body

# p body

url = 'http://api.qiniu.com/pfop/'
uri = URI(url)
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Post.new(uri.path)
#req.body = URI.encode_www_form(url_params)
body = "bucket=#{bucket}&key=#{key}&fops=#{fops}"
req.body = body


access_token = Qiniu::Auth.generate_acctoken(url, body)
p access_token
p '---'


req["Authorization"] = "QBox #{access_token}"
req["Content-Type"] = 'application/x-www-form-urlencoded'

post_data = URI.encode_www_form(url_params)
p http.request(req)
