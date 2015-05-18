
key = 'test-256k.mp3' 
put_policy = Qiniu::Auth::PutPolicy.new(ENV['QINIU_BUCKET'], key)
code = Qiniu::Utils.urlsafe_base64_encode("#{ENV['QINIU_BUCKET']}:#{key}")
put_policy.persistent_ops = 'avthumb/mp3/ab/256k|saveas/' + code
local_file = ENV['HOME'] + '/Downloads/01-2.mp3'
# local_file = ENV['HOME'] + '/Downloads/home.jpg'

p code
p put_policy
p local_file


# uptoken = Qiniu::Auth.generate_uptoken(put_policy)

# result = Qiniu::Storage.resumable_upload_with_token(
#   uptoken,
#   local_file,
#   ENV['QINIU_BUCKET']
# )

result = Qiniu::Storage.upload_with_put_policy(
  put_policy,
  local_file,
  key
)


p '==='

p result