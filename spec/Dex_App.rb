
describe "Dex_Rack" do
  
  it "has methods that can be overridden" do
    m = Module.new {
    def list_recent *args
      'ok'
    end

    }
    
    d = Class.new(Dex_Rack) {
      
    include m
    
    def initialize
    end

    get "/new-recent" do
      list_recent
    end

    }

    def self.app
      @app
    end

    @app = d
    get "/new-recent"

    last_response.body.should == 'ok'

  end
  
end # === Dex_Rack


describe "get /" do
  
  behaves_like 'Test DB'

  it "renders message when there are no exceptions" do
    get "/"
    renders %r!No unresolved exceptions!
  end

  it "renders a recent list of 10" do
    5.times { |i| Dex.insert except("Err: #{i}") }

    get "/"
    5.times { |i|
      last_response.body.should.match %r!Err: #{i}!
    }
  end

  it "renders a link to the last page of results" do
    15.times { |i| Dex.insert except("Err: #{i}") }
    get "/"
    renders %r!/recent/2">!
    renders %r!Full list\ *</a>!
  end

end # === get /

describe "get /recent/:num" do
  
  behaves_like 'Test DB'

  it "/recent/:num renders a list" do
      n = rand(10) + 1
      n.times { |i| Dex.insert except("N: #{i}") }

      get "/recent/#{1}"
      n.times { |i|
        last_response.body.should.match %r!N: #{i}!
      }
  end

end # === get /recent/num

describe "get /:id" do
  
  behaves_like 'Test DB'
  
  it "renders record" do
    id = Dex.insert(except "rand err")
    get "/#{id}"
    renders 200, %r"rand err"
  end

  it "renders non-standard backtrace: <<< Rack App" do
    id = Dex.insert(except("rand"), :backtrace=>"<<< Rack App")
    get "/#{id}"
    renders 200, %r"&lt;&lt;&lt; Rack App"
  end

  it "renders non-standard backtrace: file:13:code:1:2:3:" do
    id = Dex.insert(except("rand"), :backtrace=>"file:13:code:1:2:3:")
    get "/#{id}"
    renders 200, %r">code:1:2:3"
  end

  it "does not render any fields that are nil" do
    target = "invisibily"
    id = Dex.insert(except("rand"), target=>nil)
    get "/#{id}"
    last_response.body.should.not.match %r!#{target}!
  end

end # === get /:id

describe "get /:id/toggle" do
  
  behaves_like 'Test DB'
  
  it "updates status of record" do
    id = Dex.insert(except "rand err")
    get "/#{id}/toggle"
    Dex.filter(:id=>id).first[:status]
    .should == 1
  end

  it "redirects to /:id 302" do
    id = Dex.insert(except "rand err")
    get "/#{id}/toggle"
    redirects_to 302, "/#{id}"
  end

  it "redirects to PAGE_LIST 302 if set in session" do
    id = Dex.insert( except "rand err")
    get "/#{id}", {}, {'HTTP_REFERER'=>"/page/list"}
    get "/#{id}/toggle"
    redirects_to 302, "/page/list"
  end
  
end # === put /:id/status

describe "get /:id/delete" do
  
  behaves_like 'Test DB'
  
  it "deletes record" do
      Dex.insert(except("Deleted"))
      r = Dex.recent(1)
      get "/#{r[:id]}/delete"
      Dex.count.should == 0
  end

  it "redirects to / 303" do
      Dex.insert(except("Deleted"))
      r = Dex.recent(1)
      get "/#{r[:id]}/delete"
      redirects_to "/"
  end

end # === delete /:id

