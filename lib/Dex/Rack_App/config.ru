
require "sinatra/base"
require "sinatra/reloader"
require "Dex/Rack_App"


run Dex::Rack_App
