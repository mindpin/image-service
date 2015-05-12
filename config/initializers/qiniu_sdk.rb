require 'qiniu'

Qiniu.establish_connection! :access_key => ENV['QINIU_APP_ACCESS_KEY'],
                            :secret_key => ENV['QINIU_APP_SECRET_KEY']