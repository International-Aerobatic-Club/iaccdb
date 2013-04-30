import java.util.*;
import java.util.regex.*;
import java.io.*;
import java.net.*;

class ClientPost {

private static String JASPER_DATA_PARAM = "contest_xml";

private URL postURL;
private StringWriter dataWriter = null; // valid after startDataStream()
private boolean wasSuccessful = false;
private int cdbId = -1;

/**
Create an instance that posts to the given URL
*/
public ClientPost(URL postURL)
{
  this.postURL = postURL;
}

/**
When you call this, you start a fresh data stream for posting.
Write the data stream first, then call postToCDB().
@return Writer into the data stream
*/
public Writer startDataStream()
{
  dataWriter = new StringWriter();
  return dataWriter;
}

/**
When you call this, you post the data, after which it is gone.
The post is synchronous.  The function returns after posting and
receiving a reply.
Get a new data stream with startDataStream() to make a new post.
(You could hold on to the writer, but using it will have no effect
after calling this method.)
@return true if the post got a 200 response, else false.
*/
public boolean postToCDB()
throws IOException, ProtocolException, UnsupportedEncodingException
{
  cdbId = -1;
  if (dataWriter == null) {
    throw new IllegalStateException(
        "call startDataStream() and write something first");
  }
  HttpURLConnection connection = (HttpURLConnection)postURL.openConnection();
  connection.setRequestMethod("POST");
  
  connection.setRequestProperty("Content-Type", 
       "application/x-www-form-urlencoded");
  dataWriter.flush();
  String data = JASPER_DATA_PARAM + "=" + 
     URLEncoder.encode(dataWriter.toString(), "UTF-8");
  dataWriter = null;

  connection.setRequestProperty("Content-Length", "" + 
           Integer.toString(data.getBytes().length));
  connection.setUseCaches(false);
  connection.setDoInput(true);
  connection.setDoOutput(true);

  DataOutputStream out = new DataOutputStream(connection.getOutputStream());
  out.writeBytes(data);
  out.flush ();
  out.close ();

  wasSuccessful = connection.getResponseCode() == 200;
  if (wasSuccessful) {
    processResponse(connection.getInputStream());
  }
  connection.disconnect();

  return wasSuccessful;
}

/**
If you missed the return from postToCDB(), or simply find it more convenient,
call to get the last return from postToCDB();
*/
public boolean wasSuccessful()
{
  return wasSuccessful;
}

/**
Call to get the cdb contest identifier.
@return -1 if there was no successful post to CDB
*/
public int getCdbId()
{
  return cdbId;
}

private void processResponse(InputStream response)
throws IOException
{
  Pattern p = Pattern.compile("<cdbId>\\s*(\\d+)");
  BufferedReader in = new BufferedReader(new InputStreamReader(response));
  String line = in.readLine();
  while (cdbId == -1 && line != null) {
    System.out.println(line);
    Matcher m = p.matcher(line);
    if (m.find()) {
      String idText = m.group(1);
      if (idText != null) {
        cdbId = Integer.parseInt(idText);
      }
    }
    line = in.readLine();
  }
}

}
