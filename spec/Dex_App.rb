
describe "get /" do
  
  it "renders a recent list of 10" do
    transact {
      5.times { |i| Dex.insert except("Err: #{i}") }
      
      get "/"
      5.times { |i|
        last_response.body.should.match %r!Err: #{i}!
      }
    }
  end

  it "renders message when there are no exceptions" do
    get "/"
    last_response.body.should.match %r!No exceptions!
  end

end # === get /

describe "get /recent/:num" do

  it "/n renders a list equal to n" do
    transact {
      n = rand(10) + 1
      n.times { |i| Dex.insert except("N: #{i}") }

      get "/recent/#{n}"
      n.times { |i|
        last_response.body.should.match %r!N: #{i}!
      }
    }
  end

end # === get /recent/num

describe "get /:id" do
  
  it "displays record" do
    transact {
      id = Dex.insert(except "rand err")
      get "/#{id}"
      should_render "rand err"
    }
  end

end # === get /:id

describe "put /:id/status" do
  
  it "updates status of record" do
    transact {
      id = Dex.insert(except "rand err")
      put "/#{id}/status", :status=>2
      Dex.filter(:id=>id).first[:status]
      .should == 2
    }
  end

  it "redirects to /:id 303" do
    transact {
      id = Dex.insert(except "rand err")
      put "/#{id}/status", :status=>2
      should_redirect_to "/"
    }
  end
  
end # === put /:id/status

describe "delete /:id" do
  
  it "deletes record" do
    transact {
      Dex.insert(except("Deleted"))
      r = Dex.recent(1)
      delete "/#{r[:id]}"
      Dex.count.should == 0
    }
  end

  it "redirects to / 303" do
    transact {
      Dex.insert(except("Deleted"))
      r = Dex.recent(1)
      delete "/#{r[:id]}"
      should_redirect_to "/"
    }
  end

end # === delete /:id

