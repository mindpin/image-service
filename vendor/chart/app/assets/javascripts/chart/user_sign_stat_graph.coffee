class UserSignStatGraph
  constructor: (options)->
    @$graph = options.elm
    @api_url = options.api_url
    @init()

  init: ->
    @graph_width = @$graph.width()
    @graph_height = @$graph.height()

    @axis_height = 25
    @axis_margin = 5


  render: (dataset)->
    @$graph.find('svg').remove()

    @dataset = dataset
    @dataset.data = jQuery.map dataset.data, (item, a)->
      {count: item.count, day: a, time: "#{dataset.time}-#{a}", date: new Date "#{dataset.time}-#{a}"}

    @dataset.data = @dataset.data.sort (a,b)->
      parseInt(a.day) - parseInt(b.day)

    data_length = @dataset.data.length
    height_without_axis = @graph_height - @axis_height - @axis_margin
    max = d3.max jQuery.map @dataset.data, (item)-> item.count

    rect_width = @graph_width / data_length

    x_scale = d3.scale.linear()
      .domain [0, data_length]
      .range [0, @graph_width]

    y_scale = d3.scale.linear()
      .domain [0, max]
      .range [height_without_axis, 0]

    height_scale = d3.scale.linear()
      .domain [0, max]
      .range [0, height_without_axis]

    color_scale = d3.scale.linear()
      .domain [0, max]
      .range ['#99D7E2', '#25807F']

    first_date = d3.min jQuery.map @dataset.data, (item)-> item.date
    last_date = d3.max jQuery.map @dataset.data, (item)-> item.date
    axis_scale = d3.time.scale()
      .domain [first_date, last_date]
      .range [0, @graph_width]
    axis_date_format = d3.time.format('%d')


    tip = d3.tip()
      .attr
        'class': 'bar-tip'
      .offset [-10, 0]
      .html (data)->
        date_str = data.time
        """
          <div class='time'>
            <span>时间:</span>
            <span class='time-text'>#{date_str}</span>
          </div>
          <div class='count'>
            <span>注册人数:</span>
            <span class='count-text'>#{data.count}</span>
          </div>
          <div class='tip'>
            点击查看详细列表
          </div>
        """

    svg = d3.select @$graph[0]
      .append('svg')
      .attr
        'width': @graph_width
        'height': @graph_height
      .call tip

    click_ = (date)->
      window.open "/chart/users/sign_list?time=#{date.time}","_blank"

    svg.selectAll('rect.bar')
      .data dataset.data
      .enter()
      .append 'rect'
      .attr
        'class': 'bar'
        'x': (data, idx)->
          x_scale(idx)
        'y': (data, idx)->
          y_scale(data.count)
        'width': ->
          rect_width - 1
        'height': (data, idx)->
          height_scale(data.count)
        'fill': (data)->
          color_scale(data.count)
      .on
        'mouseover': tip.show
        'mouseout': tip.hide
        'click': click_


    xaxis = d3.svg.axis()
      .scale axis_scale
      .orient 'bottom'
      .tickFormat axis_date_format

    svg.append('g')
      .call xaxis
      .attr
        'class': 'axis'
        'transform': =>
          "translate(0, #{@graph_height - @axis_height})"

  request: (time)->
    @time = time
    jQuery.ajax
      type: 'GET'
      url: @api_url
      data:
        time: @time
      success: (res)=>
        @render res


if not console.debug?
  console.debug = -> {}

jQuery ->
  current_date = new Date()
  month = current_date.getMonth()+1
  month = if month >= 10 then "#{month}" else "0#{month}"
  year  = current_date.getFullYear()
  time = "#{year}-#{month}"

  if jQuery('.page-stat.user-sign .graph').length > 0
    new UserSignStatGraph({
      elm: jQuery('.page-stat.user-sign .graph')
      api_url: 'http://192.168.0.39:3000/chart/users/sign_stat_data'
    }).request(time)

  jQuery('.page-stat.user-sign .form button').on 'click', ->
    time = jQuery('.page-stat.user-sign .form input[name="time"]').val()
    new UserSignStatGraph({
      elm: jQuery('.page-stat.user-sign .graph')
      api_url: 'http://192.168.0.39:3000/chart/users/sign_stat_data'
    }).request(time)
