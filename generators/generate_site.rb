require 'rubygems'
require 'erb'
site_template_list ="site_template.erb"
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
   first_sentence += " <a href='#{dt}.html'>[...]</a>"
   @items << {:tags=>tags, 
              :date=>"#{dt}", 
              :content=>content, 
              :first_sentence => first_sentence
              }
   
end

htmls = Dir.entries('..').grep(/.*.html/)
idx = htmls.delete('index.html')

# index
File.open("../#{idx}",'w'){|f|f.puts ERB.new(File.read(site_template_list)).result} 

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
@item = {:tags=>'', 
            :date=>"", 
            :content=> '<p>Still deciding what this is about...</p>', 
            :first_sentence => '' 
            }
File.open("../about.html",'w'){|f|f.puts ERB.new(File.read(site_template_list)).result}
 
