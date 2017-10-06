package com.onekes.kxllx;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.SAXException;

import android.util.Log;

public class XML {
	public static String read( String sContent, String sKey ) throws SAXException, IOException, ParserConfigurationException
	{
		// 为解析XML作准备，创建DocumentBuilderFactory实例,指定DocumentBuilder  
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();  
		DocumentBuilder db = null;
		db = dbf.newDocumentBuilder();  

		Document doc = db.parse(new ByteArrayInputStream(sContent.getBytes()));
		Element root = doc.getDocumentElement();
		NodeList nodes = root.getElementsByTagName(sKey);
		if( nodes.getLength() == 1 )
		{
			Element e = (Element) nodes.item(0);  
			Text t = (Text) e.getFirstChild();
			return t.getNodeValue();
		}
		return null;
	}
}
