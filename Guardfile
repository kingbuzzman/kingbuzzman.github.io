# # Clean up existing generated code
# `rm -rf *.html`
# `rm -rf css/`
# `rm -rf js/`

# Compile haml files
guard 'haml',
  :input => 'haml',
  :output => '.',
  :run_at_start => true,
  :haml_options => {
    :attr_wrapper => '"',
    :escape_attrs => false,
    :escape_html => false,
    :remove_whitespace => true,
    :ugly => true
  }

# Compile coffeescript
guard 'coffeescript',
  :input => 'coffee',
  :output => 'js',
  :bare => true,
  :source_map => false,
  :shallow => false,
  :error_to_js => true,
  :source_root => '/coffee',
  :all_on_start => true

# Compile sass
guard 'sass',
  :input => 'sass',
  :output => 'css',
  :all_on_start => true,
  :style => :compressed,
  :compass => {
    :images_dir => "/images",
    :images_path => File.join(Dir.pwd, "images"),
    :http_path => "/",
    :http_images_path => "/images",
    :http_images_dir => "/images",
    :relative_assets => true
  }