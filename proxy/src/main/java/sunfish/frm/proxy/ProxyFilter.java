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

//Author: Md Sadek Ferdous

package sunfish.frm.proxy;
 
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

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

import org.json.JSONObject;
import org.json.simple.parser.JSONParser;
import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;

import org.apache.http.impl.client.HttpClientBuilder;
 
public class ProxyFilter implements Filter {

	private static class ByteArrayServletStream extends ServletOutputStream {

		ByteArrayOutputStream baos;

		ByteArrayServletStream(ByteArrayOutputStream baos) {
			this.baos = baos;
		}

		public void write(int param) throws IOException {
			baos.write(param);
		}
	}

	private static class ByteArrayPrintWriter {

		private ByteArrayOutputStream baos = new ByteArrayOutputStream();

		private PrintWriter pw = new PrintWriter(baos);

		private ServletOutputStream sos = new ByteArrayServletStream(baos);

		public PrintWriter getWriter() {
			return pw;
		}

		public ServletOutputStream getStream() {
			return sos;
		}

		byte[] toByteArray() {
			return baos.toByteArray();
		}
	}

	private class BufferedServletInputStream extends ServletInputStream {

		ByteArrayInputStream bais;

		public BufferedServletInputStream(ByteArrayInputStream bais) {
			this.bais = bais;
		}

		public int available() {
			return bais.available();
		}

		public int read() {
			return bais.read();
		}

		public int read(byte[] buf, int off, int len) {
			return bais.read(buf, off, len);
		}

	}		

	public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
			throws IOException, ServletException {

		final HttpServletRequest httpRequest = (HttpServletRequest) servletRequest;
		
		/* wrap the request in order to read the inputstream multiple times */
		CachedServletRequest multiReadRequest = new CachedServletRequest((HttpServletRequest) servletRequest);
		
		StringBuffer jb = new StringBuffer();
		String line = null;
		BufferedReader reader = new BufferedReader(new InputStreamReader(multiReadRequest.getInputStream()));
		
		try {
            while ((line = reader.readLine()) != null) {
                jb.append(line);
            }
        } finally {
        } 
		
		JSONObject jsonObj = new JSONObject(jb.toString());
		
		System.out.println("JSON:" + jsonObj.toString());		
		

		ServletContext context = httpRequest.getSession().getServletContext();
		String fullPath = context.getRealPath("/WEB-INF/config.json");

		JSONParser parser = new JSONParser();

		String loggerID = "", token = "", hostingID = "";

		try {

			Object obj = parser.parse(new FileReader(fullPath));

			org.json.simple.JSONObject jsonObject = (org.json.simple.JSONObject) obj;

			loggerID = (String) jsonObject.get("loggerID");
			hostingID = (String) jsonObject.get("hostingID");
			token = (String) jsonObject.get("token");

		} catch (Exception e) {
			e.printStackTrace();
		}
				  

		String timeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		String dataType = "REQUEST";

		System.out.println("At filter!");
		
		final String id = jsonObj.getString("id");
		String data = jsonObj.getString("xacmlReq");
		
		
		System.out.println("ID:"+ id);						

		final String urlString = "https://sp.sunfish.com:8075/api/monitoring/store";

		final org.json.simple.JSONObject obj = new org.json.simple.JSONObject();

		obj.put("loggerID", loggerID);
		obj.put("timeStamp", timeStamp);
		obj.put("token", token);
		obj.put("dataType", dataType);
		obj.put("data", data);
		obj.put("id", id);

		Thread thread = new Thread(new Runnable() {
			@Override
			public void run() {
				HttpClient httpClient = HttpClientBuilder.create().build(); 																																						

				try {
					HttpPost req = new HttpPost(urlString);
					StringEntity params = new StringEntity(obj.toJSONString());
					req.addHeader("content-type", "application/json");
					req.setEntity(params);
					HttpResponse response = httpClient.execute(req);
					System.out.println("Received response:" + response.toString());
					//no need to handle any response here, move on....
				} catch (Exception ex) {
					// handle exception here
					System.out.println("Error:" + ex);
				} finally {
					// Deprecated
					// httpClient.getConnectionManager().shutdown();
				}
			}
		});
		thread.start();

		final HttpServletResponse response = (HttpServletResponse) servletResponse;

		final ByteArrayPrintWriter pw = new ByteArrayPrintWriter();
		HttpServletResponse wrappedResp = new HttpServletResponseWrapper(response) {
			public PrintWriter getWriter() {
				return pw.getWriter();
			}

			public ServletOutputStream getOutputStream() {
				return pw.getStream();
			}

		};

		filterChain.doFilter(multiReadRequest, wrappedResp);
		
		if(hostingID.equals("PDP")){
			byte[] bytes = pw.toByteArray();
			response.getOutputStream().write(bytes);

			String returnResponse = new String(bytes);
			
			System.out.println("Return Response:" + returnResponse);

			final String encodedResponse = Base64.encodeBase64URLSafeString(returnResponse.getBytes());

			final String respLoggerID = loggerID, respToken = token;

			Thread responseThread = new Thread(new Runnable() {
				@Override
				public void run() {
					try {
						Thread.sleep(15000);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					HttpClient httpClient = HttpClientBuilder.create().build(); 
					
					String respTimeStamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
					String respDataType = "RESPONSE";
					org.json.simple.JSONObject obj = new org.json.simple.JSONObject();

					obj.put("loggerID", respLoggerID);
					obj.put("timeStamp", respTimeStamp);
					obj.put("token", respToken);
					obj.put("dataType", respDataType);
					obj.put("data", encodedResponse);
					obj.put("id", id);

					try {
						HttpPost req = new HttpPost(urlString);
						StringEntity params = new StringEntity(obj.toJSONString());
						req.addHeader("content-type", "application/json");
						req.setEntity(params);
						HttpResponse response = httpClient.execute(req);
						// no handle to response, move on...
					} catch (Exception ex) {

						// handle exception here
						System.out.println("Error:" + ex);

					} finally {
						// Deprecated
						// httpClient.getConnectionManager().shutdown();
					}
				}
			});
			responseThread.start();
		}
	}

	public void destroy() {
	}

	public void init(FilterConfig arg0) throws ServletException {
		// TODO Auto-generated method stub

	}

}
