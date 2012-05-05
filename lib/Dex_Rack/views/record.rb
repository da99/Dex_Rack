      div.sixteen.columns {
        h2 "#{vars[:record][:message]}" 

      }
      div {
        span.status.send vars[:status_class].downcase, vars[:status_word]
        a.button(:href=>"/#{vars[:record][:id]}/toggle") { "Toggle" }
      }

      unless vars[:table_keys].empty?
        div.sixteen.columns.more_info! {
          vars[:table_keys].each { |k|
            div.two.columns.alpha { k.inspect }
            div.fourteen.columns.omega { vars[:record][k] }
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
        vars[:record][:backtrace] 
      }


