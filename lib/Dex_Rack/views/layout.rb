xhtml_strict do
  
  head {
    
    link( :href=>'http://fonts.googleapis.com/css?family=Bree+Serif|Oxygen', :rel=>'stylesheet', :type=>'text/css' ) 
    
    title vars[:title]
    %w{ reset dex }.each { |name|
      link(:rel=>"stylesheet", :href=>"/stylesheets/#{name}.css")
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
  
  body(:class=>[vars[:status_class]].compact.join(' ')) {
    
      eval File.read(vars[:view_file]), nil, vars[:view_file], 1
    
      
    div.footer! {
    if vars[:app].request.path_info == '/'
      %~
        <span>Background from: </span>
        <a href="http://www.backgroundlabs.com" title="Background Labs"><img src="http://www.backgroundlabs.com/images/backgroundlabs88x15.gif" border="0" alt="Background Labs"/></a>
      ~
    end
    }
  }
end

