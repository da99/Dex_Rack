
describe "get /" do
  
  behaves_like 'Test DB'

  it "renders a recent list of 10" do
      5.times { |i| Dex.insert except("Err: #{i}") }
      
      get "/"
      5.times { |i|
        last_response.body.should.match %r!Err: #{i}!
      }
  end

  it "renders message when there are no exceptions" do
    get "/"
    last_response.body.should.match %r!No exceptions!
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
  
  it "displays record" do
      id = Dex.insert(except "rand err")
      get "/#{id}"
      should_render "rand err"
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
      should_redirect_to "/#{id}", 302
  end
  
end # === put /:id/status

describe "delete /:id" do
  
  behaves_like 'Test DB'
  
  it "deletes record" do
      Dex.insert(except("Deleted"))
      r = Dex.recent(1)
      delete "/#{r[:id]}"
      Dex.count.should == 0
  end

  it "redirects to / 303" do
      Dex.insert(except("Deleted"))
      r = Dex.recent(1)
      delete "/#{r[:id]}"
      should_redirect_to "/"
  end

end # === delete /:id

