package com.fetion.shareplatforminvite.func;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.http.util.EncodingUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.example.shareplatforminvite.R;
import com.fetion.shareplatform.func.login.LoginFuncEntry;
import com.fetion.shareplatform.json.handle.FetionFriendsListTaskHandler;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.model.FetionContactEntity;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.CharacterParser;
import com.fetion.shareplatform.util.GetRecentCallRecordUtils;
import com.fetion.shareplatform.util.Utils;
import com.fetion.shareplatforminvite.adapter.FriendsListAdapter;
import com.fetion.shareplatforminvite.view.XListView;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class FeixinFriendsListActivity extends Activity{
	
    private FriendsListAdapter adapter;
    private RelativeLayout mLinearLayout_background;
    private LinearLayout mLinearLayout_side;
    private LinearLayout mLinearLayout_progress;
    private ImageView mImageView_back;
    private LinearLayout mLinearLayout_gotoContact;
    private XListView mListView;
    private EditText searchFriends;
    private LinearLayout mLinearLayout_nonet;
    private TextView mTextView_noNet;
    private AlertDialog.Builder builder = null;
    
    private MyHandler handler = null;
    private List<FetionContactEntity> mList_friends = null;
    private List<FetionContactEntity> recentCalls = null;
    private String [] firstPinyins = null;
    private HashMap<String, Integer> alphaIndexer;//存放存在的汉语拼音首字母和与之对应的列表位置
    private StringBuffer sections;//存放存在的汉语拼音首字母
    private HashMap<String, Integer> allPingyins;
    private CharacterParser characterParser = null;
    
	private String TAG = FeixinFriendsListActivity.class.getSimpleName();
	public static String EXTRA_KEY_ACCESSTOKEN = "access_token";
	public static String EXTRA_KEY_SHAREPLATFORMINFO = "sharePlatformInfo";
	public static String EXTRA_KEY_SHARETYPE = "shareType";
	public static String EXTRA_KEY_SHARETOFETION = "shareToFetion";
    
	private String access_token;
	private SharePlatformInfo sharePlatformInfo;
	private int shareType;
	private int shareToFetion;
	
	private boolean firstLoad = true;
	private GetRecentCallRecordUtils recordUtils;
	private boolean readLocalContacts = false;
	private boolean isAddContact = false;
	private SharedPreferences mSharedPreferences = null;
	private int fetionNum = 0;
	private int fetionVersion = 0;
	
	private int bossNum = 20;
	private String select = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
		setContentView(R.layout.shareplatform_invite);
		
		Intent intent = getIntent();
		access_token = Utils.getAccessToken(FeixinFriendsListActivity.this, "FX");
		sharePlatformInfo = (SharePlatformInfo)intent.getSerializableExtra(EXTRA_KEY_SHAREPLATFORMINFO);
		shareType = intent.getIntExtra(EXTRA_KEY_SHARETYPE, 1);
		shareToFetion = intent.getIntExtra(EXTRA_KEY_SHARETOFETION, 1);
		mList_friends = new ArrayList<FetionContactEntity>();
		recentCalls = new ArrayList<FetionContactEntity>();
		alphaIndexer = new HashMap<String, Integer>();
		allPingyins = new HashMap<String, Integer>();
		handler = new MyHandler();
		characterParser = new CharacterParser();
		recordUtils = new GetRecentCallRecordUtils(this);
		mSharedPreferences = FeixinFriendsListActivity.this.getSharedPreferences("shareplatform", Context.MODE_PRIVATE); 
		isAddContact = false;
		SharedPreferences.Editor editor = mSharedPreferences.edit();
		editor.putBoolean("isAddContact", isAddContact);
		editor.commit();
		initWidget();
		setWidgetListener();
		firstLoad();
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		setContentView(R.layout.shareplatform_invite);
		initWidget();
		setWidgetListener();
		adapter = null;
		if(mList_friends.size() > 0){
			mLinearLayout_progress.setVisibility(View.GONE);
			mLinearLayout_nonet.setVisibility(View.GONE);
			mListView.setVisibility(View.VISIBLE);
			adapter = new FriendsListAdapter(FeixinFriendsListActivity.this,mList_friends);
			mListView.setAdapter(adapter); 
		}else{
			firstLoad();
		}
		searchFriends.setFocusable(true);
		searchFriends.setFocusableInTouchMode(true);
		searchFriends.requestFocus();
		searchFriends.requestFocusFromTouch();
		if(select != null && select.length() > 0){
			gotoSearch(select);
		}
	}
	
	private void initWidget(){
		mLinearLayout_background = (RelativeLayout) findViewById(R.id.shareplatform_invite_background_id);
		mLinearLayout_side = (LinearLayout) findViewById(R.id.shareplatform_invite_view_id);
		mLinearLayout_progress = (LinearLayout) findViewById(R.id.shareplatform_invite_progressbar_id);
		mImageView_back = (ImageView) findViewById(R.id.shareplatform_invite_back_id);
		mLinearLayout_gotoContact = (LinearLayout) findViewById(R.id.shareplatform_invite_contact_list_id);
		mListView = (XListView) findViewById(R.id.shareplatform_invite_friends_listview_id);
		mListView.setPullLoadEnable(false);
		mListView.setPullRefreshEnable(true);
		mListView.setRefreshTime(getStrTime(System.currentTimeMillis()));
		searchFriends = (EditText) findViewById(R.id.shareplatform_invite_search_id);
		searchFriends.setText(select);
		mLinearLayout_nonet = (LinearLayout) findViewById(R.id.shareplatform_invite_nonet_id);
		mTextView_noNet =  (TextView) findViewById(R.id.shareplatform_invite_nonet_text_id);
	}
	
	private void setWidgetListener(){
		mListView.setOnItemClickListener(listener);
		searchFriends.addTextChangedListener(new MyTextWatcher());
		mLinearLayout_background.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				FeixinFriendsListActivity.this.finish();
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
				FeixinFriendsListActivity.this.finish();
				return false;
			}
		});
		readLocalContacts = mSharedPreferences.getBoolean("readLocalContacts", false);
		mLinearLayout_gotoContact.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(readLocalContacts){
					FeixinFriendsListActivity.this.startActivity(new Intent(FeixinFriendsListActivity.this, FeixinContactListActivity.class));
				}else{
					builder = new AlertDialog.Builder(FeixinFriendsListActivity.this);
					builder.setTitle("应用将访问您的通讯录");
					builder.setNegativeButton("拒绝",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									readLocalContacts = false;
									SharedPreferences.Editor editor = mSharedPreferences.edit();
									editor.putBoolean("readLocalContacts", readLocalContacts);
									editor.commit();
									Toast.makeText(FeixinFriendsListActivity.this, "未获得权限", Toast.LENGTH_SHORT).show();
								}
					});
					builder.setPositiveButton("允许", new DialogInterface.OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							readLocalContacts = true;
							SharedPreferences.Editor editor = mSharedPreferences.edit();
							editor.putBoolean("readLocalContacts", readLocalContacts);
							editor.commit();
							FeixinFriendsListActivity.this.startActivity(new Intent(FeixinFriendsListActivity.this, FeixinContactListActivity.class));
						}
					});
					builder.show();
				}
			}
		});
		mListView.setXListViewListener(new XListView.IXListViewListener() {

			@Override
			public void onRefresh() {
				//刷新数据
				if(Utils.isNetworkAvaliable(FeixinFriendsListActivity.this)){
					loadFriendsList();
				}else{
					mListView.stopRefresh();
					mListView.stopLoadMore();
					Toast.makeText(FeixinFriendsListActivity.this, "网络连接不可用，请稍后重试", Toast.LENGTH_SHORT).show();
				}
			}

			@Override
			public void onLoadMore() {
				//不做处理
			}

		});
		mTextView_noNet.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if(Utils.isNetworkAvaliable(FeixinFriendsListActivity.this)){
					loadFriendsList();
				}else{
					Toast.makeText(FeixinFriendsListActivity.this, "网络连接不可用，请稍后重试", Toast.LENGTH_SHORT).show();
				}
			}
		});
	}

	/**
	 * 将毫秒转为字符串方式的时间格式
	 * 
	 * @param filetime
	 * @return
	 */
	@SuppressLint("SimpleDateFormat")
	private String getStrTime(long filetime) {
		if (filetime == 0) {
			return "未知";
		}
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-hh:mm:ss");
		String ftime = formatter.format(new Date(filetime));
		return ftime;
	}
	
	private String getUrl() {
		String url = null;
		if(sharePlatformInfo == null){
			return url;
		}
		switch (shareType) {
		case 1:
			url =  new PlatformHttpRequest(this).formatUrl((sharePlatformInfo.getText()));
			Log.i(TAG, "分享文本=="+url);
			break;
		case 2:
			url = sharePlatformInfo.getmImageUrl();
			break;
		case 3:
			url = sharePlatformInfo.getVideoUrl();
			break;
		case 4:
			int index = 0;
			String str = sharePlatformInfo.getPageUrl();
			if(str == null){
				return str;
			}
			str = str.toLowerCase();
			
			if (str.contains("http://")) {
				index = str.lastIndexOf("http://");
			} else if (str.contains("https://")) {
				index = str.lastIndexOf("https://");
			} else {
				Log.i(TAG, "the url is illegal");
			}
			String needUrl = sharePlatformInfo.getPageUrl().substring(index,
					sharePlatformInfo.getPageUrl().length());
			String behindStr = sharePlatformInfo.getPageUrl().substring(0,
					index);
			url = new PlatformHttpRequest(this).formatUrl(behindStr)
					+ new PlatformHttpRequest(this).formatUrl(needUrl);
			Log.i(TAG,"url="+url);
			Log.i(TAG, "url length = "+ url.length());
			break;
		}
		return url;
	}
	
	private AdapterView.OnItemClickListener listener = new AdapterView.OnItemClickListener(){

		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position,
				long id) {
			Log.i(TAG, "position===" + position);
			final FetionContactEntity contactEntity = mList_friends.get(position - 1);
			final int isCmUser = contactEntity.getIsCmUser();
			final long friendid = contactEntity.getUserId();
			final String number = contactEntity.getNumber();
			builder = new AlertDialog.Builder(FeixinFriendsListActivity.this);
			builder.setTitle("分享给好友“" + contactEntity.getNickname()+ "”?");
			builder.setPositiveButton("确定",
					new DialogInterface.OnClickListener() {

						@Override
						public void onClick(DialogInterface dialog, int which) {
							if (shareToFetion == 1) {
								new PlatformHttpRequest(
										FeixinFriendsListActivity.this)
										.FetionToFriends(
												access_token,
												String.valueOf(contactEntity.getUserId()),
												getUrl(),
												new FetionPublicAccountHandler() {

													@Override
													public void onSuccess(String result) {
														JSONObject json = null;
														int code = 0;
														try {
															json = new JSONObject(result);
															code = json.getInt("statusCode");
														} catch (JSONException e) {
															e.printStackTrace();
														}
														Log.i(TAG, "result--"+ result);
														if (code == 200) {
															InviteFuncEntry.gfriendsListListener.onCompleted(true);
														} else {
															InviteFuncEntry.gfriendsListListener.onCompleted(false);
														}
													}


													@Override
													public void onTimeOut() {
														InviteFuncEntry.gfriendsListListener.onTimeOut();
													}

													@Override
													public void onFailed(
															String result) {
														InviteFuncEntry.gfriendsListListener.onFailure("请求服务器失败", 5);
														Log.i(TAG, "请求服务器失败");
													}
												});
							} else {
								if (isCmUser == 1) {
									if(friendid == 0 && number != null){
										//通讯录好友
										new PlatformHttpRequest(FeixinFriendsListActivity.this).FetionToContactMessages(access_token,
												number, new FetionPublicAccountHandler(){

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
									}else if(friendid != 0 && number == null){
										//飞信好友
										new PlatformHttpRequest(FeixinFriendsListActivity.this).FetionToFetionMessages(access_token,
												String.valueOf(friendid), new FetionPublicAccountHandler(){

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
								} else {
									//此处判断点击的是否是最近通话的item
									Toast.makeText(FeixinFriendsListActivity.this,"此用户没有电话号码", Toast.LENGTH_SHORT).show();
								}
							}
						}
					});

			builder.setNegativeButton("取消",
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
				LoginFuncEntry.fetionLogout(FeixinFriendsListActivity.this);
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
			select = searchFriends.getText().toString().replaceAll(" ", "");
			if(mList_friends.size() > 0 && select != null){
				gotoSearch(select);
			}
		}
	}
	
	private void gotoSearch(String select){
		if (select.length() > 0) {
			if (select.length() == 1) {
				searchFristLetter(select);
			} else {
				int position = searchFriends(select);
				if (position < mList_friends.size() - 1 && position >=0) {
					mListView.setSelection(position + 1 + bossNum);
				} else {
					mListView.setSelection(position + bossNum);
				}
				// mListView.setSelection(searchFriends(select));
			}
		} else {
			mListView.setSelection(0);
		}
	}
	
	private void searchFristLetter(String select){
		if(String.valueOf(select.charAt(0)).getBytes().length == 1){
			String letter = Utils.getAlpha(select);
			if(sections.toString().contains(letter)){
				int position = alphaIndexer.get(letter);
				if (position < mList_friends.size() - 1 && position >= 0) {
					mListView.setSelection(position + 1 + bossNum);
				} else {
					mListView.setSelection(position + bossNum);
				}
				
			}else{
				Toast.makeText(FeixinFriendsListActivity.this, "未找到任何好友", Toast.LENGTH_LONG).show();
				InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);  
				imm.hideSoftInputFromWindow(searchFriends.getWindowToken(), 0);
				mListView.setSelection(0);
			}
	    }else{
			String letter = Utils.getAlpha(characterParser.getSelling(select));
			if(sections.toString().contains(letter)){
				int position = 0;
				if(allPingyins.containsKey(characterParser.getSelling(select))){
					position = allPingyins.get(characterParser.getSelling(select));
				}else{
					position = alphaIndexer.get(letter);
				}
				if (position < mList_friends.size() - 1 && position >= 0) {
					mListView.setSelection(position + 1 + bossNum);
				} else {
					mListView.setSelection(position + bossNum);
				}
			}else{
				Toast.makeText(FeixinFriendsListActivity.this, "未找到任何好友", Toast.LENGTH_LONG).show();
				InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);  
				imm.hideSoftInputFromWindow(searchFriends.getWindowToken(), 0);
				mListView.setSelection(0);
			}
	    } 
	}
	
	private int searchFriends(String select){
		int position = -1;	
		for (int i = 0; i < firstPinyins.length; i++) { 
			if(characterParser.getFirstSelling(select).equalsIgnoreCase(firstPinyins[i])){
				position = i;
				break;
			}
		}
		if(position == -1){
			if(allPingyins.containsKey(characterParser.getSelling(select))){
				position = allPingyins.get(characterParser.getSelling(select));
			}else{
				String letter = Utils.getAlpha(characterParser.getSelling(select));
				if(sections.toString().contains(letter)){
					position = alphaIndexer.get(letter);
				}
			}
		}
		return position;
	}
	
	/** 接收返回值 操作界面 */
	@SuppressLint("HandlerLeak")
	public class MyHandler extends Handler {

		@Override
		public void handleMessage(Message msg) {
			
			switch (msg.what) {
			case 1:
				firstLoad = false;
				mLinearLayout_progress.setVisibility(View.VISIBLE);
				mListView.setVisibility(View.VISIBLE);
				mLinearLayout_nonet.setVisibility(View.GONE);
				mLinearLayout_gotoContact.setVisibility(View.GONE);
				firstSetData();
				break;
			case 2:
				firstLoad = true;
				mLinearLayout_progress.setVisibility(View.VISIBLE);
				mListView.setVisibility(View.VISIBLE);
				mLinearLayout_nonet.setVisibility(View.GONE);
				mLinearLayout_gotoContact.setVisibility(View.GONE);
				loadFriendsList();
				break;
			case 3:
				firstLoad = false;
				mLinearLayout_progress.setVisibility(View.GONE);
				mListView.setVisibility(View.VISIBLE);
				mLinearLayout_nonet.setVisibility(View.GONE);
				mLinearLayout_gotoContact.setVisibility(View.GONE);
				firstSetData();
				Toast.makeText(FeixinFriendsListActivity.this, "网络连接错误",
						Toast.LENGTH_SHORT).show();
				break;
			case 4:
				firstLoad = true;
				Toast.makeText(FeixinFriendsListActivity.this, "网络连接错误",
						Toast.LENGTH_SHORT).show();
				mList_friends.clear();
				firstSetData();
				break;
			case 5:
				if(mList_friends.size() > 0){
					mLinearLayout_progress.setVisibility(View.GONE);
					mListView.setVisibility(View.VISIBLE);
					mLinearLayout_nonet.setVisibility(View.GONE);
					mLinearLayout_gotoContact.setVisibility(View.GONE);
					mListView.requestLayout();
					if(adapter == null){
						adapter = new FriendsListAdapter(FeixinFriendsListActivity.this,mList_friends);
						mListView.setAdapter(adapter);
					}else{
						adapter.notifyDataSetChanged();
					}
				}else{
					mLinearLayout_progress.setVisibility(View.GONE);
					mListView.setVisibility(View.GONE);
					mLinearLayout_nonet.setVisibility(View.GONE);
					mLinearLayout_gotoContact.setVisibility(View.VISIBLE);
				}
				break;
			}
			super.handleMessage(msg);
		}
	}
	
	/** 设置boss话单 */
	private void setBossContact(){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				SharedPreferences.Editor editor = mSharedPreferences.edit();
				isAddContact = false;
				if(!isAddContact){
					if(recentCalls == null || recentCalls.size() == 0){
						recentCalls = recordUtils.setContenResolver();
						if(recentCalls.size() > 0){
							if(recentCalls.size() <= 20){
								bossNum = recentCalls.size();
								mList_friends.addAll(0, recentCalls);
							}else{
								bossNum = 20;
								for (int i = 19; i >= 0; i--) {
									mList_friends.add(0, recentCalls.get(i));
								}
							}
							isAddContact = true;
							editor.putBoolean("isAddContact", isAddContact);
							editor.commit();
						}else{
							Log.i(TAG, "新用户获取最近通话记录失败或无通话记录");
						}
					}else{
						if(recentCalls.size() <= 20){
							bossNum = recentCalls.size();
							mList_friends.addAll(0, recentCalls);
						}else{
							bossNum = 20;
							for (int i = 19; i >= 0; i--) {
								mList_friends.add(0, recentCalls.get(i));
							}
						}
					}
				}else{
				}
				setData(mList_friends);
			}
		}).start();
		
	}
	
	/** 加载数据 */
	private void firstLoad() {
		if (Utils.isNetworkAvaliable(FeixinFriendsListActivity.this)) {
			new Thread(new Runnable() {
				
				@Override
				public void run() {
					
					List<FetionContactEntity> firstData = getDataFromCache();
					if(firstData != null){
						if (firstData.size() > 0) {
							mList_friends.clear();
							isAddContact = false;
							SharedPreferences.Editor editor = mSharedPreferences.edit();
							editor.putBoolean("isAddContact", isAddContact);
							editor.commit();
							mList_friends.addAll(firstData);
							Message msg = new Message();
							msg.what = 1;
							handler.sendMessage(msg);
						} else {
							Message msg = new Message();
							msg.what = 2;
							handler.sendMessage(msg);
						}
					}else{
						Message msg = new Message();
						msg.what = 2;
						handler.sendMessage(msg);
					}
				}
			}).start();
		} else {
			new Thread(new Runnable() {

				@Override
				public void run() {
					List<FetionContactEntity> firstData = getDataFromCache();
					if(firstData != null){
						if (firstData.size() > 0) {
							mList_friends.clear();
							isAddContact = false;
							SharedPreferences.Editor editor = mSharedPreferences.edit();
							editor.putBoolean("isAddContact", isAddContact);
							editor.commit();
							mList_friends.addAll(firstData);
							Message msg = new Message();
							msg.what = 3;
							handler.sendMessage(msg);
						} else {
							Message msg = new Message();
							msg.what = 4;
							handler.sendMessage(msg);
						}
					}else{
						setBossContact();
						Message msg = new Message();
						msg.what = 5;
						handler.sendMessage(msg);
					}
				}
			}).start();
		}
	}
    
