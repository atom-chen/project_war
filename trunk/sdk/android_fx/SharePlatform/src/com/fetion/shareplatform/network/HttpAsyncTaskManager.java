package com.fetion.shareplatform.network;

import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.protocol.HTTP;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.fetion.shareplatform.json.handle.TaskHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.util.Utils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class HttpAsyncTaskManager implements Request{

	private static String TAG = HttpAsyncTaskManager.class.getSimpleName();
	private Context context;

	private static long TIME_OUT = 15000;	//毫秒，超时
	
	public HttpAsyncTaskManager(Context context) {
		this.context = context;
		
	}
	
	/**
	 * type ,0:get, 1:post
	 */
	@Override
	public void request(String url, int type, TaskHandler handler) {
		request(url, type, null, handler);
	}

	/**
	 * 不带参数
	 */
	@Override
	public void request(String url, int type, Map<String, String> params,
			TaskHandler handler) {
		if(context != null){
			synchronized(this){
				final AsyncTask<String, Integer, String> task = new HttpTask(context, url, type, params, handler).execute("");
				new Thread(){
			        public void run() {
			            try {
			                /**
			                 * 在这里你可以设置超时的时间
			                 * 切记：这段代码必须放到线程中执行，因为不放单独的线程中执行的话该方法会冻结UI线程
			                 * 直接导致onPreExecute()方法不执行
			                 */
			                task.get(TIME_OUT, TimeUnit.MILLISECONDS);
			            } catch (InterruptedException e) {
			            } catch (ExecutionException e) {
			            } catch (TimeoutException e) {
			                /**
			                 * 如果在doInbackground中的代码执行的时间超出10000秒则会出现这个异常。
			                 * 所以这里就成为你处理异常操作的唯一途径。
			                 * 备注：这里是不能够处理UI操作的，如果处理UI操作则会出现崩溃异常。
			                 * 你可以写一个Handler，向handler发送消息然后再Handler中接收消息并处理UI更新操作。
			                 */
			            	task.cancel(true);

			            }//请求超时
			        };
			    }.start();
			}
		}
	}

	/**
	 * 不带参数
	 */
	@Override
	public void requestAddTimeOut(String url, int type, Map<String, String> params,final int timeout,
			TaskHandler handler) {
		if(context != null){
			synchronized(this){
				final AsyncTask<String, Integer, String> task = new HttpTask(context, url, type, params, handler).execute("");
				new Thread(){
			        public void run() {
			            try {
			                /**
			                 * 在这里你可以设置超时的时间
			                 * 切记：这段代码必须放到线程中执行，因为不放单独的线程中执行的话该方法会冻结UI线程
			                 * 直接导致onPreExecute()方法不执行
			                 */
			                task.get(timeout, TimeUnit.MILLISECONDS);
			            } catch (InterruptedException e) {
			            } catch (ExecutionException e) {
			            } catch (TimeoutException e) {
			                /**
			                 * 如果在doInbackground中的代码执行的时间超出10000秒则会出现这个异常。
			                 * 所以这里就成为你处理异常操作的唯一途径。
			                 * 备注：这里是不能够处理UI操作的，如果处理UI操作则会出现崩溃异常。
			                 * 你可以写一个Handler，向handler发送消息然后再Handler中接收消息并处理UI更新操作。
			                 */
			            	task.cancel(true);

			            }//请求超时
			        };
			    }.start();
			}
		}
	}
	
	/**
	 * 不带参数  需要head头时使用额外map集合存储head信息
	 */
	@Override
	public void requestAddHead(String url, int type, Map<String, String> params,Map<String, String> head,
			TaskHandler handler) {
		if(context != null){
			synchronized(this){
				final AsyncTask<String, Integer, String> task = new HttpTask(context, url, type, params, head , handler).execute("");
				new Thread(){
			        public void run() {
			            try {
			                /**
			                 * 在这里你可以设置超时的时间
			                 * 切记：这段代码必须放到线程中执行，因为不放单独的线程中执行的话该方法会冻结UI线程
			                 * 直接导致onPreExecute()方法不执行
			                 */
			                task.get(TIME_OUT, TimeUnit.MILLISECONDS);
			            } catch (InterruptedException e) {
			            } catch (ExecutionException e) {
			            } catch (TimeoutException e) {
			                /**
			                 * 如果在doInbackground中的代码执行的时间超出10000秒则会出现这个异常。
			                 * 所以这里就成为你处理异常操作的唯一途径。
			                 * 备注：这里是不能够处理UI操作的，如果处理UI操作则会出现崩溃异常。
			                 * 你可以写一个Handler，向handler发送消息然后再Handler中接收消息并处理UI更新操作。
			                 */
			            	task.cancel(true);

			            }//请求超时
			        };
			    }.start();
			}
		}
	}
	
	private static class HttpTask extends
					AsyncTask<String, Integer, String>{
		private Context context;
		private String requestUrl;
		private Map<String, String> params;
		private Map<String, String> heads;
		private TaskHandler handler;
		private int type; // 0 : get,  1 : post

		public HttpTask(Context context, String url, int type, Map<String, String> param, TaskHandler handle){
			this.context = context;
			this.requestUrl = url;
			this.params = param;
			this.type = type;
			this.handler = handle;
		}
		//需要head头时
		public HttpTask(Context context, String url, int type, Map<String, String> param , Map<String, String> head, TaskHandler handle){
			this.context = context;
			this.requestUrl = url;
			this.params = param;
			this.heads=head;
			this.type = type;
			this.handler = handle;
		}
		@Override
		protected void onPreExecute(){
			if(!Utils.isNetworkAvaliable(context))
			{
				handler.onFailed(null);
			}
		}
		
		@Override
		protected String doInBackground(String... param) {
			InputStream in = null;
			String result = null;
			if(Utils.isNetworkAvaliable(context)){
				if(type == 0){ // Get
					HttpEntity entity = null;
					HttpGet get = new HttpGet(requestUrl);
					if(heads!=null){
						for(Map.Entry<String, String> entry: heads.entrySet()){
							if(entry.getKey() != null&&entry.getValue() !=null){
								get.addHeader(entry.getKey(), entry.getValue());
							}
						}
					}
					try{
						HttpResponse response = HttpFactory.execute(context,get);
						final int statusCode = response.getStatusLine().getStatusCode();
						entity = response.getEntity();
						
						if(statusCode == HttpStatus.SC_OK && entity != null){
							in = entity.getContent();
							result = Utils.stream2String(in);
							return result;
						}else{
							if(statusCode==1746){
								//增加删除数据库
							}
							get.abort();
						}
					}
					catch(Exception ex){
						get.abort();
						Log.i(TAG,"get=============="+ex.getMessage());
					}
				}else{
					final HttpPost post = new HttpPost(requestUrl);
					HttpEntity entity = null;
					if(heads!=null){
						for(Map.Entry<String, String> entry: heads.entrySet()){
							if(entry.getKey() != null&&entry.getValue() !=null){
								post.addHeader(entry.getKey(), entry.getValue());
							}
						}
					}
					try{
						String pairString = buildStringFromListPair(params);
						StringEntity stringEntity = new StringEntity(pairString, HTTP.UTF_8);
						if(heads!=null){
							stringEntity
							.setContentType("application/x-www-form-urlencoded;charset=UTF-8");
						}else{
						stringEntity.setContentType("application/x-www-form-urlencoded");	
						}
						post.setEntity(stringEntity);
						
						HttpResponse response = HttpFactory.execute(context, post);
						final int statusCode = response.getStatusLine().getStatusCode();
						entity = response.getEntity();
						
						if( statusCode == HttpStatus.SC_OK && entity != null)
						{
							in = entity.getContent();
							result = Utils.stream2String(in);
							return result;
						}else{
							post.abort();
						}
					}
					catch(Exception ex){
						post.abort();
						Log.i(TAG, "post=============="+ex.getMessage());
					}
				}
			}
			return result;
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
		
		// 根据list组参数
		private String buildStringFromListPair(List<NameValuePair> pairs){
			String result = "";
			
			for( NameValuePair pair: pairs ){
				if(pair.getName() != null){			
					result += pair.getName()+"=";
					if(pair.getValue()!=null){		
						result += pair.getValue();
					}
					result += "&";
				}
			}
			result = result.substring(0,result.length() - 1);
			return result;
		}
		
		protected void onPostExecute(String result){
			try{		
				if(result == null){
					handler.onFailed(null);
				}
				else{
					Log.i(TAG, "onPostExecute result ==== "+ result);
					if(result.contains("\"status\":") && result.contains("\"errorcode\":")){
						BaseErrorEntity errorEntity = null;
						try {
							errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
						} catch (Exception e) {
							handler.onFailed(result);
							e.printStackTrace();
						} finally{
							if(errorEntity != null){
								if("false".equals(errorEntity.getStatus())){
									if(errorEntity.getError() == 1746 && errorEntity.getError_description().equals("access token invalid  or expired")){
										handler.onFailed("need login");
									}else{
										handler.onFailed(result);
									}
								}else if("true".equals(errorEntity.getStatus())){
									handler.onSuccess(handler.parseResult(result));	
								}else{
									handler.onSuccess(handler.parseResult(result));
								}
							}else{
								handler.onFailed(result);
							}
						}
					}else{
						handler.onSuccess(handler.parseResult(result));	
					}
				}
			}
			catch(Exception ex){
				
			}
		}
		
		//onCancelled方法用于在取消执行中的任务时更改UI  
		@Override  
		protected void onCancelled() {  
			Log.i(TAG, "onCancelled() called");  
			handler.onTimeOut();
		}  
	}
}
