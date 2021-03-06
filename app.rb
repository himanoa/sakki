require 'active_support/all'
require 'continuation'
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
  FEED_LINK = 'https://himanoa.com'.freeze
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
    TITLE = 'okimoti.out.println'.freeze
    def entry_repository
      @@entry_repository ||= EntryRepository.new(App.database)
    end

    def res(request)
      auth = Rack::Auth::Digest::MD5.new(Sinatra::Base, ENV['BLOG_REALM']) do |user|
        hash = {}.with_indifferent_access
        hash[ENV['BLOG_USERNAME']] = ENV['BLOG_PASSWORD']
        hash[user]
      end
      auth.opaque = 'posapdoasd'
      auth.call(request.env)
    end

    def protected!
      response = res(request)
      throw(:halt, response) if response.first == 401
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
    count = entry_repository.size
    p count
    slim :index
  end

  get '/entries/:id/edit' do
    protected!
    @entry = entry_repository.fetch(params[:id].to_i)
    @method = 'POST'
    @action = "/entries/#{params[:id]}"
    @is_edit= true
    slim :new
  end
  post '/entries/:id' do
    protected!
    title = params[:title]
    body = params[:body]
    id = params[:id]
    posted_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    entry_repository.update(id.to_i, title, body, posted_at)
    redirect to("/entries/#{id}")
  end
  get '/entries/new' do
    protected!
    @entry = Entry.new
    @entry.title = ''
    @entry.body = ''
    @method = 'POST'
    @action = '/entries'
    @is_edit = false
    slim :new
  end

  enable :method_override
  delete '/entries/:id' do
    protected!
    id = params[:id]
    entry_repository.delete(id.to_i)
    redirect to("/entries")
  end

  post '/entries' do
    protected!
    entry = Entry.new
    entry.title = params[:title]
    entry.body = params[:body]
    entry.body_html = entry.to_html
    entry.posted_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    entry.published = 1
    id = entry_repository.save(entry)
    url = request.url
    redirect to("/entries/#{id}")
    slim :index
  end

  get '/sitemap' do
    headers \
      "Content-type" => "text/xml; charset=utf-8"
    map = XmlSitemap::Map.new("himanoa.com") do |m|
      m.add('/entries.rss')
      m.add('/entries')
      entry_repository.each.each do |e|
        m.add("/entries/#{e.id}")
      end
    end
    map.render
  end
  get '/entries.rss' do
    headers \
      "Content-type" => "text/xml; charset=utf-8"
    RSS::Maker.make('2.0') do |rss|
      rss.channel.title = title
      rss.channel.description = TITLE
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
    if @entry.body_html.nil?
      @entry.body_html = entry_repository.update_html(params[:id].to_i, @entry.to_html)
    end
    slim :entry
  end
end
