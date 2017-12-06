/**
 * This file is part of SUNFISH FRM.
 *
 * SUNFISH FRM Interface is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SUNFISH FRM is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

//Author: Stefano De Angelis

package sunfish.frm.proxy;
 
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.json.JSONObject;
import org.json.simple.parser.JSONParser;
import org.xml.sax.InputSource;
import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
 
public class ProxyFilter implements Filter {
	
	private ServletContext context;
	private final String catalina_home = "/usr/local/tomcat/conf/";
	private int req_count, res_count;
	
	public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
			throws IOException, ServletException {

		HttpServletRequest httpRequest = (HttpServletRequest) servletRequest;
		HttpServletResponse response = (HttpServletResponse) servletResponse;
		
		/* wrap the request in order to read the inputstream multiple times */
		CachedServletRequest multiReadRequest = new CachedServletRequest(httpRequest);
		
		/* *
		 * Retrieve Headers and content-type *
		 * *
		 * * */
		boolean content_type = false;
		
		//this.context.log(" \n\nRetrieving Headers");
		Enumeration<String> headerNames = httpRequest.getHeaderNames();
		while(headerNames.hasMoreElements()) {
		  String headerName = headerNames.nextElement();
		  if (headerName.equals("content-type"))
			  content_type = true;
		  //this.context.log("Header Name - " + headerName + ", Value - " + httpRequest.getHeader(headerName));
		}
		
		
		/* *
		 * Retrieve Parameters *
		 * *
		 * *
		this.context.log("\n\nRetrieving Parameters");
        Enumeration<String> params = httpRequest.getParameterNames();
        while(params.hasMoreElements()){
            String paramName = (String)params.nextElement();
            this.context.log(paramName + " = " + httpRequest.getParameter(paramName));
        }
        */
		
        /*										
         * 	Retrieve the body in a StringBuffer *
         */
        this.context.log("\n\nRetrieving request Body");	
		StringBuffer jb = new StringBuffer();
		String line = null;
		BufferedReader reader = new BufferedReader(new InputStreamReader(multiReadRequest.getInputStream()));
		
		// Populate the StringBuffer with the inputstream
		try {
            while ((line = reader.readLine()) != null) {
                jb.append(line);
            }
        } finally {
        	reader.close();
        } 
		//this.context.log("Retrieved request body:\n"+jb.toString());
		
		
		/* *
		 * 
		 *		Request filter. Send to monitoring just Request xmls
		 * 
		 * */
		if(content_type && httpRequest.getHeader("content-type").equals("application/xml+xacml")){
			
			// Parameters for Monitoring
			
			String requestorID = "", token = "", monitoringID = "", loggerID = "", timeStamp = "", dataType = "", data = "";
			
			/* 
			 *  Parameters set-up for Monitoring service
			 */
			timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
			//this.context.log("timeStamp setted up: timeStamp="+timeStamp);
			
			//this.context.log("Trying to parse the xml");
			SAXBuilder saxBuilder = new SAXBuilder();
			InputSource is = new InputSource();
			is.setCharacterStream(new StringReader(jb.toString()));
			Document doc = new Document();
			try {
			    doc = saxBuilder.build(is);
			} catch (JDOMException e) {
			    // handle JDOMException
			} catch (IOException e) {
			    // handle IOException
			}
			
			Element root = doc.getRootElement();
			
			// Proceed to post Monitoring in Request xml
			if (root.getName().equals("Request")) {
				//this.context.log("Request xml. Proceed to retrieving parameters from parser..");
				List<Element> attrs = root.getChildren();
		    
				Element child = getElement(attrs);
				
				String req_type = child.getAttributeValue("Category");
				monitoringID = getChildrenAttributeValue(child,"urn:sunfish:attribute:request:path");
				
				if (req_type.contains("response")){
					//CREATE JSON for response data
					//this.context.log("It is a response!");
					String decision = "", body = "";
					
					decision = getChildrenAttributeValue(child, "urn:sunfish:attribute:response:response-code");
					decision = decision.replace("\n", "");
					decision = decision.replace(" ", "");

					body = Base64.encodeBase64String(doc.toString().getBytes());
		    	
					//Create the Json for data field.
					JSONObject obj = new JSONObject();
					obj.put("decision", decision);
					obj.put("body", body);
					data = obj.toString().replace(" ", "");
					//this.context.log("data value is " + data);
		    	
				} else {
					//Encode request
					//this.context.log("It is a request!");
		    	
					// encode data on your side using BASE64
					data = Base64.encodeBase64String(doc.toString().getBytes());
					//this.context.log("data value is " + data);
				}
		    
		    
				// ************* LOADING THE config.json ****************//
			
				String fullPath = this.catalina_home + "params.json";
				//this.context.log("Retrieved path: "+fullPath +" to load network and missing params.");
		 			
				JSONParser parser = new JSONParser();

				String ServerIP = "", Port = "", Path = "";

				try {
					//this.context.log("Loading the json object with parser");
					Object obj = parser.parse(new FileReader(fullPath));
		 				
					org.json.simple.JSONObject jsonObject = (org.json.simple.JSONObject) obj;

					ServerIP = (String) jsonObject.get("ServerIP");
					Port = (String) jsonObject.get("Port");
					Path = (String) jsonObject.get("Path");
					loggerID = (String) jsonObject.get("loggerID");
					requestorID = (String) jsonObject.get("requestorID");
					token = (String) jsonObject.get("token");
					dataType = (String) jsonObject.get("dataType");
					this.context.log("Missing and network params loaded.");

				} catch (Exception e) {
					e.printStackTrace();
					this.context.log("Error in json loading for params");
				}
		 			
				// ************* FINISH *************** //
		    
		 	
		    
				final String urlString = "http://"+ServerIP+":"+Port+"/"+Path;
				this.context.log("Preparing to POST the Monitor component at: " + urlString);
			
				final org.json.simple.JSONObject obj = new org.json.simple.JSONObject();

				obj.put("requestorID", requestorID);
				obj.put("token", token);
				obj.put("monitoringID", monitoringID);
				obj.put("loggerID", loggerID);
				obj.put("timeStamp", timeStamp);		
				obj.put("dataType", dataType);
				obj.put("data", data);
		
				this.context.log("Json for monitoring ready:\n\n"+obj.toString());
				Thread thread = new Thread(new Runnable() {
					@Override
					public void run() {
						HttpClient httpClient = HttpClientBuilder.create().build(); 																																						
						//System.out.println("Prova0");
						try {
							//System.out.println("Prova1");
							HttpPost req = new HttpPost(urlString);
							//System.out.println("Prova2");
							StringEntity params = new StringEntity(obj.toString());
							//System.out.println("Prova3");
							req.addHeader("content-type", "application/json");
							//System.out.println("Prova4");
							req.addHeader("Accept", "application/json");
							//System.out.println("Prova5");
							req.setEntity(params);
							//System.out.print("!!!!!!!!!!!!! CI SONO !!!!!!!!!!!!");
							HttpResponse response = httpClient.execute(req);
							context.log("Received response from MONITORING:" + response.toString());
							//System.out.print("Received response from MONITORING:" + response.toString());
							//no need to handle any response here, move on....
						} catch (Exception ex) {
							// handle exception here
							context.log("Error:" + ex);
							//System.out.println("Error:" + ex);
						} finally {
							// Deprecated
							// httpClient.getConnectionManager().shutdown();
						}
					}
				});
				thread.start();		    
			} else 
				this.context.log("OPS! Not tag Request in xml.");			
		}		
		filterChain.doFilter(multiReadRequest, response);
	}

	public void destroy() {
	}
	
	public static Element getElement(List<Element> elements) {
	    for (Element e : elements){
	    	if (e.getAttributeValue("Category").equals("urn:sunfish:attribute-category:request")){
	    		return e;
	    	}
	    	if (e.getAttributeValue("Category").equals("urn:sunfish:attribute-category:response")) {
	    		return e;
	    	}	
	    }
		return null;
	}
	
	public static String getChildrenAttributeValue(Element parent, String attrId){
		String value = "";
		for (Element e : parent.getChildren()){
    		if (e.getAttributeValue("AttributeId").equals(attrId)){
    			value = e.getValue().toString();
    		}
    	}
		return value;
	}

	public void init(FilterConfig arg0) throws ServletException {
		// TODO Auto-generated method stub
		this.context = arg0.getServletContext();
		this.req_count = 0;
		this.res_count = 0;
		//this.count = 0;
		this.context.log("SUNFISH ProxyFilter initialized");
	}

}
