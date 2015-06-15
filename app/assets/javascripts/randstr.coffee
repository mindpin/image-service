jQuery.randstr = (length)->
  if null == length || "undefined" == typeof length
    length = 8
  base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  size = base.length
  re = ''
  re += base[Math.floor(Math.random()*(size-10))]
  for num in [1..length-1]
    re += base[Math.floor(Math.random()*size)]
  re
