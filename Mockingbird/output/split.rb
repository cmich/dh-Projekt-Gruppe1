require 'nokogiri'


#test for arguments
if ARGV.size == 0 || ARGV[0] == "-h" || ARGV.size > 2 || ARGV.size == 1 
	puts "-h	-->	displays this help"
	puts "-f	-->	to split file"
end


if ARGV.size == 2 && ARGV[0] == "-f"
	file = ARGV[1] 
	counter = 1

	doc = Nokogiri::XML(File.open(file))
	doc.encoding = 'UTF-8'
	doc.xpath("//document//chapter").each do |chapter|

		File.open("chapter" + counter.to_s + ".txt", "w+") do |file|
			file.write(chapter.content)
		end
		counter = counter + 1
	end
	File.open(file + '_clear.xml','w') {|f| doc.write_xml_to f}	
end

