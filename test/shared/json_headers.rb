module JsonHeaders
  def json_headers
    json_mime_type = 'application/json'
    {
       'ACCEPT' => json_mime_type,
       'HTTP_ACCEPT' => json_mime_type,
       'CONTENT_TYPE' => json_mime_type
    }
  end
end
