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
import org.apache.commons.cli.*;

class TestClientPost {

private static String POST_FILE_NAME = "../spec/jasper/jasperResultsFormat.xml";
private static String POST_URL = "http://localhost:3000/admin/jasper.xml";

public static Options buildOptions()
{
  Options options = new Options();
  options.addOption("i", "cdbID", true, 
    "Contest ID becomes cdbID for update existing contest at the server. Creates a new contest entry at the server if unspecified.");
  options.addOption("d", "data", true, 
    String.format("Contest XML data input file.  Default is \"%s\" if left unspecified.", POST_FILE_NAME));
  options.addOption("p", "postURL", true,
    String.format("URL at which to post.  Default is \"%s\" if left unspecified.", POST_URL));
  return options;
}

public static CommandLine processOptions(String argv[], Options options)
throws ParseException
{
  CommandLineParser optProc = new PosixParser();
  return optProc.parse(options, argv);
}

public static void main(String argv[]) 
{
  try {
    Options opts = buildOptions();
    HelpFormatter helper = new HelpFormatter();
    CommandLine clOpts = processOptions(argv, opts);
    int cid = Integer.parseInt(clOpts.getOptionValue('i', "-1"));
    File inputFile = new File(clOpts.getOptionValue('d', POST_FILE_NAME));
    URL postURL = new URL(clOpts.getOptionValue('p', POST_URL));
    helper.printHelp("TestClientPost", opts);
    System.out.printf("Posting file %s\n", inputFile.getCanonicalFile());
    System.out.printf("Posting to %s\n", postURL.toString());
    if (0 <= cid) {
      System.out.printf("Will attempt to overwrite contest with id, %d\n", cid);
    }
    processSubmission(postURL, inputFile, cid);
  }
  catch (NumberFormatException ex)
  {
    System.err.print("First argument must be a number.");
  }
  catch (MalformedURLException ex)
  {
    System.err.printf("%s is not a valid URL\n", POST_URL);
  }
  catch (IOException ex)
  {
    System.err.printf("%s is not a good file.", POST_FILE_NAME);
  }
  catch (SAXException ex)
  {
    System.err.printf("%s failed to parse.", POST_FILE_NAME);
  }
  catch (XPathExpressionException ex)
  {
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
  catch (ParseException ex)
  {
    System.err.println("Unable to parse command line options.");
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
  int postResult = post.postToCDB();
  if (postResult == 200)
  {
    System.out.printf("Success, CDB contest ID is %d\n", post.getCdbId());
  }
  else
  {
    System.out.printf("Fail. HTTP error code %d\n", postResult);
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
  XPathExpression xpe = xp.compile("//ContestInfo/cdbId");
  Element idNode = (Element)xpe.evaluate(dataDoc, XPathConstants.NODE);
  Text idValue = dataDoc.createTextNode(Integer.toString(cid));
  if (idNode == null)
  {
    xpe = xp.compile("//ContestInfo");
    Node ciNode = (Element)xpe.evaluate(dataDoc, XPathConstants.NODE);
    idNode = dataDoc.createElement("cdbId");
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
