package com.fetion.shareplatform.network;

import java.util.Map;

import com.fetion.shareplatform.json.handle.TaskHandler;

public interface Request {
	void request(String url, int type,  TaskHandler handler);

	void request(String url, int type,  Map<String, String> params, TaskHandler handler);

	void requestAddHead(String url, int type, Map<String, String> params,
			Map<String, String> head, TaskHandler handler);

	void requestAddTimeOut(String url, int type, Map<String, String> params,
			int timeout, TaskHandler handler);

}
