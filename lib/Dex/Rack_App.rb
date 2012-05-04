
require 'sinatra/base'
require 'Dex'
require 'markaby'
require 'chronic_duration'

class Dex

  class Rack_App < Sinatra::Base

    use Rack::Lint
    use Rack::Static, \
      :urls=>%w{ /stylesheets/ /javascripts/ /images/ /index.html }, \
      :root=>(Dex.rack_dir + '/public')

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      use Rack::CommonLogger
    end

    get "/" do
      recent
    end
    
    get "/recent/:num" do | num |
      recent Integer(num)
    end

    get %r!\A/(\d+)\Z! do | id |
      r = Dex.filter(:id=>id).first
      
      view_record Hash[
        :title=>r[:exception],
        :record=>r,
        :table_keys=>(r.keys - [:exception, :message, :backtrace, :status]),
        :app=>self
      ]
    end

    get "/:id/toggle" do |id|
      r = Dex.filter(:id=>id).first
      s = r[:status] == 0 ? 1 : 0
      Dex.filter(:id=>id).update(:status=>s)
      redirect to("/#{r[:id]}"), 303
    end

    delete "/:id" do | id |
      Dex.filter(:id=>id).delete
      redirect to('/'), 303
    end

    get "/create-sample" do
      begin
        raise ArgumentError, request.path_info
      rescue ArgumentError => e
        Dex.insert e
      end
      redirect to("/"), 302
    end

    def recent num = 10
      vars = Hash[
        :title => "Dex List",
        :list  => Dex.recent.to_a,
        :app   => self
      ]
      view_index vars
    end

    def layout vars, &b
      Markaby::Builder.set(:indent, 2)
      mab = Markaby::Builder.new
      mab.html do
        head {
          title vars[:title]
          %w{ base skeleton layout dex }.each { |name|
            link(:rel=>"stylesheet", :href=>"stylesheets/#{name}.css")
          }
          script(
            :type=>"text/javascript", 
            :src=>"http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"
          ) {}
          script(
            :type=>"text/javascript", 
            :src=>"/javascripts/dex.js"
          ) {}
        }
        body(:class=>['container',vars[:status_class]].compact.join(' ')) {
          
          if vars[:app].request.path_info != '/'
            div.nav! {
              a(:href=>'/') { "Home"}
              span.towards ">>"
            }
          end

          div.sixteen.columns.header! {
            h1 vars[:title]
          }
          
          instance_eval(&b)
          
        }
      end
      
      mab.to_s
    end
    
    def view_index vars
      app = vars[:app]
      layout(vars) {
        if vars[:list].empty?
          div.empty { 
            p "No exceptions created." 
            a.button( :href=>"/create-sample" ) {
              "Create Sample Exception"
            }
          }

        else
          vars[:list].each { |db|
            div {
              p {
                a.button(:href=>"/#{db[:id]}") {
                  "View"
                }
                span.time( app.human_time(db[:created_at]) )
                span.status.send(app.status_to_word(db[:status]).downcase, app.status_to_word(db[:status]))
                span.exception db[:exception]
                span.message db[:message]
              }
            }
          }
        end
      }
    end

    def view_record vars
      r = vars[:record]
      s = self
      status = status_to_word(r[:status])
      vars[:status_class] = status.downcase
      r[:human_time]   = human_time(r[:created_at])
      vars[:table_keys] << :human_time
      layout(vars) {
        div.sixteen.columns {
          h2 "#{r[:message]}" 

        }
        div {
          span.status.send status.downcase, status
          a.button(:href=>"/#{r[:id]}/toggle") { "Toggle" }
        }

        unless vars[:table_keys].empty?
          div.sixteen.columns.more_info! {
            vars[:table_keys].each { |k|
              div.two.columns.alpha { k.inspect }
              div.fourteen.columns.omega { r[k] }
            }
          }
        end
        
        div.sixteen.columns.toggle_backtrace! {
          div.eight.columns.alpha {
            a.show_backtrace!(:href=>"#show") { "Show Backtrace" }
          }
          div.eight.columns.omega {
            a.hide_backtrace!(:href=>"#hide") { "Hide Backtrace" }
          }
        }

        div.backtrace! {
          pre { code { "\n\n"+r[:backtrace] } }
        }
        
      }
    end

    def status_to_word num
      case num
      when 0
        "Unresolved"
      when 1
        "Resolved"
      end
    end

    def human_time t
      ChronicDuration.output(Time.now.utc.to_i - t.to_i, :format=>:short).sub(/\d+s\Z/, '') + " ago"
    end

  end # === Rack_App < Sinatra::Base
  
end # === Dex

