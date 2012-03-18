require "net/http"

module MannyConnect

MANNY_HOST = 'donkeykong.highroaddata.com'
MANNY_PORT = 1001

def pull_contest(manny_number, &line_proc)
  query = "<ContestDetail><ContestID>#{manny_number}</ContestID></ContestDetail>"
  tail = ''
  Net::HTTP.start(MANNY_HOST, MANNY_PORT) do |http|
    http.post('/', query, {'Content-Type' => 'text/xml'}) do |data| 
      data = tail << data
      aRcd = data.split("\r")
      if !aRcd.empty?
        tail = aRcd.last
        aRcd.pop
        aRcd.each { |rcd| line_proc(rcd) }
      end
    end
  end
end

def pull_contest_list(record_proc)
  tail = ''
  Net::HTTP.start(MANNY_HOST, MANNY_PORT) do |http|
    http.post('/', '<ContestList/>', {'Content-Type' => 'text/xml'}) do |data| 
      data = tail << data
      aRcd = data.split("\r")
      if !aRcd.empty?
        tail = aRcd.last
        aRcd.pop
        aRcd.each { |rcd| record_proc.call(rcd) }
      end
    end
  end
  # tail should be empty because data ends with a record delimiter
end

end
