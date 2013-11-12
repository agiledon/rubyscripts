require "rdiscount"

def to_html(md_content)
	RDiscount.new(md_content).to_html
end

def to_html_files
	Dir.glob('./**/*.markdown').each do |file|
		htmlContent = to_html(File.open(File.expand_path(file), "rb").read)
		htmlDir = "#{File.dirname(file)}/html"
		Dir.mkdir(htmlDir) if (!Dir.exists?(htmlDir)) 
		File.open("#{htmlDir}/#{File.basename(file, ".markdown")}.html", "w") do |file|
			file.write("<meta charset='utf-8'>\n#{htmlContent}")
		end
	end
end

to_html_files