package com.fetion.shareplatforminvite.func;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.sourceforge.pinyin4j.lite.PinyinHelper;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.example.shareplatforminvite.R;
import com.fetion.shareplatform.func.login.LoginFuncEntry;
import com.fetion.shareplatform.json.handle.FetionErrorHandler;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.model.FetionAddressContactEntity;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.ContactJSONUtils;
import com.fetion.shareplatform.util.Utils;
import com.fetion.shareplatforminvite.adapter.ContactListAdapter;
import com.fetion.shareplatforminvite.view.Comparents;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class FeixinContactListActivity extends Activity {
	
	private RelativeLayout mRelativeLayout_background;
	private LinearLayout mLinearLayout_side;
	private ImageView mImageView_back;
	private EditText mEditText_search;
	private TextView mTextView_search_result;
	private ListView mListView_contact;
	/** 进度加载Loading */
	private LinearLayout mLinearLayout_progress; 
	/** 无缓存无网络时的提示信息 */
	private LinearLayout mLinearLayout_noNet;
	private TextView mTextView_reload;
	
	private String TAG = FeixinContactListActivity.class.getSimpleName();
	private String access_token;
	private AlertDialog.Builder builder = null;
	
	private List<FetionAddressContactEntity> mList_contact;
	private List<FetionAddressContactEntity> mList_cache;
	private MyHandler handler;
	private PinyinHelper pinyinHelper;
	private String[] letters = {"A","B","C","D","E","F","G","H","I","J","K","L"
			,"M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"};
	private HashMap<String, Integer> mHashMap_letter;
	private StringBuffer bufferLetter;
	private HashMap<String, Integer> mHashMap_simPinyin;
	private HashMap<String, Integer> mHashMap_allPinyin;
	
	private ContactListAdapter adapter = null;
	private String searchText = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
		setContentView(R.layout.shareplatform_invite_contact);
		access_token = Utils.getAccessToken(FeixinContactListActivity.this, "FX");
		mList_contact = new ArrayList<FetionAddressContactEntity>();
		mList_cache = new ArrayList<FetionAddressContactEntity>();
		handler = new MyHandler();
		pinyinHelper = PinyinHelper.getInstance();
		mHashMap_letter = new HashMap<String, Integer>();
		bufferLetter = new StringBuffer();
		mHashMap_simPinyin = new HashMap<String, Integer>();
		mHashMap_allPinyin = new HashMap<String, Integer>();
		initWidget();
		setWidgetListener();
		getContactFromCache();
		Log.i(TAG, "onCreate");
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		setContentView(R.layout.shareplatform_invite_contact);
		initWidget();
		setWidgetListener();
		adapter = null;
		if(mList_contact.size() > 0){
			mLinearLayout_progress.setVisibility(View.GONE);
			mTextView_search_result.setVisibility(View.GONE);
			mLinearLayout_noNet.setVisibility(View.GONE);
			mListView_contact.setVisibility(View.VISIBLE);
			adapter = new ContactListAdapter(FeixinContactListActivity.this, mList_contact);
			mListView_contact.setAdapter(adapter);
		}else{
			getContactFromCache();
		}
		mEditText_search.setFocusable(true);
		mEditText_search.setFocusableInTouchMode(true);
		mEditText_search.requestFocus();
		mEditText_search.requestFocusFromTouch();
		if(searchText != null && searchText.length() > 0){
			gotoSearch(searchText);
		}
		Log.i(TAG, "onConfigurationChanged");
		Log.i(TAG, "mListView_contact======"+mListView_contact.getVisibility());
		
	}
	
	/** 初始化控件 */
	private void initWidget(){
		mRelativeLayout_background = (RelativeLayout) findViewById(R.id.shareplatform_invite_background_id);
		Log.i(TAG, "mRelativeLayout_background"+mRelativeLayout_background.toString());
		mLinearLayout_side = (LinearLayout) findViewById(R.id.shareplatform_invite_view_id);
		mImageView_back = (ImageView) findViewById(R.id.shareplatform_invite_back_id);
		mEditText_search = (EditText) findViewById(R.id.shareplatform_invite_search_id);
		if(searchText != null && searchText.length() > 0){
			mEditText_search.setText(searchText);
			gotoSearch(searchText);
		}
		mTextView_search_result = (TextView) findViewById(R.id.shareplatform_invite_friends_search_text_id);
		mListView_contact = (ListView) findViewById(R.id.shareplatform_invite_contact_listview_id);
		Log.i(TAG, "mListView_contact"+mListView_contact.toString());
		mLinearLayout_progress = (LinearLayout) findViewById(R.id.shareplatform_invite_progressbar_id);
		mLinearLayout_noNet = (LinearLayout) findViewById(R.id.shareplatform_invite_nonet_id);
		mTextView_reload = (TextView) findViewById(R.id.shareplatform_invite_nonet_text_id);
	}
	
	/** 设置控件监听 */
	private void setWidgetListener(){
		mRelativeLayout_background.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				FeixinContactListActivity.this.finish();
				return false;
			}
		});
		mLinearLayout_side.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				return true;
			}
		});
		mImageView_back.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				FeixinContactListActivity.this.finish();
				return false;
			}
		});
		mListView_contact.setOnItemClickListener(itemClickListener);
		mEditText_search.addTextChangedListener(new MyTextWatcher());
		mTextView_reload.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(Utils.isNetworkAvaliable(FeixinContactListActivity.this)){
					//刷新数据
					mLinearLayout_progress.setVisibility(View.VISIBLE); 
					mLinearLayout_noNet.setVisibility(View.GONE);
					getContactFromCache();
				}else{
					Toast.makeText(FeixinContactListActivity.this, "网络连接不可用，请稍后重试", Toast.LENGTH_SHORT).show();
				}
			}
		});
	}
	
	private AdapterView.OnItemClickListener itemClickListener = new AdapterView.OnItemClickListener(){

		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position,
				long id) {
			// 分享到联系人
			final FetionAddressContactEntity addressContactEntity = mList_contact.get(position);
//			LinearLayout linearLayout = (LinearLayout) LayoutInflater.from(FeixinContactListActivity.this).inflate(R.layout.shareplatform_login_alter_net, null);
//    		TextView textView_reject = (TextView) linearLayout.findViewById(R.id.btn_reject);
//    		TextView textView_allow = (TextView) linearLayout.findViewById(R.id.btn_allow);
//    		TextView textView_content = (TextView) linearLayout.findViewById(R.id.textView1);
//    		textView_content.setText("分享给好友“" + addressContactEntity.getAddressname()+ "”?");
//    		final String mobile = addressContactEntity.getAddressmobile();
//    		final Dialog dialog  = new Dialog(FeixinContactListActivity.this, R.style.NobackDialog);
//    		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
//			dialog.setContentView(linearLayout, new RelativeLayout.LayoutParams(dip2px(FeixinContactListActivity.this, 249), dip2px(FeixinContactListActivity.this, 90)));
//			textView_reject.setOnTouchListener(new View.OnTouchListener() {
//
//				@Override
//				public boolean onTouch(View v, MotionEvent event) {
//					// 拒绝
//					if (dialog.isShowing()) {
//						dialog.dismiss();
//					}
//					return false;
//				}
//			});
//			textView_allow.setOnTouchListener(new View.OnTouchListener() {
//
//				@Override
//				public boolean onTouch(View v, MotionEvent event) {
//					// 允许
//					if (dialog.isShowing()) {
//						dialog.dismiss();
//					}
//					new PlatformHttpRequest(FeixinContactListActivity.this)
//							.FetionToContactMessages(access_token, mobile,
//									new FetionPublicAccountHandler() {
//
//										@Override
//										public void onFailed() {
//											InviteFuncEntry.gfriendsListListener
//													.onFailure("请求服务器失败");
//											Log.i(TAG, "请求服务器失败");
//										}
//
//										@Override
//										public void onTimeOut() {
//											InviteFuncEntry.gfriendsListListener
//													.onTimeOut();
//										}
//
//										@Override
//										public void onSuccess(String result) {
//											JSONObject json = null;
//											int num = 0;
//											try {
//												json = new JSONObject(result);
//												num = json.getInt("num");
//											} catch (JSONException e) {
//												e.printStackTrace();
//											}
//											Log.i(TAG, "result--" + result);
//											if (num > 0) {
//												InviteFuncEntry.gfriendsListListener
//														.onCompleted(true);
//											} else {
//												InviteFuncEntry.gfriendsListListener
//														.onCompleted(false);
//											}
//										}
//
//									});
//					return false;
//				}
//			});
			
			
			
			builder = new AlertDialog.Builder(FeixinContactListActivity.this);
			builder.setTitle("分享给好友“" + addressContactEntity.getAddressname()+ "”?");
			final String mobile = addressContactEntity.getAddressmobile();
			builder.setNegativeButton("确定",
					new DialogInterface.OnClickListener() {

						@Override
						public void onClick(DialogInterface dialog, int which) {
							new PlatformHttpRequest(FeixinContactListActivity.this).FetionToContactMessages(access_token, mobile, new FetionPublicAccountHandler(){

								@Override
								public void onFailed(String result) {
									setFailedInfo(result);
								}

								@Override
								public void onTimeOut() {
									InviteFuncEntry.gfriendsListListener.onTimeOut();
								}

								@Override
								public void onSuccess(
										String result) {
									JSONObject json = null;
									int num = 0;
									try {
										json = new JSONObject(result);
										num = json.getInt("num");
									} catch (JSONException e) {
										e.printStackTrace();
									}
									Log.i(TAG,"result--"+ result);
									if (num > 0) {
										InviteFuncEntry.gfriendsListListener.onCompleted(true);
									} else {
										InviteFuncEntry.gfriendsListListener.onCompleted(false);
									}
								}
						
					});
				}
			});
			builder.setPositiveButton("取消",
					new DialogInterface.OnClickListener() {

						@Override
						public void onClick(DialogInterface dialog, int which) {
						}
					});
			builder.show();
		}
	};
	
	private void setFailedInfo(String result){
		if(result != null){
			if(result.equals("need login")){
				InviteFuncEntry.gfriendsListListener.onFailure("need login", 0);
				LoginFuncEntry.fetionLogout(FeixinContactListActivity.this);
				Log.i(TAG,"need login");
			}else{
				BaseErrorEntity errorEntity = null;
				try {
					errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
				} catch (Exception e) {
					e.printStackTrace();
				} finally{
					if(errorEntity != null){
						if("false".equals(errorEntity.getStatus())){
							String errorCode = errorEntity.getErrorcode();
							if("01".equals(errorCode)){
								Log.i(TAG, "短信分发达到条数限制");
								InviteFuncEntry.gfriendsListListener.onFailure("短信分发达到条数限制", 1);
							}else if("02".equals(errorCode)){
								Log.i(TAG, "用户条数受限");
								InviteFuncEntry.gfriendsListListener.onFailure("用户条数受限", 2);
							}else if("03".equals(errorCode)){
								Log.i(TAG, "WPA侧故障");
								InviteFuncEntry.gfriendsListListener.onFailure("WPA侧故障", 3);
							}else{
								Log.i(TAG, "分享到短信失败");
								InviteFuncEntry.gfriendsListListener.onFailure("分享到短信失败", 4);
							}
						}else{
							InviteFuncEntry.gfriendsListListener.onFailure("分享到短信失败", 4);
							Log.i(TAG, "分享到短信失败");
						}
					}else{
						InviteFuncEntry.gfriendsListListener.onFailure("分享到短信失败", 4);
						Log.i(TAG, "分享到短信失败");
					}
				}
			}
		}else{
			InviteFuncEntry.gfriendsListListener.onFailure("请求服务器失败", 5);
			Log.i(TAG,"请求服务器失败");
		}
	}
	private class MyTextWatcher implements TextWatcher{

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
			
		}

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
		}

		@Override
		public void afterTextChanged(Editable s) {
			// String select = new String();
			if (mList_contact.size() > 0) {
				searchText = mEditText_search.getText().toString().replaceAll(" ", "").toLowerCase();
				Log.i(TAG, "searchText=" + searchText);
				gotoSearch(searchText);
			}
		}
	}
	
	
	private void gotoSearch(String select){
		if (select.length() > 0) {
			if (select.length() == 1) {
				searchFristLetter(select);
			} else {
				searchFriends(select);
			}
		} else {
			mTextView_search_result.setVisibility(View.GONE);
			mListView_contact.setVisibility(View.VISIBLE);
			mListView_contact.setSelection(0);
		}
	}
	
	private void searchFristLetter(String str){
		String pinyin = pinyinHelper.getPinyins(str, "").toLowerCase();
		if(pinyin.length() == 1){
			if(bufferLetter.toString().contains(pinyin)){
				if(mHashMap_letter.containsKey(pinyin)){
					mTextView_search_result.setVisibility(View.GONE);
					mListView_contact.setVisibility(View.VISIBLE);
					mListView_contact.setSelection(mHashMap_letter.get(pinyin));
				}else{
//					Toast.makeText(FeixinContactListActivity.this, "未找到任何联系人", Toast.LENGTH_SHORT).show();
//					mListView_contact.setSelection(0);
					mTextView_search_result.setVisibility(View.VISIBLE);
					mListView_contact.setVisibility(View.GONE);
					Log.i(TAG, "mListView_contact======GONE");
				}
			}else{
//				Toast.makeText(FeixinContactListActivity.this, "未找到任何联系人", Toast.LENGTH_SHORT).show();
//				mListView_contact.setSelection(0);
				mTextView_search_result.setVisibility(View.VISIBLE);
				mListView_contact.setVisibility(View.GONE);
				Log.i(TAG, "mListView_contact======GONE");
			}
		}else{
			if(bufferLetter.toString().contains(String.valueOf(pinyin.charAt(0)))){
				if(mHashMap_letter.containsKey(String.valueOf(pinyin.charAt(0)))){
					mTextView_search_result.setVisibility(View.GONE);
					mListView_contact.setVisibility(View.VISIBLE);
					mListView_contact.setSelection(mHashMap_letter.get(String.valueOf(pinyin.charAt(0))));
				}else{
//					Toast.makeText(FeixinContactListActivity.this, "未找到任何联系人", Toast.LENGTH_SHORT).show();
//					mListView_contact.setSelection(0);
					mTextView_search_result.setVisibility(View.VISIBLE);
					mListView_contact.setVisibility(View.GONE);
					Log.i(TAG, "mListView_contact======GONE");
				}
			}else{
//				Toast.makeText(FeixinContactListActivity.this, "未找到任何联系人", Toast.LENGTH_SHORT).show();
//				mListView_contact.setSelection(0);
				mTextView_search_result.setVisibility(View.VISIBLE);
				mListView_contact.setVisibility(View.GONE);
				Log.i(TAG, "mListView_contact======GONE");
			}
		}
	}
	
	private void searchFriends(String str){
		int position = -1;
		String pinyin = pinyinHelper.getFirstPinyins(str).toLowerCase();
		Log.i(TAG, "pinyin"+pinyin);
		String allPinyin = pinyinHelper.getPinyins(str, "").toLowerCase();
		Log.i(TAG, "allPinyin"+allPinyin);
		if(mHashMap_simPinyin.containsKey(pinyin)){
			position = mHashMap_simPinyin.get(pinyin);
			Log.i(TAG, "简拼position:"+position);
		}else{
			if(mHashMap_allPinyin.containsKey(allPinyin)){
				position = mHashMap_allPinyin.get(pinyin);
				Log.i(TAG, "全拼position:"+position);
			}
		}
		if (position >= 0) {
			mTextView_search_result.setVisibility(View.GONE);
			mListView_contact.setVisibility(View.VISIBLE);
			mListView_contact.setSelection(position);
		} else {
			mTextView_search_result.setVisibility(View.VISIBLE);
			mListView_contact.setVisibility(View.GONE);
			Log.i(TAG, "mListView_contact======GONE");
//			Toast.makeText(FeixinContactListActivity.this,
//					"未找到任何联系人", Toast.LENGTH_SHORT).show();
//			mListView_contact.setSelection(0);
		}
	}
	
	/** 操作UI界面  */
	private class MyHandler extends Handler {

		@Override
		public void handleMessage(Message msg) {
			
			switch (msg.what) {
			case 1:
				//刷新界面
				mLinearLayout_progress.setVisibility(View.GONE);
				if(mList_contact.size() > 0){
					Log.i(TAG, "mList_contact.size()"+mList_contact.size());
					mLinearLayout_noNet.setVisibility(View.GONE);
					setContactAdapter();
					//获取是否上传过通讯录
					getSDKAddressUpload();
				}else{
					mLinearLayout_noNet.setVisibility(View.VISIBLE);
				}
				break;
			case 2:
				mLinearLayout_progress.setVisibility(View.GONE);
				if(mList_contact.size() > 0){
					mLinearLayout_noNet.setVisibility(View.GONE);
					setContactAdapter();
					refreshPackageCache();
					//获取是否上传过通讯录
					getSDKAddressUpload();
				}else{
					mLinearLayout_noNet.setVisibility(View.VISIBLE);
				}
				break;
			}
			super.handleMessage(msg);
		}
	}
	
	private void getContactFromCache(){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				mList_cache = ContactJSONUtils.readContactFromPackage(FeixinContactListActivity.this, "fetioncontact.txt");
				if(mList_cache.size() > 0){
					//本地有缓存
					sortPhoneContacts(mList_cache);
					Message msg = new Message();
					msg.what = 1;
					handler.sendMessage(msg);
					Log.i(TAG, "本地有缓存");
				} else {
					//本地无缓存
					mList_cache = ContactJSONUtils.getFetionAddressContacts(FeixinContactListActivity.this);
					sortPhoneContacts(mList_cache);
					Log.i(TAG, "mList_contact长度=" + mList_contact.size());
					Log.i(TAG, "本地无缓存");
					Message msg = new Message();
					msg.what = 2;
					handler.sendMessage(msg);
				}
			}
		}).start();
	}
	
	/** 对通讯录联系人进行排序  */
	private void sortPhoneContacts(List<FetionAddressContactEntity> list){
		Log.i(TAG,"sortPhoneContacts()");
		mList_contact.clear();
//		adapter = null;
		mHashMap_letter.clear();
		mHashMap_simPinyin.clear();
		mHashMap_allPinyin.clear();
	
		Log.i(TAG,"mList_contact before >>>>>>>" +mList_contact.size());
		Collections.sort(list, new Comparents());
		for (int i = 0; i < letters.length; i++) {
			String letter = letters[i];
			if (isLetter(letter)) {
				for (int j = 0; j < list.size(); j++) {
					String currentLetter = String.valueOf(pinyinHelper.getFirstPinyins(list.get(j).getAddressname()).charAt(0)).toLowerCase();
					if (letter.equalsIgnoreCase(currentLetter)) {
						FetionAddressContactEntity addressContactEntity = new FetionAddressContactEntity();
						addressContactEntity.setAddressid(list.get(j).getAddressid());
						addressContactEntity.setAddressmobile(list.get(j).getAddressmobile());
						addressContactEntity.setAddressname(list.get(j).getAddressname());
						addressContactEntity.setAddressversion(list.get(j).getAddressversion());
						addressContactEntity.setFirstchar(letter);
						mList_contact.add(addressContactEntity);
					}
				}
			} else {
				for (int j = 0; j < list.size(); j++) {
					String currentLetter = String.valueOf(pinyinHelper.getFirstPinyins(list.get(j).getAddressname()).charAt(0)).toLowerCase();
					if (!isLetter(currentLetter)) {
						FetionAddressContactEntity addressContactEntity = new FetionAddressContactEntity();
						addressContactEntity.setAddressid(list.get(j).getAddressid());
						addressContactEntity.setAddressmobile(list.get(j).getAddressmobile());
						addressContactEntity.setAddressname(list.get(j).getAddressname());
						addressContactEntity.setAddressversion(list.get(j).getAddressversion());
						addressContactEntity.setFirstchar(letter);
						mList_contact.add(addressContactEntity);
					}
				}
			}
		}
		
		for (int i = 0; i < mList_contact.size(); i++) {
			String currentStr = String.valueOf(pinyinHelper.getFirstPinyins(mList_contact.get(i).getAddressname()).charAt(0)).toLowerCase();
            String previewStr = (i - 1) >= 0 ? String.valueOf(pinyinHelper.getFirstPinyins(mList_contact.get(i-1).getAddressname()).charAt(0)).toLowerCase() : " ";
            if (!previewStr.equals(currentStr)) {
            	mHashMap_letter.put(currentStr, i);  
            	bufferLetter.append(currentStr);
            } 
		}
		
		for (int i = 0; i < mList_contact.size(); i++) {
			String simplePinyin = pinyinHelper.getFirstPinyins(mList_contact.get(i).getAddressname()).toLowerCase();
//			Log.i(TAG, mList_contact.get(i).getAddressname()+"简拼=="+simplePinyin);
			if(mHashMap_simPinyin.containsKey(simplePinyin)){
			}else{
				mHashMap_simPinyin.put(simplePinyin, i);
			}
		}
		
		for (int i = 0; i < mList_contact.size(); i++) {
			String allPinyin = pinyinHelper.getPinyins(mList_contact.get(i).getAddressname(), "").toLowerCase();
//			Log.i(TAG, mList_contact.get(i).getAddressname()+"全拼=="+allPinyin);
			if(mHashMap_allPinyin.containsKey(allPinyin)){
				
			}else{
				mHashMap_allPinyin.put(allPinyin, i);
			}
		}
		Log.i(TAG,"mList_contact after <<<<<<<<<" +mList_contact.size());
	}
	
	private boolean isLetter(String str) {
		Pattern pattern = Pattern.compile("[a-zA-Z]");
		Matcher m = pattern.matcher(str);
		return m.matches();
	}
	
	private void setContactAdapter(){
		mListView_contact.setVisibility(View.VISIBLE);
		Log.i(TAG, "setContactAdapter");
		if(adapter == null){
			adapter = new ContactListAdapter(FeixinContactListActivity.this, mList_contact);
			mListView_contact.setAdapter(adapter);
			Log.i(TAG," adapter is null");
		}else{
			adapter.notifyDataSetChanged();
		}
	}
	
	/** 获取是否上传过通信录 */
	private void getSDKAddressUpload(){
		new PlatformHttpRequest(FeixinContactListActivity.this).getSDKAddress(access_token, 2, new FetionErrorHandler() {
			
			@Override
			public void onTimeOut() {
				Log.i(TAG, "get sdk address TimeOut!");
			}
			
			@Override
			public void onSuccess(BaseErrorEntity result) {
				if(result != null){
					//上传过通讯录
				}else{
					//没有上传过通讯录
					uploadSDKAddressContact();
				}
			}
			
			@Override
			public void onFailed(String result) {
				Log.i(TAG, "get sdk address failed!");
			}
		});
	}
	
	/** 上传通讯录 */
	private void uploadSDKAddressContact(){
		String contactJSON = ContactJSONUtils.createJSONForAdd(FeixinContactListActivity.this, mList_contact);
		Log.i(TAG, "全量通讯录JSON数据：" + contactJSON);
		new PlatformHttpRequest(FeixinContactListActivity.this).SDKAddressUp(access_token, 1, contactJSON,
            new FetionPublicAccountHandler() {
			
			@Override
			public void onTimeOut() {
				Log.i(TAG, "全量上传通讯录超时");
			}
			
			@Override
			public void onSuccess(String result) {
				Log.i(TAG, "全量上传通讯录成功");
//				JSONObject jsonObject = null;
//				String code = null;
//				try {
//					jsonObject = new JSONObject(result);
//					if(jsonObject.has("code")){
//						code = jsonObject.optString("code");
//					}
//				} catch (JSONException e) {
//					e.printStackTrace();
//				}
//				if(code != null){
//					if(code.equals("true")){
//						//全量上传通讯录成功
//						Log.i(TAG, "全量上传通讯录成功");
//					} else if(code.equals("false")){
//						//全量上传通讯录失败
//						Log.i(TAG, "全量上传通讯录失败");
//					}
//				}
			}
			
			@Override
			public void onFailed(String result) {
				Log.i(TAG, "全量上传通讯录失败");
			}
		});
	}
	
	/** 更新本地缓存 */
	private void refreshPackageCache(){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				Log.i(TAG, "更新本地缓存");
				ContactJSONUtils.saveContactToPackage(FeixinContactListActivity.this, "fetioncontact.txt", mList_contact);
			}
		}).start();
	}
}
