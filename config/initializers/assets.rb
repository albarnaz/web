# Be sure to restart your server when you modify this file.
module Fsek
  class Application < Rails::Application
    # Version of your assets, change this if you want to expire all your assets.
    config.assets.version = '1.0'
    config.assets.precompile += %w( application.scss )
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
    #
    # # Precompile additional assets.
    # # application.js, application.css, and all non-JS/CSS in app/assets folder are
    # already added.
    # # Rails.application.config.assets.precompile += %w( search.js )
  end
end
