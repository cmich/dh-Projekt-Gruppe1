require 'nokogiri'	

	# Öffnen der Textdatei und schreiben in eine String Variable
	text = ""
	File.open("/home/me/Projekt-Sporleder/HuckFinn/HuckFinn_Gutenberg.txt", "r") do |f|
	  f.each_line do |line|
	 	text << line
	  end
	end

	# Sicherstellen, dass der Strinbg utf-8 kodieert ist
	begin
  		text.encode("UTF-8")
	rescue Encoding::UndefinedConversionError
  	# ...
	end
	
	# Bereinigen des Textes und hinzufügen des xml markups (hier noch String)
	text = "<document title='HUCKLEBERRY FINN' author='Mark Twain'>\n<chapter>\n<paragraph>\n" + text + "\n</paragraph>\n</chapter>\n</document>"
	altered_text = text.gsub!(/\s{4,}CHAPTER \w{1,}.\s{1,}/,"\n</paragraph>\n</chapter>\n<chapter>\n<paragraph>\n")
	altered_text.gsub!("\r\n\r\n","\n</paragraph>\n<paragraph>\n")
	
	# Vergabe der id's an die chapter
	# Bei diesem Schritt wird der String in ein xml doc konvertiert und auf Wohlgeformtheit geprüft 
	counter = 1
	doc = Nokogiri::XML(altered_text)
	doc.encoding = 'UTF-8'
	doc.search('//document//chapter').each do |chapter|
                chapter["id"] = counter
		counter = counter + 1
        end
	
	doc.search('//document//chapter//paragraph').each do |para|
                zwischen = para.content
		zwischen.gsub!("\n", " ")
		para.content = zwischen
		# die nächsten beiden Zeilen löschen die paragraph tags aus dem xml markup		
		zwischen2 = para.content
		para.replace(zwischen2)
        end
	
	# Speichern als xml-Datei 	
	File.open('HuckFinn.xml','w') {|f| doc.write_xml_to f}	
	
	# Speichern als txt-Datei 
	#File.open("HuckFinn.txt", 'w') do |file|
	#   file.puts(text)
	#end
	
	#Zusätzlich speichern aller chapter als einzelne txt-Dateien
	chapternumber = 1
	doc.search('//document//chapter').each do |chapter|
                File.open("chapter"+chapternumber.to_s+".txt" , 'w') do |file|
                       file.puts(chapter.content)
                end
                chapternumber = chapternumber + 1
        end

