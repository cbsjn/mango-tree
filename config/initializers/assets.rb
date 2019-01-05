# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( map.js )
Rails.application.config.assets.precompile += %w( SmoothScroll.js )
Rails.application.config.assets.precompile += %w( jarallax.js )
Rails.application.config.assets.precompile += %w( jquery.countTo.js )
Rails.application.config.assets.precompile += %w( all.js )
Rails.application.config.assets.precompile += %w( anchors.nav.js )

Rails.application.config.assets.precompile += %w( bootstrap.min.css )
Rails.application.config.assets.precompile += %w( fontello.css )
Rails.application.config.assets.precompile += %w( idangerous.swiper.css )
Rails.application.config.assets.precompile += %w( style.css )
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
Rails.application.config.assets.precompile += %w( home.css )

