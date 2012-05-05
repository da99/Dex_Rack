


div.header! {
  h1 {
    span.exception "#{vars[:record][:exception]}:"
    span.message   vars[:record][:message]
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
  div {
    span.status.send vars[:status_class].downcase, vars[:status_word]
    a.button(:href=>"/#{vars[:record][:id]}/toggle") { "Toggle" }
  }

  unless vars[:table_keys].empty?
    table {
      vars[:table_keys].each { |k|
        tr {
          td.key k.inspect 
          td.val vars[:record][k]
        }
      }
    }
  end

  div.sixteen.columns.toggle_backtrace! {
    div.eight.columns.alpha {
      a.button.show_backtrace!(:href=>"#show") { "Show Backtrace" }
    }
    div.eight.columns.omega {
      a.button.hide_backtrace!(:href=>"#hide") { "Hide Backtrace" }
    }
  }

  div.backtrace! {
    vars[:record][:backtrace] 
  }


}
