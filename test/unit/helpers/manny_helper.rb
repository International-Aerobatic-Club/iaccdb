require 'iac/mannyParse'
module MannyParsedTestData
  @@Parsed30 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_30.txt") { |line| @@Parsed30.processLine(line) }
  @@Parsed31 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_31.txt") { |line| @@Parsed31.processLine(line) }
  @@Parsed32 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_32.txt") { |line| @@Parsed32.processLine(line) }
  MP30 = @@Parsed30
  MP31 = @@Parsed31
  MP32 = @@Parsed32
end
