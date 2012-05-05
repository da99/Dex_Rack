
Dex\_Rack
================

A Ruby gem that provides a web frontend for exceptions logged with 
[Dex](https://github.com/da99/Dex).

Installation
------------

    sudo apt-get install sqlite3
    gem install Dex_Rack

Usage
------

Create a `config.ru` file:

    require "Dex_Rack"

    Dex_Rack.set :dex, ( Dex.db("My.SQLITE.file.db") && Dex )
    run Dex_Rack

In your shell:

    rackup -p 3000

Visit: [http://localhost:3000](http://localhost:3000)

Run Tests
---------

    git clone git@github.com:da99/Dex_Rack.git
    cd Dex_Rack
    bundle update
    bundle exec bacon spec/lib/main.rb


