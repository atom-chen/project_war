package com.fetion.shareplatform.util;

import java.util.ArrayList;
import java.util.List;

import com.fetion.shareplatform.json.handle.FetionErrorHandler;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.model.FetionAddressContactEntity;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

/**
 * 此类用于处理通讯录的增量上传
 * @author fangmin
 *
 */
public class IncrementalUploadContact {
	private String TAG = IncrementalUploadContact.class.getSimpleName();
	private Context mContext;
	private String access_token;
	private SharedPreferences mSharedPreferences = null; 
	private boolean readLocalContacts = false;
	private MyHandler myHandler = null;
	private List<FetionAddressContactEntity> mList_cache = null;
	private List<FetionAddressContactEntity> mList_contact = null;
	private List<FetionAddressContactEntity> mList_local = null;
	
	private boolean addSuccess = false;
	private boolean updateSuccess = false;
	private boolean deleteSuccess = false;
	
	public IncrementalUploadContact(Context context, String access_token){
		this.mContext = context;
		this.access_token = access_token;
		myHandler = new MyHandler();
		mList_cache = new ArrayList<FetionAddressContactEntity>();
		mList_contact = new ArrayList<FetionAddressContactEntity>();
		mList_local = new ArrayList<FetionAddressContactEntity>();
		mSharedPreferences = context.getSharedPreferences("shareplatform", Context.MODE_PRIVATE); 
		readLocalContacts = mSharedPreferences.getBoolean("readLocalContacts", false);
	}
	
	/** 由此方法进入开始处理通讯录的流程 */
	public void startUploadContact(){
		if(readLocalContacts){
			//有本地通讯录访问权限,获取上传通讯录标识(即是否上传过通讯录)
			getSDKAddressUpload();
		}else{
			//无本地通讯录访问权限
		}
	}
	
	/** 获取是否上传过通信录 */
	private void getSDKAddressUpload(){
		new PlatformHttpRequest(mContext).getSDKAddress(access_token, 2, new FetionErrorHandler() {
			
			@Override
			public void onTimeOut() {
				Log.i(TAG, "获取是否上传过通讯录请求超时");
			}
			
			@Override
			public void onSuccess(BaseErrorEntity result) {
				Log.i(TAG, "获取是否上传过通讯录请求成功");
				if(result != null){
					//上传过通讯录，判断本地是否有缓存
					judgeCacheContact();
				}else{
					//没有上传过通讯录
				}

			}
			
			@Override
			public void onFailed(String result) {
				Log.i(TAG, "获取是否上传过通讯录请求失败");
			}
		});
	}
	
	/** 操作UI界面  */
	@SuppressLint("HandlerLeak")
	private class MyHandler extends Handler {

		@Override
		public void handleMessage(Message msg) {
			
			switch (msg.what) {
			case 1:
				if(mList_cache.size() > 0){
					//本地有缓存
					Log.i(TAG, "本地有缓存");
					setSDKContactADU(mList_cache);
				} else {
					//本地无缓存
					Log.i(TAG, "本地无缓存");
//					getSDKAddressContactUploaded();
				}
				break;
			}
			super.handleMessage(msg);
		}
	}
	
