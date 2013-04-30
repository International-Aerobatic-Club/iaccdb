import java.io.*;
import java.net.*;
import javax.xml.*;
import javax.xml.parsers.*;
import javax.xml.xpath.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;

class TestClientPost {

private static String POST_FILE_NAME = "../spec/jasper/jasperResultsFormat.xml";
private static String POST_URL = "http://localhost:3000/admin/jasper.xml";

private static void usage() {
  System.err.printf("First argument is the contest id. " +
     "Unspecified creates a new contest entry at the server.\n");
}

private static int processCID(String argv[])
{
  return (0 < argv.length) ? Integer.parseInt(argv[0]) : -1;
}

public static void main(String argv[]) 
{
  try {
    URL postURL = new URL(POST_URL);
    File inputFile = new File(POST_FILE_NAME);
    int cid = processCID(argv);
    System.out.printf("Posting file %s\n", inputFile.getCanonicalFile());
    System.out.printf("Posting to %s\n", postURL.toString());
    if (0 <= cid) {
      System.out.printf("Will attempt to overwrite contest with id, %d\n", cid);
    }
    processSubmission(postURL, inputFile, cid);
  }
  catch (NumberFormatException ex)
  {
    usage();
    System.err.print("First argument must be a number.");
  }
  catch (MalformedURLException ex)
  {
    usage();
    System.err.printf("%s is not a valid URL\n", POST_URL);
  }
  catch (IOException ex)
  {
    usage();
    System.err.printf("%s is not a good file.", POST_FILE_NAME);
  }
  catch (SAXException ex)
  {
    usage();
    System.err.printf("%s failed to parse.", POST_FILE_NAME);
  }
  catch (XPathExpressionException ex)
  {
    usage();
    System.err.printf("%s failed to query.", POST_FILE_NAME);
  }
  catch (ParserConfigurationException ex)
  {
    System.err.println("unable to set up XML parser.");
  }
  catch (TransformerConfigurationException ex)
  {
    System.err.println("unable to set up XML output.");
  }
  catch (TransformerException ex)
  {
    System.err.println("unable to output XML");
  }
}

private static void processSubmission(URL postURL, File inputFile, int cid)
throws XPathExpressionException,
ParserConfigurationException,
SAXException,
IOException,
TransformerConfigurationException,
TransformerException
{
  Document dataDoc = getDOM(inputFile);
  XPathFactory xpf = XPathFactory.newInstance();
  XPath xp = xpf.newXPath();
  String contestName = xp.evaluate("//ContestInfo/Contest", dataDoc);
  System.out.printf("Process %s.\n", contestName);
  if (0 <= cid) {
    insertContestID(xp, dataDoc, cid);
  }
  ClientPost post = new ClientPost(postURL);
  printDocument(dataDoc, post.startDataStream());
  if (post.postToCDB())
  {
    System.out.printf("Success, CDB contest ID is %d\n", post.getCdbId());
  }
  else
  {
    System.out.println("Fail.");
  }
}

private static void printDocument(Document dataDoc, Writer out)
throws TransformerConfigurationException,
TransformerException
{
  TransformerFactory tFactory = TransformerFactory.newInstance();
  Transformer transformer = tFactory.newTransformer();
  DOMSource source = new DOMSource(dataDoc);
  StreamResult result = new StreamResult(out);
  transformer.transform(source, result); 
}


private static void insertContestID(XPath xp, Document dataDoc, int cid)
throws XPathExpressionException
{
  XPathExpression xpe = xp.compile("//ContestInfo/Id");
  Element idNode = (Element)xpe.evaluate(dataDoc, XPathConstants.NODE);
  Text idValue = dataDoc.createTextNode(Integer.toString(cid));
  if (idNode == null)
  {
    xpe = xp.compile("//ContestInfo");
    Node ciNode = (Element)xpe.evaluate(dataDoc, XPathConstants.NODE);
    idNode = dataDoc.createElement("Id");
    idNode.appendChild(idValue);
    ciNode.insertBefore(idNode, ciNode.getFirstChild());
  }
  else
  {
    idNode.replaceChild(idValue, idNode.getFirstChild());
  }
}

private static Document getDOM(File inputFile)
throws ParserConfigurationException,
SAXException,
IOException
{
  DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
  dbf.setCoalescing(true);
  dbf.setExpandEntityReferences(true);
  dbf.setIgnoringComments(true);
  dbf.setIgnoringElementContentWhitespace(true);
  dbf.setValidating(false);
  DocumentBuilder builder = dbf.newDocumentBuilder();
  return builder.parse(inputFile);
}
}
