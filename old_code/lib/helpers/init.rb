require_relative 'auth_helper'
require_relative 'img_helper'
require_relative 'upload_helper'

ImageServiceApp.helpers AuthHelper
ImageServiceApp.helpers ImgHelper
ImageServiceApp.helpers UploadHelper
