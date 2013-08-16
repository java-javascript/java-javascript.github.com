require 'rubygems'
require 'erb'
require 'open-uri'

site_template_list ="site_template.erb"
rss_template ="rss_template.erb"
jquery = '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>' + "\n"
jquery_github = '<script src="js/jquery.github.min.js"></script><script>$("[data-repo]").github();</script>' + "\n"
@title=nil
@items=[]
@is_list=true
# the content directory drives the content for the site
Dir.new('content').entries.grep(/.*.txt/).each do |note|
  
   tags = note.split('_')
   dt = tags.shift
   dt= "#{dt[0,4]}-#{dt[4,2]}-#{dt[6,2]}"
   content = File.open("content/#{note}").readlines.join("\n")
   tags.map{|m|m.gsub!('.txt','')}
   first_sentence = content.split('.  ')[0]
   description = first_sentence.split('</h4>').last.gsub('<p>','').strip
   first_sentence += " <a href='#{dt}.html'>[...]</a>"
   title = first_sentence.split('</h4>').first.gsub('<h4>','')

   
   @items << {:tags => tags, 
              :date => "#{dt}", 
              :content => content, 
              :first_sentence => first_sentence,
              :title =>  title,
              :description => description
              }
end

htmls = Dir.entries('..').grep(/.*.html/)
idx = htmls.delete('index.html')
htmls.delete('sieve-of-eratosthenes.html')

# index
File.open("../#{idx}",'w'){|f|f.puts ERB.new(File.read(site_template_list)).result} 
# rss
File.open("../rss.xml",'w'){|f|f.puts ERB.new(File.read(rss_template)).result} 

# tags page
@all_items = @items
htmls.each{|html|
   @title=html.gsub('.html','')
   puts "Processing #{@title}"
   @items=@all_items.find_all{|i|i[:tags].include?(@title)}
   puts "Total #{@items.size}"   
   File.open("../#{html}",'w'){|f|f.puts ERB.new(File.read(site_template_list)).result} unless @items.nil?      
}

# details
@is_list=false
@all_items.each{|item|
  puts "Detail #{item[:date]}"
   @item=item
   File.open("../#{item[:date]}.html",'w'){|f|f.puts ERB.new(File.read(site_template_list)).result}
}

about = htmls.delete('about.html')
about_content = <<-HERE
<p><a href="http://www.oreillynet.com/pub/au/5724">I</a> am still deciding what this is about...</p>
HERE

projects =<<-HERE
<h4>Selected Github Repos</h4>
<div class="projects">
  <div data-repo="java-javascript/client-server-web-apps"></div>
  <div data-repo="ezgraphs/maven-jruby-gems-sinatra"></div>
  <div data-repo="ezgraphs/underscore-mixins"></div>
</div>
HERE


@item = {:tags=>'', 
            :date=>"", 
            :content=> about_content, 
            :first_sentence => '' 
          }

File.open("../about.html",'w'){|f|
  f.puts ERB.new(File.read(site_template_list).gsub('</body>',jquery + jquery_github + '</body>').gsub('<!-- REPO -->', projects)).result
}
 
