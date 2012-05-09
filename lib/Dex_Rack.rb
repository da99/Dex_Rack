require 'Dex_Rack/version'
require 'Dex'
require 'markaby'
require 'chronic_duration'
require 'cgi'
require 'escape_utils'

class Dex_Rack 
  
  RACK_DIR   = File.join( File.dirname( __FILE__ ) , "/Dex_Rack" )
  
  set :dex, ( Dex.db("/tmp/dex.rack.sample.db") && Dex )

  use Rack::Lint
  
  set :public_folder, RACK_DIR + "/public"
  set :views_folder,  RACK_DIR + "/views"
  
  # use Rack::Static, \
    # :urls=>%w{ /stylesheets/ /javascripts/ /images/ /index.html }, \
    # :root=> RACK_DIR 

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    use Rack::CommonLogger
  end

  get "/" do
    recent
  end

  get "/recent/:page" do | page |
    recent page
  end

  get '/:id' do | id |
    r = find_id( id )
    pass unless r

    if r
      vars= Hash[
        :title=>"#{r[:exception]}: #{r[:message]}",
        :record=>r,
        :table_keys=>(r.keys - [:exception, :message, :backtrace, :status]),
        :app=>self
      ]

      s = self
      status = status_to_word(r[:status])
      vars[:status_class] = status.downcase
      vars[:status_word]  = status
      r[:human_time]   = human_time(r[:created_at])
      r[:backtrace]    = backtrace_to_html(r[:backtrace])
      vars[:table_keys] << :human_time
      layout vars, :record 
    else
      status 404
      layout Hash[:id=>id, :title=>"Not Found: Record ##{id}"], :record_404
    end
      
  end

  get "/:id/toggle" do |id|
    r = dex.filter(:id=>id).first
    s = r[:status] == 0 ? 1 : 0
    dex.filter(:id=>id).update(:status=>s)
    redirect to("/#{r[:id]}"), 302
  end

  delete "/:id" do | id |
    dex.filter(:id=>id).delete
    redirect to('/'), 303
  end

  get "/create-sample" do
    begin
      raise ArgumentError, request.path_info
    rescue ArgumentError => e
      dex.insert e
    end
    redirect to("/"), 302
  end

  module Base # ============================================
    
    %w{ dex dex? }.each { |m|
      eval %~
      def #{m} *args
        settings.#{m}(*args)
      end
      ~
    }

    def count
      @count ||= dex.count
    end

    def find_id id
      r = dex.filter(:id=>id).first
    end
    
    def list_recent limit, offset
      dex.limit(limit, offset).to_a.reverse
    end

    def recent page = :last, limit = 10
      nav  = page_nav( count, limit, page)

      return redirect(to('/'), 302) if !nav

      nav[:prev_url] = "/recent/#{nav[:prev]}" if nav[:prev]
      nav[:next_url] = "/recent/#{nav[:next]}" if nav[:next]
      nav[:next_url] = "/" if nav[:next] == nav[:total]

      vars = nav.merge(
        Hash[
          :title => "Dex List",
          :list  => list_recent(nav[:limit], nav[:offset]),
          :app => self
        ])

        layout(vars, :index) 
    end

    def layout vars, file_name
      Markaby::Builder.set(:indent, 2)
      mab = Markaby::Builder.new
      file = File.join(settings.views_folder, "/layout.rb")
      vars[:view_file] = File.join(settings.views_folder, "#{file_name}.rb" )
      vars[:app] = self
      mab.instance_eval {
        eval File.read(file), nil, file, 1
      }
      mab.to_s
    end

    def status_to_word num
      case num
      when 0
        "Unresolved"
      when 1
        "Resolved"
      end
    end

    def escape_html str
      EscapeUtils.escape_html( str.encode('UTF-8') )
    end

    def backtrace_to_html s
      last_file = nil
      str = ""
      s.split("\n").each { |l|
        
        file, num, code = l.split(':')
        
        str.<< %!
          <div class="file">#{escape_html file}</div>
        ! if file != last_file

        str.<< %!  
          <div class="line">
            <span class="num">#{num}</span> 
            <span class="code">#{escape_html code}</span>
          </div>!
          
        last_file = file
        
      }

      str
    end

    def human_time t
      target = Time.now.utc.to_i - t.to_i
      if target < 61
        return "<1m ago"
      else
        ChronicDuration.output(target, :format=>:short).sub(/\d+s\Z/, '') + " ago"
      end
    end

    def page_nav count, div, page = :last
      count = count.to_i

      div   = div.to_i
      total = ( count / Float(div) ).ceil
      page  = total if page == :last
      page  = page.to_i

      if count > 0 
        if total < 1 || page < 1 || page > total || div < 2
          return nil 
        end
      end

      n = page + 1
      n = nil if n > total
      p = page - 1
      p = nil if p < 1
      offset = div * (page - 1)
      offset = 0 if offset < 1

      Hash[ 

        :total => total, 
        :next => n, 
        :prev => p, 
        :page => page,

        :count => count,
        :limit => div,
        :offset => offset

      ]
    end
    
  end # === Base =======================================================

  include Base
  
end # === class Dex_Rack
