
require "Dex_Rack"

Dex_Rack.set :dex, ((Dex.db ':memory:') && Dex)

run Dex_Rack
