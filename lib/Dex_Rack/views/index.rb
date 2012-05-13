div.header! {
  h1 {
    span.exception vars[:title]
    span.message   vars[:message]
  }
}

    if vars[:app].request.path_info != '/'
      div.nav! {
        a(:href=>'/') { "Home"}
        span.towards ">>"
        span.location vars[:title]
      }
    end

    div.content! {
      
if vars[:app].request.path_info == '/'
  table {
    tr { 
      td.key "Database:"
      td.val  vars[:app].dex.db_name.to_s
    }
    tr {
      td.key "Table:"
      td.val vars[:app].dex.table_name.to_s
    }
  }
end 

div.recent_nav! {

  if vars[:app].request.path_info == '/'
    a(:href=>vars[:last_url]) { "<< Full list" }
  else
    if vars[:prev_url]
      a(:href=>vars[:prev_url]) { "<< Back in Time" }
    end

    if vars[:next_url]
      a(:href=>vars[:next_url]) { "Forward In Time >>" }
    end
  end

}

if vars[:list].empty?
  div.empty { 
    p "No exceptions created." 
    a.button( :href=>"/create-sample" ) {
      "Create Sample Exception"
    }
  }

else
  
  vars[:list].each { |db|
    div.record_in_list {
      p {
        a.button(:href=>"/#{db[:id]}") {
          "View"
        }
        span.time( vars[:app].human_time(db[:created_at]) )
        span.status.send(vars[:app].status_to_word(db[:status]).downcase, vars[:app].status_to_word(db[:status]))
        span.exception "#{db[:exception]}:"
        span.message db[:message]
      }
    }
  }
  
end
    }
