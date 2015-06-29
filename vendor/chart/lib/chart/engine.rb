module Chart
  class Engine < ::Rails::Engine
    isolate_namespace Chart
    config.to_prepare do
      # ApplicationController.helper ::ApplicationHelper
    end

    initializer 'chart.assets.precompile' do |app|
      %w(stylesheets javascripts fonts images).each do |sub|
        app.config.assets.paths << root.join('assets', sub).to_s
      end
    end

  end
end
