module ACRO
  module AcroWebOutputReader
    def read_file(file)
      filtered = ''
      File.open(file,'r') do |f|
        # the ACRO outputs have missing font end tags
        # the non-breaking spaces don't encode as white space to strip
        f.each_line { |l| filtered << l.gsub(/<font[^>]+>|<\/font>|&nbsp;/,' ') }
      end
      filtered
    end
  end
end
