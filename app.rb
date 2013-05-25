
require './uncletbag'
require 'sinatra'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
end

get '/' do
  @results = []
  @q = ""
  erb :main
end

get '/search' do
  if @q = params['q']
    @results = UncleTBag.search @q
    erb :main
  else
    redirect '/'
  end
end

