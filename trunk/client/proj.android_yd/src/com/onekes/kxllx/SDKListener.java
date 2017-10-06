package com.onekes.kxllx;

import java.util.HashMap;

public abstract class SDKListener {
	private int mId = 0;
	private Object mObject = null;
	private int mHandler = 0;
	private HashMap<String, Integer> mIntegerMap = new HashMap<String, Integer>();
	private HashMap<String, Double> mDoubleMap = new HashMap<String, Double>();
	private HashMap<String, String> mStringMap = new HashMap<String, String>();
	
	public SDKListener() {}
	
	public SDKListener(int id) {
		mId = id;
	}
	
	public SDKListener(int id, Object obj) {
		mId = id;
		mObject = obj;
	}
	
	public SDKListener(int id, Object obj, int handler) {
		mId = id;
		mObject = obj;
		mHandler = handler;
	}
	
	public int getId() {
		return mId;
	}
	
	public void setId(int id) {
		mId = id;
	}
	
	public Object getObject() {
		return mObject;
	}
	
	public void setObject(Object obj) {
		mObject = obj;
	}
	
	public int getHandler() {
		return mHandler;
	}
	
	public void setHandler(int handler) {
		mHandler = handler;
	}
	
	public Integer get(String key, Integer def) {
		if (mIntegerMap.containsKey(key)) {
			return mIntegerMap.get(key);
		}
		return def;
	}
	
	public Double get(String key, Double def) {
		if (mDoubleMap.containsKey(key)) {
			return mDoubleMap.get(key);
		}
		return def;
	}
	
	public String get(String key, String def) {
		if (mStringMap.containsKey(key)) {
			return mStringMap.get(key);
		}
		return def;
	}
	
	public void set(String key, Integer i) {
		mIntegerMap.put(key, i);
	}
	
	public void set(String key, Double d) {
		mDoubleMap.put(key, d);
	}
	
	public void set(String key, String s) {
		mStringMap.put(key, s);
	}
	
	public abstract void onCallback(int resultCode, Object resultObject);
}
