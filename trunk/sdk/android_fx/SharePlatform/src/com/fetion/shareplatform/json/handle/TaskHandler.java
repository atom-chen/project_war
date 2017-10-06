package com.fetion.shareplatform.json.handle;

/**
 * 请求的结果和解析
 * @author wangchao
 *
 * @param <T>
 */
public abstract class TaskHandler<T> {

	public abstract void onFailed(String result);
	
	public abstract void onTimeOut();
	
	/**
	 * have a successful response
	 * @param result
	 */
	public abstract void onSuccess(T result);
	
	/**
	 * 解析结果，必须重写这个
	 * @param result
	 * @return
	 */
	public abstract T parseResult(String result);
}
