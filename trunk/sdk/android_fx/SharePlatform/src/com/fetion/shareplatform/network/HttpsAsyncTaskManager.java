package com.fetion.shareplatform.network;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.fetion.shareplatform.json.handle.TaskHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.util.Utils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class HttpsAsyncTaskManager implements Request{
	private static X509TrustManager myX509TrustManager = new X509TrustManager() { 

	    @Override 
	    public X509Certificate[] getAcceptedIssuers() { 
	        return null; 
	    } 

	    @Override 
	    public void checkClientTrusted(X509Certificate[] chain, String authType) 
	    throws CertificateException { 
	    }

		@Override
		public void checkServerTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {
			// TODO Auto-generated method stub

		} 
	};
	
	private static String TAG = HttpsAsyncTaskManager.class.getSimpleName();
	private Context context;
	private static int TIME_OUT = 15000;	//毫秒，超时
	
	public HttpsAsyncTaskManager(Context context){
		this.context = context;
	}
	
	@Override
	public void request(String url, int type, TaskHandler handler) {
		// TODO Auto-generated method stub
		request(url, type, null, handler);
	}

	@Override
	public void request(String url, int type, Map<String, String> params, TaskHandler handler) {
		// TODO Auto-generated method stub
		if(context != null){
			synchronized(this){
				final AsyncTask<String, Integer, String> myTask = new HttpsTask(context, url, type, TIME_OUT, params, handler).execute("");
				new Thread(){
					public void run(){
						try{
							myTask.get(TIME_OUT, TimeUnit.MILLISECONDS);
						}catch(InterruptedException ex){
						} catch (ExecutionException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (TimeoutException e) {
							myTask.cancel(isAlive());
						}
					}
				}.start();
			}
		}
	}

	@Override
	public void requestAddTimeOut(String url, int type,
			Map<String, String> params, final int timeout, TaskHandler handler) {
		// TODO Auto-generated method stub
		if(context != null){
			synchronized(this){
				final AsyncTask<String, Integer, String> myTask = new HttpsTask(context, url, type, timeout, params, handler).execute("");
				new Thread(){
					public void run(){
						try{
							myTask.get(TIME_OUT, TimeUnit.MILLISECONDS);
						}catch(InterruptedException ex){
							Log.i(TAG, "InterruptedException!!!!!!!!!!!!!!!!!!!!!!!!!");
						} catch (ExecutionException e) {
							// TODO Auto-generated catch block
							Log.i(TAG, "ExecutionException!!!!!!!!!!!!!!!!*******");
							e.printStackTrace();
						} catch (TimeoutException e) {
							myTask.cancel(isAlive());
						}
					}
				}.start();
			}
		}
	}
	
	private static class HttpsTask extends
	AsyncTask<String, Integer, String>{
		
		private Context context;
		private String requestUrl;
		private Map<String, String> params;
		private TaskHandler handler;
		private int timeout;
		private int type; // 0 : get,  1 : post
		
		public HttpsTask(Context context, String url, int type, int time, Map<String, String> param, TaskHandler handle){
			this.context = context;
			this.requestUrl = url;
			this.params = param;
			this.type = type;
			this.handler = handle;
			this.timeout = time;
			Log.i(TAG,"construct");
		}
		
		@Override
		protected String doInBackground(String... arg0) {
			if(Utils.isNetworkAvaliable(context)){
				HttpsURLConnection conn;
				try{
					Log.i(TAG, "start background.");
					String requestParam = buildStringFromListPair(params);
					Log.i(TAG, requestParam);
					
					//设置SSLContext 
		            SSLContext sslcontext = SSLContext.getInstance("TLS"); 
		            sslcontext.init(null, new TrustManager[]{myX509TrustManager}, null);
		            
		            //要发送的POST请求url?Key=Value&amp;Key2=Value2&amp;Key3=Value3的形式 
		            URL url = new URL(requestUrl + "?" + requestParam); 
		            Log.i(TAG,"url="+url.toString());
		            conn = (HttpsURLConnection) url.openConnection();
		            
		            conn.setSSLSocketFactory(sslcontext.getSocketFactory());
		            conn.setConnectTimeout(timeout);
		            conn.setRequestMethod("POST");
		            conn.setReadTimeout(timeout);
//		            conn.setDoOutput(true);
//		            
//		            DataOutputStream out = new DataOutputStream(conn.getOutputStream());
		            
		            // get inputStream
		            int code = conn.getResponseCode();
		            Log.i(TAG, "code="+code);
		            if( code == HttpURLConnection.HTTP_OK){
		            	InputStream in = conn.getInputStream();
		            	return Utils.stream2String(in);
		            }
				}catch(Exception ex){
					//Todo
					Log.i(TAG,"doInBackground Exception!******************* +me="+ex.getMessage());
					ex.printStackTrace();
					return null;
				}
			}
			return null;
		}
		
		@Override
		protected void onPreExecute(){
			if(!Utils.isNetworkAvaliable(context))
			{
				handler.onFailed(null);
			}
		}
		
		protected void onPostExecute(String result){
			try{		
				if(result == null){
					Log.i(TAG, "onPostExecute ==== result = null");
					handler.onFailed(null);
				}
				else{
					Log.i(TAG, "onPostExecute ==== result = " + result);
					if(result.contains("\"status\":") && result.contains("\"errorcode\":")){
						BaseErrorEntity errorEntity = null;
						try {
							errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
						} catch (Exception e) {
							handler.onFailed(result);
							e.printStackTrace();
						}
						if(errorEntity != null){
							if("false".equals(errorEntity.getStatus())){
								handler.onFailed(result);
							}else if("true".equals(errorEntity.getStatus())){
								handler.onSuccess(handler.parseResult(result));	
							}
						}else{
							handler.onFailed(result);
						}
					}else{
						handler.onSuccess(handler.parseResult(result));	
					}
				}
			}
			catch(Exception ex){
				Log.i(TAG, "onPostExecute Exception!*******************");
			}
		}
		
		//onCancelled方法用于在取消执行中的任务时更改UI  
		@Override  
		protected void onCancelled() {  
			Log.i(TAG, "onCancelled() called");  
			handler.onTimeOut();
		}  
		
		// 根据map组参数
		private String buildStringFromListPair(Map<String, String> params){
			String result = "";
			if(params != null && !params.isEmpty()){
				for(Map.Entry<String, String> entry: params.entrySet()){
					if(entry.getKey() != null){			
						result += entry.getKey()+"=";
						if(entry.getValue()!=null){		
							result += entry.getValue();
						}
						result += "&";
					}
				}
			}
			result = result.substring(0,result.length() - 1);
			return result;
		}
	}

	@Override
	public void requestAddHead(String url, int type,
			Map<String, String> params, Map<String, String> head,
			TaskHandler handler) {
		request(url, type, params, handler);
	}
}
