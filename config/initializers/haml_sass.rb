Sass::Plugin.options[:style] = :compact if RAILS_ENV == 'production'
Sass::Plugin.options[:template_location] = "#{RAILS_ROOT}/app/views/layouts/sass"