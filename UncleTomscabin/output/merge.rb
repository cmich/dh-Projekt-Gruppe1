require 'nokogiri'

#test for arguments
if ARGV.size == 0 || ARGV[0] == "-h" || ARGV.size > 2 || ARGV.size == 1 
	puts "-h	-->	displays this help"
	puts "-d	-->	operates on all files in given directory"
end

if ARGV.size == 2 && ARGV[0] == "-d"
	
	#search the given directory for xml files 
        directory = ARGV[1] +'*.xml'
	
	#check if any files found	
	count = Dir.glob(directory).count
	puts "Unter dem Pfad "+ directory +" wurden " + count.to_s + " xml-Dateien gefunden"
	
	if count > 0 
		puts "Starte Bearbeitung..."
	end

	if count == 0
		puts "Keine xml-Dateien gefunden"
	end
	
	#load the found xml files into array and sort them by filename
	#it's important that the xml files are named correct e.g. "chapter01.xml" and not "chapter1.xml" 
	#without that the sort() function doesn't work correct
	$files =  Dir.glob(directory).sort
	
	#creating some variables for further use.
	dump = []
	count = 0
	count2= 1

	#open each xml chapter file and save the sentences node of the files to a array (dump)
	$files.each do |xml_file|
		doc = Nokogiri::XML(File.open(xml_file))
		doc.encoding = 'UTF-8'
        	doc.search('//document//sentences').each do |sentences|
			dump<<sentences
			puts xml_file + ' ' + count2.to_s + ' eingelesen'
			count2 += 1
		end
	end

	#get the xml file in which the chapters should be inserted
	#the file has to be located in the parent folder of the given chapters folder
	#also it has to be the only xml file there 

	ausgabe = directory.gsub!("/annotated_chapters","")
	$file2 = Dir.glob(ausgabe).sort
	doc2 = Nokogiri::XML(File.open($file2[0]))
	doc2.encoding = 'UTF-8'

	#combine the chapters in the output xml using the found "parent" xml
	doc2.search('//document//chapter').each do |chapter|
        	if count < dump.length
			chapter.content = ""
			dump[count].parent = chapter
			count += 1
                	puts "chapter "+count.to_s+" eingefügt"
                	
		end
        end
	
	#save finished xml 
	File.open('Ausgabe.xml', 'w') { |f| f.print(doc2.to_xml) }        
end