//    /**
//     * 此方法是从服务器获取分页好友
//     */
//    private void loadFriendsList(final int page){
//    	if(page == 1){
//    		mProgressLoading.setVisibility(View.GONE);
//    	}else{
//    		progressBar.setVisibility(View.VISIBLE);
//    		loadingText.setText("加载中...");
//    	}
//		new PlatformHttpRequest(FeixinFriendsListActivity.this).FetionGetPagerFriends(oauthToken, page, new FetionFriendsListTaskHandler(FeixinFriendsListActivity.this, page){
//			@Override
//			public void onFailed() {
//				if(page != 1){
//					pagerid--;
//				}
//				Toast.makeText(FeixinFriendsListActivity.this, "请求服务器失败", Toast.LENGTH_SHORT).show();
//				mLinearLayout_progress.setVisibility(View.GONE);
//				mProgressLoading.setVisibility(View.GONE);
//			}
//
//			@Override
//			public void onSuccess(List<FetionContactEntity> result) { 
//				if(result != null){
//					if(page == 1){
//						letterList.clear();
//					}
//					mLinearLayout_progress.setVisibility(View.GONE);
//					if(previewLength == -1){
//						previewLength = result.size();
//						currentLength = result.size();
//				    }else{
//				    	previewLength = currentLength;
//				    	currentLength = result.size();
//				    }
//					letterList.addAll(result);
//					setData(result);
//				}else{
//					//请求数据为空
//					Log.i(TAG, "解析数据失败");
//				}
//			}
//
//			@Override
//			public void onTimeOut() {
//				Toast.makeText(FeixinFriendsListActivity.this, "连接服务器超时", Toast.LENGTH_SHORT).show();
//				mLinearLayout_progress.setVisibility(View.GONE);
//				mProgressLoading.setVisibility(View.GONE);
//			}		
//		});
//	} 
    
    /**
     * 此方法是从服务器获取全部好友
     */
	private void loadFriendsList(){
		new PlatformHttpRequest(FeixinFriendsListActivity.this).FetionGetFriends(access_token, new FetionFriendsListTaskHandler(FeixinFriendsListActivity.this, 1){

			@Override
			public void onSuccess(List<FetionContactEntity> result) {
				SharedPreferences.Editor editor = mSharedPreferences.edit();
				if(result.size() > 0){
					mList_friends.clear();
					isAddContact = false;
					editor.putBoolean("isAddContact", isAddContact);
					editor.commit();
					mList_friends.addAll(result);
					readLocalContacts = mSharedPreferences.getBoolean("readLocalContacts", false);
					setBossContact();
					
				}else{
					mList_friends.clear();
					isAddContact = false;
					editor.putBoolean("isAddContact", isAddContact);
					editor.commit();
					readLocalContacts = mSharedPreferences.getBoolean("readLocalContacts", false);
					setBossContact();
				}
				mListView.stopRefresh();
				mListView.stopLoadMore();
				fetionVersion = mSharedPreferences.getInt("fetionVersion", 0);
				if(fetionVersion == 0){
                	editor.putInt("fetionVersion", 1);
                	editor.commit();
                }
			}

			@Override
			public void onTimeOut() {
				mListView.stopRefresh();
	            mListView.stopLoadMore();
                if(firstLoad){
                	Toast.makeText(FeixinFriendsListActivity.this, "数据获取失败,请尝试手动加载", Toast.LENGTH_SHORT).show();
                	firstLoad = false;
    				Message msg = new Message();
    				msg.what = 5;
    				handler.sendMessage(msg);
				}else{
					Toast.makeText(FeixinFriendsListActivity.this, "TimeOut", Toast.LENGTH_SHORT).show();
					mLinearLayout_progress.setVisibility(View.GONE);
				}
                fetionVersion = mSharedPreferences.getInt("fetionVersion", 0);
                SharedPreferences.Editor editor = mSharedPreferences.edit();
                if(fetionVersion == 0){
                	editor.putInt("fetionVersion", 0);
                	editor.commit();
                }
			}

			@Override
			public void onFailure(String result) {
				setGetFriendsListFailedInfo(result);
			}		
		});
	} 	

	private void setGetFriendsListFailedInfo(String result){
		mListView.stopRefresh();
		mListView.stopLoadMore();
		if(result != null){
			if(result.equals("need login")){
				InviteFuncEntry.gfriendsListListener.onFailure("need login" , 0);
				LoginFuncEntry.fetionLogout(FeixinFriendsListActivity.this);
				Log.i(TAG,"need login");
			}else{
				if(firstLoad){
					Toast.makeText(FeixinFriendsListActivity.this, "数据获取失败,请尝试手动加载", Toast.LENGTH_SHORT).show();
					firstLoad = false;
					Message msg = new Message();
					msg.what = 5;
					handler.sendMessage(msg);
				}else{
					Toast.makeText(FeixinFriendsListActivity.this, "请求服务器失败", Toast.LENGTH_SHORT).show();
					mLinearLayout_progress.setVisibility(View.GONE);
				}
				fetionVersion = mSharedPreferences.getInt("fetionVersion", 0);
                SharedPreferences.Editor editor = mSharedPreferences.edit();
                if(fetionVersion == 0){
                	editor.putInt("fetionVersion", 0);
                	editor.commit();
                }
			}
		}else{
			if(firstLoad){
				Toast.makeText(FeixinFriendsListActivity.this, "数据获取失败,请尝试手动加载", Toast.LENGTH_SHORT).show();
				firstLoad = false;
				Message msg = new Message();
				msg.what = 5;
				handler.sendMessage(msg);
			}else{
				Toast.makeText(FeixinFriendsListActivity.this, "请求服务器失败", Toast.LENGTH_SHORT).show();
				mLinearLayout_progress.setVisibility(View.GONE);
			}
			fetionVersion = mSharedPreferences.getInt("fetionVersion", 0);
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            if(fetionVersion == 0){
            	editor.putInt("fetionVersion", 0);
            	editor.commit();
            }
		}
	}
	
	private void firstSetData() {
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				sections = new StringBuffer();
				alphaIndexer.clear();
				allPingyins.clear();
				for (int i = 0; i < mList_friends.size(); i++) {
					// 当前汉语拼音首字母
					String currentStr = mList_friends.get(i).getFirstchar();
					// 上一个汉语拼音首字母，如果不存在为“ ”
					String previewStr = (i - 1) >= 0 ? mList_friends.get(i - 1).getFirstchar(): " ";
					if (!previewStr.equals(currentStr)) {
						alphaIndexer.put(currentStr, i);
						sections.append(currentStr);
					}
				}

				firstPinyins = new String[mList_friends.size()];
				for (int i = 0; i < mList_friends.size(); i++) {
					firstPinyins[i] = characterParser
							.getFirstSelling(mList_friends.get(i).getNickname());
				}
				for (int i = 0; i < mList_friends.size(); i++) {
					String pinyin = characterParser.getSelling(mList_friends.get(i).getNickname());
					if(!allPingyins.containsKey(pinyin)){
						allPingyins.put(pinyin, i);
					}else{
						int firstsite = allPingyins.get(pinyin);
						if(firstsite > i){
							allPingyins.remove(pinyin);
							allPingyins.put(pinyin, i);
						}else{
							
						}
					}
				}
				searchFriends.setVisibility(View.VISIBLE);
				mListView.setVisibility(View.VISIBLE);
		    	isAddContact = mSharedPreferences.getBoolean("isAddContact", false);
				if( !isAddContact){
					recentCalls = recordUtils.setContenResolver();
					if(recentCalls.size() > 0){
						if(recentCalls.size() <= 20){
							bossNum = recentCalls.size();
							mList_friends.addAll(0, recentCalls);
						}else{
							bossNum = 20;
							for (int i = 19; i >= 0; i--) {
								mList_friends.add(0, recentCalls.get(i));
							}
						}
						isAddContact = true;
						SharedPreferences.Editor editor = mSharedPreferences.edit();
						editor.putBoolean("isAddContact", isAddContact);
						editor.commit();
					}else{
						bossNum = 0;
						Log.i(TAG, "获取最近通话记录失败或无通话记录");
					}
				}else{
				}
				Message msg = new Message();
				msg.what = 5;
				handler.sendMessage(msg);
				FeixinFriendsListActivity.this.runOnUiThread(new Runnable() {
					
					@Override
					public void run() {
						if(Utils.isNetworkAvaliable(FeixinFriendsListActivity.this)){
							getSDKBuddyVersion();
						}else{
						}
					}
				});
			}
		}).start();
		
	}
	
	private void setData(final List<FetionContactEntity> result){
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				sections = new StringBuffer();
				alphaIndexer.clear();
				allPingyins.clear();
				for (int i = 0; i < mList_friends.size(); i++) {
					//当前汉语拼音首字母
					String currentStr = mList_friends.get(i).getFirstchar();
					//上一个汉语拼音首字母，如果不存在为“ ”
		            String previewStr = (i - 1) >= 0 ? mList_friends.get(i-1).getFirstchar() : " ";
		            if (!previewStr.equals(currentStr)) {
		            	alphaIndexer.put(currentStr, i);  
		            	sections.append(currentStr);
		            }   
				}
				
				firstPinyins = new String[mList_friends.size()];
				for (int i = 0; i < mList_friends.size(); i++) {
					firstPinyins[i] = characterParser.getFirstSelling(mList_friends.get(i).getNickname());
				}
				for (int i = 0; i < mList_friends.size(); i++) {
					String pinyin = characterParser.getSelling(mList_friends.get(i).getNickname());
					if(!allPingyins.containsKey(pinyin)){
						allPingyins.put(pinyin, i);
					}else{
						int firstsite = allPingyins.get(pinyin);
						if(firstsite > i){
							allPingyins.remove(pinyin);
							allPingyins.put(pinyin, i);
						}else{
						}
					}
				}
		    	
				Message msg = new Message();
				msg.what = 5;
				handler.sendMessage(msg);
//				for (int i = 0; i < mList_friends.size(); i++) {
//					Log.i(TAG, mList_friends.get(i).getNickname());
//					Log.i(TAG, characterParser.getSelling(mList_friends.get(i).getNickname()));
//				}
				Log.i(TAG, "好友列表的长度：" + mList_friends.size());
			}
		}).start();
	}
	
	/** 读取缓存 */
	private List<FetionContactEntity> getDataFromCache() {
		File file = null;
		String res = null;
		List<FetionContactEntity> friends = null;
		if (Environment.getExternalStorageState().equals(
				android.os.Environment.MEDIA_MOUNTED)) {
			File path = Environment.getExternalStorageDirectory();
			file = new File(path, "fetion.txt");
		} else {
			File path = FeixinFriendsListActivity.this.getCacheDir();
			file = new File(path, "fetion.txt");
		}
		if(file.exists()){
			try {
				FileInputStream fin = new FileInputStream(file);
				int length = fin.available();
				byte[] buffer = new byte[length];
				fin.read(buffer);
				res = EncodingUtils.getString(buffer, "UTF-8");
				fin.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (res != null) {
				friends = new Gson().fromJson(res.trim(),new TypeToken<List<FetionContactEntity>>(){}.getType());
			} else {
			}
		}
		return friends;

	}
	
	/** 获取好友版本号 */
	private void getSDKBuddyVersion(){
		new PlatformHttpRequest(FeixinFriendsListActivity.this).getSDKBuddyVersion(access_token, new FetionPublicAccountHandler(){

			@Override
			public void onFailed(String result) {
				Toast.makeText(FeixinFriendsListActivity.this, "数据获取失败,请尝试手动加载", Toast.LENGTH_SHORT).show();
				Log.i(TAG, "get sdk buddy version Failed!");
			}

			@Override
			public void onTimeOut() {
				Toast.makeText(FeixinFriendsListActivity.this, "数据获取失败,请尝试手动加载", Toast.LENGTH_SHORT).show();
				Log.i(TAG, "get sdk buddy version TimeOut!");
			}

			@Override
			public void onSuccess(String result) {
				JSONObject jsonObject = null;
				int num = 0;
				int version = 1;
				try {
					jsonObject = new JSONObject(result);
					if(jsonObject.has("num")){
						num = jsonObject.optInt("num");
					}
					if(jsonObject.has("version")){
						version = jsonObject.optInt("version");
					}
				} catch (JSONException e) {
					e.printStackTrace();
				}
				fetionNum = mSharedPreferences.getInt("fetionNum", 0);
				fetionVersion = mSharedPreferences.getInt("fetionVersion", 0);
				SharedPreferences.Editor editor = mSharedPreferences.edit();
				if(fetionNum != num){
					fetionNum = num;
					editor.putInt("fetionNum", num);
					editor.commit();
				}
				if(fetionVersion != version){
					fetionVersion = version;
					editor.putInt("fetionVersion", version);
					editor.commit();
					firstLoad = true;
					loadFriendsList();
				}
			}
		});
	}
	
	@Override
	protected void onDestroy() {
		mList_friends.clear();
		super.onDestroy();
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if(keyCode == KeyEvent.KEYCODE_BACK){
			if(builder != null){
				builder = null;
			}
			FeixinFriendsListActivity.this.finish();
		}
		return super.onKeyDown(keyCode, event);
	}
}
