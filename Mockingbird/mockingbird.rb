#two ruby gems that save a lot of work 
require 'yomu'
require 'nokogiri'

#open the pdf and converting the input to a string
$file = "/home/me/Projekt-Sporleder/mockingbird/To_Kill_ a_ Mockingbird.pdf"
yomu = Yomu.new $file
text = yomu.text
altered_text = ""

#clearing obvious text junk 
altered_text = text.gsub!(/“To Kill a Mockingbird” By Nelle Harper Lee \d{1,3}/,"")
altered_text = altered_text.gsub!(/\n{6}/,"")
altered_text = altered_text.gsub!(" Part One  ","")
altered_text = altered_text.gsub!("Part Two ","")	

#including first xml tags (<document>,<chapter>,<paragraph>)
#still just as string
altered_text = altered_text.sub!(/\n{3}Chapter \d \n{2}/,"<chapter>\n")
altered_text = altered_text.gsub!(/\n\s{0,1}Chapter \d{1,3}\s{0,1}\n/,"\n</chapter>\n<chapter>\n")
altered_text = altered_text.gsub!(/\n\s{0,2}\n/,"")
altered_text = altered_text.gsub!(/<chapter>   /,"<chapter>\n   ")
altered_text = altered_text.gsub!("<chapter>\n   ","<chapter>\n<paragraph>\n")
altered_text = altered_text.gsub!("</chapter>\n","</paragraph>\n</chapter>\n")
altered_text = altered_text.gsub!("   ","</paragraph>\n<paragraph>\n")
altered_text = "<document>\n" + altered_text + "</paragraph>\n</chapter>\n</document>"

#converting the string to a xml object 
doc = Nokogiri::XML(altered_text)
counter = 1

#setting attributes (title,author)for the document node
doc.search('//document').each do |dok|
	dok["title"] = "To Kill a Mockingbird"
	dok["author"] = "Harper Lee"
end

#including attributes like "id"
doc.search('//document//chapter').each do |chapter|
	chapter["id"] = counter
	counter = counter + 1
end

#deleting the newline characters from each paragraph node
doc.search('//document//chapter//paragraph').each do |para|
	zwischen = para.content
	zwischen.gsub!("\n", "")
	para.content = zwischen
	# the next two lines delete the paragraph tags		
	zwischen2 = para.content
	para.replace(zwischen2)
end


#save to xml file
File.open('to_kill_a_mockingbird.xml','w') {|f| doc.write_xml_to f}	


#additionaly save a txt file for each chapter 
counter2 = 1
doc.search('//document//chapter').each do |chapter|
	File.open("mockingbird_chapter "+counter2.to_s+".txt", 'w') do |file|
   		file.puts(chapter.content)
		counter2 = counter2 +1
	end
end

#saves altered_text to txt file 
#was used to check the output while working on the file
#File.open($file[0..-5]+".txt", 'w') do |file|
#   file.puts(altered_text)
#end