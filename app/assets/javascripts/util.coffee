###
  一个小扩展，用于获取元素相对于当前浏览器窗口区域的位置
  返回对象包括 top, left, bottom, right 四个属性
  top    元素上边缘和窗口上边缘的距离（如果上边缘在窗口区域外则为负值）
  left   元素左边缘和窗口左边缘的距离（如果左边缘在窗口区域外则为负值）
  bottom 元素下边缘和窗口下边缘的距离（如果下边缘在窗口区域外则为负值）
  right  元素右边缘和窗口右边缘的距离（如果右边缘在窗口区域外则为负值）
  计算元素上下左右边缘时不包括 margin 值
  
  -> http://stackoverflow.com/questions/3714628/jquery-get-the-location-of-an-element-relative-to-window
###
jQuery.fn.offset_of_window = ->
  offset = this.offset()
  off_top    = offset.top
  off_left   = offset.left
  off_bottom = off_top + this.height()
  off_right  = off_left + this.width()
  jqw = jQuery(window)
  window_scroll_left = jqw.scrollLeft()
  window_scroll_top = jqw.scrollTop()
  {
    left: off_left - window_scroll_left
    top: off_top  - window_scroll_top
    bottom: jqw.height() + window_scroll_top - off_bottom
    left: jqw.width() + window_scroll_left - off_right
  }


###
  一个小扩展，用于计算指定的元素是否在当前浏览器窗口之内
  只要有任何一部分在窗口之内，就返回 true
  如果完全在窗口之外，则返回 false
  此方法一般用于实现图片 lazy load 等特性
###
jQuery.fn.is_in_screen = ->
  oow = this.offset_of_window()
  jqw = jQuery(window)
  return false if oow.top > jqw.height()
  return false if oow.bottom > jqw.height()
  return false if oow.left > jqw.width()
  return false if oow.right > jqw.width()
  return true


window.Util = 
  ###
    网格计算辅助方法
    根据传入的总长度，grid 个数（默认1），grid 之间的间隔（默认0），返回一个对象
    该对象包含以下属性：
      side_length:
        每个网格的长度
      positions:
        数组，长度为 grid 个数，包含的数据是每个 grid 的起始坐标位置
  ###
  spacing_grid_data: (length, grid_count = 1, spacing = 0)->
    side_length = (length - spacing * (grid_count - 1)) / grid_count
    {
      side_length: side_length
      positions: for i in [0 ... grid_count]
        i * (side_length + spacing)
    }

  ###
    一个小扩展，初始化一个数组，并使用指定的方法返回的结果填充
    传入两个参数，第一个参数是数组长度，第二个参数是指定的方法
    两个参数都可以省略，如果省略时，默认使用 null 填充
    之所以不是简单地传入指定的对象来填充，是为了避免对象的引用重复，例如：
    传入 {height: $height} 这样的对象时，会造成对 $height 的重复引用
  ###
  array_init: (length = 0, func = -> null)->
    (func(i) for i in [0 ... length])

  ###
    一个小扩展，用于计算数组中最大/最小的数值
    传入数组作为参数，返回最大/最小的数值
  ###
  array_max: (array)->
    Math.max.apply null, array
  array_min: (array)->
    Math.min.apply null, array