	/** 获取本地缓存 */
	private void judgeCacheContact(){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				mList_cache = ContactJSONUtils.readContactFromPackage(mContext, "fetioncontact.txt");
				Message msg = new Message();
				msg.what = 1;
				myHandler.sendMessage(msg);
			}
		}).start();
		
	}
	
	/** 获取上传过的通讯录 */
	private void getSDKAddressContactUploaded(){
		new PlatformHttpRequest(mContext).getSDKAddress(access_token, 1, new FetionPublicAccountHandler() {
			
			@Override
			public void onTimeOut() {
				Log.i(TAG, "获取上传过的通讯录超时");
			}
			
			@Override
			public void onSuccess(String result) {
				Log.i(TAG, "result:"+result);
				Log.i(TAG, "获取上传过的通讯录成功");
				mList_contact = new Gson().fromJson(result.trim(),new TypeToken<List<FetionAddressContactEntity>>(){}.getType());
				if(mList_contact.size() > 0){
					//服务器有缓存,更新本地缓存
					refreshPackageCache(mList_contact, 1);
					setSDKContactADU(mList_contact);
				}else{
					//服务器无缓存,结束
				}
			}
			
			@Override
			public void onFailed(String result) {
				Log.i(TAG, "获取上传过的通讯录失败");
			}
		});
	}
	
	/** 获取通讯录增加、更新和删除的数据 */
	private void setSDKContactADU(List<FetionAddressContactEntity> list){
		String addData = ContactJSONUtils.getAddContacts(mContext, list);
		Log.i(TAG, "addData="+addData);
		String updateData = ContactJSONUtils.getUpdateContact(mContext, list);
		Log.i(TAG, "updateData="+updateData);
		String deleteData = ContactJSONUtils.getDeleteContact(mContext, list);
		Log.i(TAG, "deleteData="+deleteData);
		if(addData != null && !addData.equals("{}")){
			//增量添加上传
			updateAddressToNet(1, addData);
		}else{
			addSuccess = true;
		}
		if(updateData != null && !updateData.equals("{}")){
			//增量更新上传
			updateAddressToNet(2, updateData);
		}else{
			updateSuccess = true;
		}
		if (deleteData != null && !deleteData.equals("{}")) {
			//增量删除上传
			updateAddressToNet(3, deleteData);
		}else{
			deleteSuccess = true;
		}
	}
	
	/**  
	 * 通讯录的增量添加上传、增量更新上传和增量删除上传
	 * @param type    1：添加  2：更新   3：删除
	 * @param jsonData 变化的通讯录数据
	 */
	private void updateAddressToNet(final int type, String jsonData){
		new PlatformHttpRequest(mContext).SDKAddressUp(access_token, type, jsonData,
	            new FetionPublicAccountHandler() {
				
				@Override
				public void onTimeOut() {
					switch (type) {
					case 1:
						Log.i(TAG, "增量添加上传通讯录超时");
						break;
					case 2:
						Log.i(TAG, "增量更新上传通讯录超时");
						break;
					case 3:
						Log.i(TAG, "增量删除上传通讯录超时");
						break;
					}
				}
				
				@Override
				public void onSuccess(String result) {
					switch (type) {
					case 1:
						Log.i(TAG, "增量添加上传通讯录成功");
						addSuccess = true;
						break;
					case 2:
						Log.i(TAG, "增量更新上传通讯录成功");
						updateSuccess = true;
						break;
					case 3:
						Log.i(TAG, "增量删除上传通讯录成功");
						deleteSuccess = true;
						break;
					}
					if(addSuccess && updateSuccess && deleteSuccess){
						refreshPackageCache(mList_local, 2);
					}
				}
				
				@Override
				public void onFailed(String result) {
					if(result != null){
						switch (type) {
						case 1:
							Log.i(TAG, "增量添加上传通讯录失败");
							break;
						case 2:
							Log.i(TAG, "增量更新上传通讯录失败");
							break;
						case 3:
							Log.i(TAG, "增量删除上传通讯录失败");
							break;
						}
					}else{
						switch (type) {
						case 1:
							Log.i(TAG, "增量添加上传通讯录,请求服务器失败");
							break;
						case 2:
							Log.i(TAG, "增量更新上传通讯录,请求服务器失败");
							break;
						case 3:
							Log.i(TAG, "增量删除上传通讯录,请求服务器失败");
							break;
						}
					}
				}
			});
	}
	
	/** 刷新本地缓存 */
	private void refreshPackageCache(final List<FetionAddressContactEntity> list, final int type){
		new Thread(new Runnable() {

			@Override
			public void run() {
				Log.i(TAG, "更新本地缓存");
				if (type == 1) {
					ContactJSONUtils.saveContactToPackage(mContext, "fetioncontact.txt", list);
				} else {
					if (mList_local.size() > 0) {
						ContactJSONUtils.saveContactToPackage(mContext, "fetioncontact.txt", mList_local);
					} else {
						mList_local = ContactJSONUtils.getFetionAddressContacts(mContext);
						ContactJSONUtils.saveContactToPackage(mContext, "fetioncontact.txt", mList_local);
					}
				}
			}
		}).start();
	}
}
