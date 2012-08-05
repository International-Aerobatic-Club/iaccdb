require "net/http"

module MannyConnect

MANNY_HOST = 'donkeykong.highroaddata.com'
MANNY_PORT = 1001

def pull_contest(manny_number, line_proc)
  query = "<ContestDetail><ContestID>#{manny_number}</ContestID></ContestDetail>"
  Net::HTTP.start(MANNY_HOST, MANNY_PORT) do |http|
    resp = http.post('/', query, {'Content-Type' => 'text/xml'})
    if resp.kind_of?(Net::HTTPSuccess)
      resp.body.each_line { |line| line_proc.call(line) }
    end
  end
end

def pull_contest_list(record_proc)
  tail = ''
  Net::HTTP.start(MANNY_HOST, MANNY_PORT) do |http|
    resp = http.post('/', '<ContestList/>', {'Content-Type' => 'text/xml'})
    if resp.kind_of?(Net::HTTPSuccess)
      resp.body.each_line { |line| record_proc.call(line) }
    end
  end
end

end
