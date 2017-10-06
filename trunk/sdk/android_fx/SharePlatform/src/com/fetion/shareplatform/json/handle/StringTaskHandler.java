package com.fetion.shareplatform.json.handle;

/**
 * string类型的请求处理
 * @author wangchao
 *
 */
public abstract class StringTaskHandler extends TaskHandler<String>{
	private static final String TAG = StringTaskHandler.class.getSimpleName();
	
	public String parseResult(String result){
	
		return result;
	}
}
