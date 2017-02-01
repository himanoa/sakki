require 'rss/maker'
require 'bundler/setup'
Bundler.require(:default)
require 'sinatra/reloader'
require 'slim/include'
require 'date'

Dir['models/*.rb'].each do |model|
  require_relative model
end

Dir['repositories/*.rb'].each do |model|
  require_relative model
end
class App < Sinatra::Base
  FEED_LINK = 'https://localhost:9292'.freeze
  configure :development do
    register Sinatra::Reloader
  end
  configure do
    set :views, settings.root + '/views'
  end

  def self.database_config
    YAML.load_file('config/database.yml')[ENV['RACK_ENV'] || 'development']
  end

  def self.database
    @database ||= Mysql2::Client.new(database_config)
  end

  helpers do
    TITLE = 'okimoti.io.println'
    def entry_repository
      @@entry_repository ||= EntryRepository.new(App.database)
    end

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['BLOG_USERNAME'], ENV['BLOG_PASSWORD']]
    end

    def title
      str = ''
      str = @entry.title + ' - ' if @entry
      str + TITLE
    end
  end

  get '/' do
    slim :aboutme
  end
  get '/entries' do
    @pager = params[:page] || 0
    slim :index
  end

  get '/entries/:id/edit' do
    protected!
    @entry = entry_repository.fetch(params[:id].to_i)
    @method = 'POST'
    @action = "/entries/#{params[:id]}"
    slim :new
  end
  post '/entries/:id' do
    protected!
    title = params[:title]
    body = params[:body]
    id = params[:id]
    posted_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    entry_repository.update(id.to_i, title, body, posted_at)
    redirect to("/entries/#{id}")
  end
  get '/entries/new' do
    protected!
    @entry = Entry.new
    @entry.title = ""
    @entry.body = ""
    @method = 'POST'
    @action = "/entries"
    slim :new
  end

  post '/entries' do
    protected!
    entry = Entry.new
    entry.title = params[:title]
    entry.body = params[:body]
    entry.posted_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    entry.published = 1
    id = entry_repository.save(entry)
    url = request.url
    redirect to("/entries/#{id}")
    slim :index
  end

  get '/entries/rss' do
    RSS::Maker.make('2.0') do |rss|
      rss.channel.title = title
      rss.channel.description = 'お気持ちアウトプット.js'
      rss.channel.link = FEED_LINK
      rss.channel.about = FEED_LINK
      entry_repository.recent(10).each do |entry|
        item = rss.items.new_item
        item.title = entry.title
        item.link = FEED_LINK + "/entries/#{entry.id}"
      end
    end.to_s
  end

  get '/entries/:id' do
    @entry = entry_repository.fetch(params[:id].to_i)
    slim :entry
  end
end
