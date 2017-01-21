$KCODE = 'UTF-8'
class GraphController < ApplicationController
  
  def bar
    items = params[:items]
    values = params[:values].collect{|v|v.to_i}
    g = Graph.new
    g.set_bg_color('#FFFFFF')
    bar1 = Bar.new(50, '#0066CC')
    values.each do |v|
      bar1.data << v
    end
    g.data_sets << bar1
    g.set_x_labels(items)
    g.set_x_label_style(10, '#FFFFFF', 0)
    g.set_x_axis_steps(0)
    r = 5 - (values.max % 5)
    ymax = values.max + r
    g.set_y_max(ymax)
    g.set_y_label_steps(5)
    #g.set_y_legend("Open Flash Chart", 12, "0x736AFF"))
    g.title("  ","{font-size: 16px;}")
    render :text => g.render
  end

  def pie
    g = Graph.new
    g.set_bg_color('#FFFFFF')
    g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
    if params[:links]
      g.pie_values(params[:values],params[:items], params[:links])      
    else
      g.pie_values(params[:values],params[:items])
    end
    g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
    g.title(" ", '{font-size:18px; color: #d01f3c}' )
    render :text => g.render
  end

end