package com.fetion.shareplatform.network;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.text.TextUtils;

import com.fetion.shareplatform.db.StatisticDao;
import com.fetion.shareplatform.model.StatisticInfo;

public class HttpRequest {
	
	// HttpPost方式请求
	public void requestByHttpPost(final Context context, final String app, final String client, final String network, 
			final String username, final String target, final String shareUrl, final boolean result) {
		
		new Thread() {
			public void run() {
				
				try {

					JSONArray array = new JSONArray();
					//本次数据
					JSONObject obj = new JSONObject();
					try {
						obj.put("app", app);
						obj.put("client", client);
						obj.put("network", network);
						obj.put("username", username);
						obj.put("target", target);
						if (!TextUtils.isEmpty(shareUrl)) {
							obj.put("shareurl", shareUrl);
						}
						obj.put("result", String.valueOf(result));
					} catch (JSONException e1) {
						e1.printStackTrace();
					}
					array.put(obj);
					
					List<StatisticInfo> list = StatisticDao.getInstance(context).query();
					for (StatisticInfo info : list) {
						JSONObject failObj = new JSONObject();
						failObj.put("app", info.getAppName());
						failObj.put("client", info.getPhoenModel());
						failObj.put("network", info.getNetworkType());
						failObj.put("target", info.getTargetPlatform());
						if (!TextUtils.isEmpty(shareUrl)) {
							failObj.put("shareUrl", info.getShareUrl());
						}
						failObj.put("result", info.getResult());
						array.put(failObj);
					}
					
					String path = "http://share.fetionyy.com.cn/collect/collect.php";
					// 新建HttpPost对象
					HttpPost httpPost = new HttpPost(path);
					// Post参数
					List<NameValuePair> params = new ArrayList<NameValuePair>();
					params.add(new BasicNameValuePair("data", array.toString()));
					// 设置字符集
					HttpEntity entity = new UrlEncodedFormEntity(params, HTTP.UTF_8);
					// 设置参数实体
					httpPost.setEntity(entity);
					// 获取HttpClient对象
					HttpClient httpClient = new DefaultHttpClient();
					// 获取HttpResponse实例
					HttpResponse httpResp = httpClient.execute(httpPost);
					// 判断是够请求成功
					if (httpResp.getStatusLine().getStatusCode() == 200) {
						// 获取返回的数据
						EntityUtils.toString(httpResp.getEntity(), "UTF-8");
						StatisticDao.getInstance(context).deleteAsync();
					} else {
						StatisticInfo info = new StatisticInfo();
						info.setAppName(app);
						info.setShareUrl(shareUrl);
						info.setNetworkType(network);
						info.setPhoenModel(client);
						info.setResult(String.valueOf(result));
						info.setTargetPlatform(target);
						StatisticDao.getInstance(context).insertAsync(info);
					}
				} catch(Exception e) {
				}
			};
		}.start();
	}
	
	// HttpGet方式请求
	public void requestByHttpGet(final String url) {
		
		new Thread() {
			public void run() {
				
				JSONArray array = new JSONArray();
				JSONObject obj = new JSONObject();
				try {
					obj.put("app", "demo");
					obj.put("client", "HuaWei");
					obj.put("network", "wifi");
					obj.put("username", "test");
					obj.put("target", "weibo");
					obj.put("shareurl", "http://www.baidu.com");
					obj.put("result", "true");
				} catch (JSONException e1) {
					e1.printStackTrace();
				}
				array.put(obj);
				try {
					String path = "http://share.fetionyy.com.cn/collect/";
					path += array.toString();
					// 新建HttpPost对象
					HttpGet httpGet = new HttpGet(path);
					// 获取HttpResponse实例
					HttpResponse httpResp = new DefaultHttpClient().execute(httpGet);
					// 判断是够请求成功
					if (httpResp.getStatusLine().getStatusCode() == 200) {
						// 获取返回的数据
						EntityUtils.toString(httpResp.getEntity(), "UTF-8");
					}
				} catch(Exception e) {
					e.printStackTrace();
				}
			};
		}.start();
	}
}