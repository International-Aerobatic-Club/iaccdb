module ACRO
  module AcroWebOutputReader
    def read_file(file)
      filtered = ''
      File.open(file,'r') do |f|
        # the ACRO outputs have missing font and paragraph end tags
        # the non-breaking spaces don't encode as white space to strip
        f.each_line do |l| 
          fl = l.gsub(/<font[^>]+>|<\/font[\s>]|&nbsp;|[[:cntrl:]]|<p\s[^>]+>|<\/p\s+>/,' ') 
          filtered << "#{fl}\n"
        end
      end
      filtered
    end
  end
end
