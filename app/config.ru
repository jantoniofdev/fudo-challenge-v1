require './app'
require 'redis'

class FudoMiddleware

  def initialize(app)
    @app = app
    @redis = Redis.new(host: 'localhost', port: 6379)
    @redis.flushall
    @static_authors = Rack::Static.new(
      app,
      urls: { "/authors" => 'AUTHORS.html' },
      root: 'public'
    )
    @static_openapi = Rack::Static.new(
      app,
      urls: { "/openapi" => 'openapi.yaml' },
      root: 'public',
      header_rules: [
        [/\.(yaml)$/, { 'cache-control' => 'public, max-age=86400' }]
      ]
    )
  end

  def call(env)
    path = env['PATH_INFO'] || ''
    if path.start_with?('/authors')
      env['HTTP_CACHE_CONTROL'] = 'public, max-age=0'
      return @static_authors.call(env)
    elsif path.start_with?('/openapi')
      return @static_openapi.call(env)
    end
    if env['HTTP_ENCODING'] = 'gzip'
      Rack::Deflater.new(@app).call(env)
    else
      @app.call(env)
    end
  end
  
end

app = App.new
use FudoMiddleware
run app