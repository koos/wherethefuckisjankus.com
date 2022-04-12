# View Middleman configurations:
# http://localhost:4567/__middleman/config/


# Vars
# ----------------------------------------------
set :protocol, "https://"
set :host, "wherethefuckisjankus.com"
set :port, 80

set :css_dir,     'assets/stylesheets'
set :js_dir,      'assets/javascripts'
set :images_dir,  'assets/images'
set :fonts_dir,   'assets/fonts'

set :trailing_slash, false

# Per-page layout changes
# ----------------------------------------------
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false


# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# ----------------------------------------------
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }


# Fix permissons
# ----------------------------------------------
class FixPermissions < Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super
    app.after_build do |builder|
      builder.run 'chmod -R a+r build'
    end
  end
end

::Middleman::Extensions.register(:fix_permissions, FixPermissions)


# Extensions
# ----------------------------------------------

# activate :es6

# Activate directory indexes
activate :directory_indexes

# Active autoprefixer
activate :autoprefixer do |config|
  config.browsers = ['last 5 versions', 'Explorer >= 9']
end

# Activate Slim
::Slim::Engine.set_options format: :html


# Bower Config
# ----------------------------------------------
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  @bower_assets_path = File.join "#{root}", @bower_config["directory"]
  sprockets.append_path @bower_assets_path
end


# Helpers
# ----------------------------------------------
helpers do
  def host_with_port
    [host, optional_port].compact.join(':')
  end

  def optional_port
    port unless port.to_i == 80
  end

  def page_url
    protocol + host_with_port + current_page.url
  end

  def image_url(source)
    protocol + host_with_port + image_path(source)
  end

  def page_title
    if current_page.data.title
      "#{data.config.page.title} #{data.config.page.title_sperator} #{current_page.data.title}"
    elsif data.config.page.subtitle
      "#{data.config.page.title} #{data.config.page.title_sperator} #{data.config.page.subtitle}"
    else
      data.config.page.title
    end
  end

  def page_description
    if current_page.data.description
      current_page.data.description
    else
      data.config.page.meta.description
    end
  end

end


# Development-specific configuration
# ----------------------------------------------
configure :development do

  set :debug_assets, true

  # Output a pretty html
  ::Slim::Engine.set_options :pretty => true

  # Used for generating absolute URLs
  set :host, "localhost"
  set :port, 4567

end


# Build-specific configuration
# ----------------------------------------------
configure :build do

  # Activate gzip
  activate :gzip

  # Minify HTML
  activate :minify_html, remove_comments: true

  # Minify CSS
  activate :minify_css

  # Minify Javascript
  activate :minify_javascript, :inline => true

  # Add asset fingerprinting to avoid cache issues
  activate :asset_hash

  # Enable cache buster
  activate :cache_buster

  # Fix permissions
  activate :fix_permissions

end
