package com.fetion.shareplatform.func.login;

import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.example.strans.MyTransCode;
import com.fetion.shareplatform.R;
import com.fetion.shareplatform.json.handle.FetionErrorHandler;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.IncrementalUploadContact;
import com.fetion.shareplatform.util.Utils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

public class AutoLoginActivity extends Activity{
	private LinearLayout mLinearLayout_background;
	
	private String TAG = AutoLoginActivity.class.getSimpleName();
	private String appKey = null;
	/** 记录是否是第一次登录 */
	private static boolean  firstLogin = true;
	/** 记录是否是获取了系统短信的权限 */
	private boolean  getSmsAuthority = false;
	private SharedPreferences mSharedPreferences = null;
	private boolean retryLogin = false;
	private String miAndAppKey = null;
	
	/** 利用广播监听短信的发送 */
	private BroadcastReceiver sendSmsReceiver = null;
	private BroadcastReceiver backSmsReceiver = null;
	private PendingIntent sendIntent = null;
	private PendingIntent backIntent = null;
	private boolean sendRegisterReceiver = false;
	private boolean backRegisterReceiver = false;
	
	/** 自动登录的提示框相关布局变量 */
	private Dialog mDialog_TokenAvalible = null;
	private RelativeLayout mLinearLayout_tokenAvalible = null;
	private RelativeLayout mRelativeLayout_login = null;
	private Button btn_login = null;
	private Dialog mDialog_AutoLogin = null;
	private Dialog mDialog_LoginSuccess = null;
	private RelativeLayout mLinearLayout_LoginSuccess = null;

	private boolean hasLogined = false;
	private boolean forceExit = false;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.shareplatform_login_autologin);
		appKey = this.getIntent().getStringExtra("autoLoginAppkey");
		init();
		if(!Utils.selectToken(AutoLoginActivity.this, "FX")){
			startAutoLogin();
	    }else{
	    	OauthAccessToken token = new OauthAccessToken();
			token.access_token = Utils.getAccessToken(AutoLoginActivity.this, "FX");
			Log.i(TAG, "用户已登录过的token：" + token.access_token);
	    	accressTokenAvaliable(token);
	    }
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		setContentView(R.layout.shareplatform_login_autologin);
		init();
	}
	
	private void init(){
		mLinearLayout_background = (LinearLayout) findViewById(R.id.shareplatform_login_auto_login_bakground);
		mLinearLayout_background.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(LoginFuncEntry.loginListener != null){
					LoginFuncEntry.loginListener.onCancle();
				}
				AutoLoginActivity.this.finish();
				return false;
			}
		});
	}
	
	/**
	 * 游戏签到
	 * @param token
	 * @param type  登录类型：1.已登录过 2.自动登录
	 */
	private void gameSign(final OauthAccessToken token, final int type) {
		new PlatformHttpRequest(AutoLoginActivity.this).gameSign(
				token.access_token, new FetionErrorHandler() {

					@Override
					public void onTimeOut() {
						if(type == 1){
							Log.i(TAG, "已登录过，签到超时");
						} else {
							Log.i(TAG, "自动登录，签到超时");
							new IncrementalUploadContact(AutoLoginActivity.this, token.access_token).startUploadContact();
						}
					}

					@Override
					public void onSuccess(BaseErrorEntity result) {
						if(type == 1){
							Log.i(TAG, "已登录过，签到成功");
						} else{
							Log.i(TAG, "自动登录，签到成功");
							new IncrementalUploadContact(AutoLoginActivity.this, token.access_token).startUploadContact();
						}
					}

					@Override
					public void onFailed(String result) {
						if (result != null) {
							if ("need login".equals(result)) {
								Log.i(TAG, "用户的token失效,须重新登录");
								LoginFuncEntry.fetionLogout(AutoLoginActivity.this);
								startAutoLogin();
							} else {
								if(type == 1){
									Log.i(TAG, "已登录过，签到失败");
								}else{
									Log.i(TAG, "自动登录，签到失败");
									new IncrementalUploadContact(AutoLoginActivity.this, token.access_token).startUploadContact();
								}
							}
						} else {
							if(type == 1){
								Log.i(TAG, "已登录过，签到请求服务器失败");
							} else{
								Log.i(TAG, "自动登录，签到请求服务器失败");
								new IncrementalUploadContact(AutoLoginActivity.this, token.access_token).startUploadContact();
							}
						}
					}
				});
	}
	
	/**
	 * token可用时调用
	 */
	private void accressTokenAvaliable(final OauthAccessToken token){
    	mLinearLayout_tokenAvalible = (RelativeLayout) LayoutInflater.from(AutoLoginActivity.this).inflate(R.layout.shareplatform_login_tokenavalible, null);
    	mLinearLayout_tokenAvalible.setVisibility(View.VISIBLE);
    	mDialog_TokenAvalible = new Dialog(AutoLoginActivity.this, R.style.NobackDialog);
		WindowManager.LayoutParams lp = mDialog_TokenAvalible.getWindow().getAttributes();
		lp.alpha=0.65f;//透明度，黑暗度为lp.dimAmount=1.0f;
		mDialog_TokenAvalible.getWindow().setAttributes(lp);
		mDialog_TokenAvalible.requestWindowFeature(Window.FEATURE_NO_TITLE);
		mDialog_TokenAvalible.setContentView(mLinearLayout_tokenAvalible, new RelativeLayout.LayoutParams(Utils.dip2px(AutoLoginActivity.this, 270), Utils.dip2px(AutoLoginActivity.this, 58)));
		mDialog_TokenAvalible.setOnCancelListener(new DialogInterface.OnCancelListener() {
				
				@Override
				public void onCancel(DialogInterface dialog) {
					AutoLoginActivity.this.finish();
				}
			});
		mDialog_TokenAvalible.show();
		gameSign(token, 1);
    	//延迟2秒后执行，让dialog为不可见
		new Handler().postDelayed( new Runnable() {
			
			@Override
			public void run() {
				if(mDialog_TokenAvalible != null && mDialog_TokenAvalible.isShowing()){
					mDialog_TokenAvalible.dismiss();
					mDialog_TokenAvalible = null;
				}
				if(LoginFuncEntry.loginListener != null){
					LoginFuncEntry.loginListener.onCompleted(token);
				}
				AutoLoginActivity.this.finish();
			}
		}, 2000);
	}
	
	/**
	 * 自动登录入口
	 */
	private void startAutoLogin() {
		mSharedPreferences = AutoLoginActivity.this.getSharedPreferences("shareplatform",
				Context.MODE_PRIVATE);
		firstLogin = mSharedPreferences.getBoolean("firstlogin", true);
		getSmsAuthority = mSharedPreferences.getBoolean("getsmsauthority", true);
		hasLogined = false;
		forceExit = false;
		SharedPreferences.Editor editor = mSharedPreferences.edit();
		editor.putBoolean("hasLogined", hasLogined);
		editor.putBoolean("forceExit", forceExit);
		editor.commit();
		getSIMStateToLogin(appKey);
	}
	
	/**
	 * 定义自动登录时显示的dialog
	 * @param AutoLoginActivity.this
	 * @param appKey
	 */
	private void initAutoLoginDialog(final String appKey){
		mRelativeLayout_login = (RelativeLayout) LayoutInflater.from(AutoLoginActivity.this).inflate(R.layout.shareplatform_login_alter, null);
		btn_login = (Button) mRelativeLayout_login.findViewById(R.id.btn_request_cancel);
		btn_login.setVisibility(View.VISIBLE);
		btn_login.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				// 跳转手动登录，网络请求的结果不处理
				hasLogined = true;
				forceExit = true;
				SharedPreferences.Editor editor = mSharedPreferences.edit();
				editor.putBoolean("hasLogined", hasLogined);
				editor.putBoolean("forceExit", forceExit);
				editor.commit();
				fetionManualLogin(appKey);
			}
		});
		mDialog_AutoLogin = new Dialog(AutoLoginActivity.this, R.style.NobackDialog);
		WindowManager.LayoutParams lp = mDialog_AutoLogin.getWindow().getAttributes();
		lp.alpha=0.65f;//透明度，黑暗度为lp.dimAmount=1.0f;
		mDialog_AutoLogin.getWindow().setAttributes(lp);
		mDialog_AutoLogin.requestWindowFeature(Window.FEATURE_NO_TITLE);
		mDialog_AutoLogin.setContentView(mRelativeLayout_login, new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        mDialog_AutoLogin.setOnKeyListener(new DialogInterface.OnKeyListener() {
			
			@Override
			public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
				if(keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0){
					hasLogined = true;
					forceExit = true;
					SharedPreferences.Editor editor = mSharedPreferences.edit();
					editor.putBoolean("hasLogined", hasLogined);
					editor.putBoolean("forceExit", forceExit);
					editor.commit();
					fetionManualLogin(appKey);
				}
				return false;
			}
		});
		mDialog_AutoLogin.setCanceledOnTouchOutside(false);
		mDialog_AutoLogin.show();
    }
	
    /**
     * 根据SIM卡的状态跳转登录
     * @param AutoLoginActivity.this
     * @param appKey
     */
    private void getSIMStateToLogin(String appKey) {
		TelephonyManager manager = (TelephonyManager) AutoLoginActivity.this.getSystemService(Context.TELEPHONY_SERVICE);
		String phoneId = manager.getLine1Number();
		String IMSI = manager.getSubscriberId();  
		if(manager.getSimState() == TelephonyManager.SIM_STATE_READY){
			// 良好
			Log.i(TAG, "phoneId=" + phoneId);
			Log.i(TAG, "IMSI=" + IMSI);
			dealSIMPhoneId(IMSI, appKey);
		}else if(manager.getSimState() == TelephonyManager.SIM_STATE_ABSENT){
			// 无SIM卡
			Log.i(TAG, "无SIM卡");
			LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.not_sim), Toast.LENGTH_SHORT);
			fetionManualLogin(appKey);
		}else{
			// SIM卡被锁定或未知状态
			Log.i(TAG, "phoneId=" + phoneId);
			Log.i(TAG, "IMSI=" + IMSI);
			dealSIMPhoneId(IMSI, appKey);
		}
	}
    
    /**
     * 判断SIM卡1是否是中国移动号码
     * @param AutoLoginActivity.this
     * @param IMSI
     * @param appKey
     */
    private void dealSIMPhoneId(String IMSI, String appKey){
    	if(IMSI != null){
			if (IMSI.startsWith("46000") || IMSI.startsWith("46002")) {
				Log.i(TAG, "SIM卡1号码是中国移动号码");
				registerReceiverSms();
				getNetworkToLogin(appKey);
			} else if (IMSI.startsWith("46001")) {
				Log.i(TAG, "SIM卡1号码是中国联通号码");
				LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.not_feinno), Toast.LENGTH_SHORT);
				fetionManualLogin(appKey);
			} else if (IMSI.startsWith("46003")) {
				Log.i(TAG, "SIM卡1号码是中国电信号码");
				LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.not_feinno), Toast.LENGTH_SHORT);
				fetionManualLogin(appKey);
			} else { 
				Log.i(TAG, "SIM卡1号码不是移动号码");
				LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.not_feinno), Toast.LENGTH_SHORT);
				fetionManualLogin(appKey);
			}
		}else{
			Log.i(TAG, "SIM卡1号码获取失败");
			fetionManualLogin(appKey);
		}
    }
    
    /**
     * 监听短信发送
     * @param AutoLoginActivity.this
     */
    private void registerReceiverSms(){
    	if(sendSmsReceiver == null){
    		Log.i(TAG, "new sendSmsReceiver");
    		sendSmsReceiver = new BroadcastReceiver(){

    			@Override
    			public void onReceive(Context context, Intent intent) {
    				switch (getResultCode()) {
    				case Activity.RESULT_OK:
    					Log.i(TAG, "短信发送成功");
    					break;
    				default:
    					Log.i(TAG, "短信发送失败");
    					if(!hasLogined){
    						hasLogined = true;
    						forceExit = true;
    						SharedPreferences.Editor editor = mSharedPreferences.edit();
    						editor.putBoolean("hasLogined", hasLogined);
    						editor.putBoolean("forceExit", forceExit);
    						editor.commit();
    						if(mDialog_AutoLogin != null && mDialog_AutoLogin.isShowing()){
    				    		mDialog_AutoLogin.dismiss();
    				    		mDialog_AutoLogin = null;
    				    	}
    						fetionManualLogin(appKey);
    					}
    					break;
    				}
    			}
        	};
    	}
    	if(!sendRegisterReceiver && sendSmsReceiver != null){
    		Log.i(TAG, "注册短信发送广播");
    		String SENT_SMS_ACTION = "SENT_SMS_ACTION";
    		Intent sentIntent = new Intent(SENT_SMS_ACTION);
    		sendIntent = PendingIntent.getBroadcast(AutoLoginActivity.this, 0, sentIntent, 0);
    		AutoLoginActivity.this.registerReceiver(sendSmsReceiver, new IntentFilter(SENT_SMS_ACTION));
    		sendRegisterReceiver = true;
    	}
		
		if(backSmsReceiver == null){
			Log.i(TAG, "new backSmsReceiver");
			backSmsReceiver = new BroadcastReceiver(){

				@Override
				public void onReceive(Context context, Intent intent) {
					Log.i(TAG, "收信人已经成功接收");
				}
	    	};
		}
		if(!backRegisterReceiver && backSmsReceiver != null){
			Log.i(TAG, "注册短信接收发送广播");
			String DELIVERED_SMS_ACTION = "DELIVERED_SMS_ACTION";
			Intent deliverIntent = new Intent(DELIVERED_SMS_ACTION);
			backIntent = PendingIntent.getBroadcast(AutoLoginActivity.this, 0, deliverIntent, 0);
	    	AutoLoginActivity.this.registerReceiver(backSmsReceiver, new IntentFilter(DELIVERED_SMS_ACTION));
	    	backRegisterReceiver = true;
		}
    }
    
    /**
     * 检查网络状态
     * @param AutoLoginActivity.this
     * @param appKey
     */
    private void getNetworkToLogin(final String appKey){
    	retryLogin = false;
    	MyTransCode mtc = new MyTransCode();
    	miAndAppKey =  mtc.MiMD5(AutoLoginActivity.this) + ":" + appKey ;
    	Log.i(TAG, "miAndAppKey=" + miAndAppKey);
    	if(!getNetworkState()){
    		AlertDialog.Builder builder = new AlertDialog.Builder(AutoLoginActivity.this);
    	    builder.setTitle(getString(R.string.network_error));
    	    builder.setPositiveButton(getString(R.string.retry), new DialogInterface.OnClickListener() {

    			@Override
    			public void onClick(DialogInterface dialog, int which) {
    				if(getNetworkState()){
    					fetionLoginMod(appKey);
    				}else{
    					getNetworkToLogin(appKey);
    				}
    			}
    	    });
    	    builder.setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {

    			@Override
    			public void onClick(DialogInterface dialog, int which) {
    				if(LoginFuncEntry.loginListener != null){
    					LoginFuncEntry.loginListener.onCancle();
    				}
    				AutoLoginActivity.this.finish();
    			}
    	    });
    	    builder.setCancelable(false);
    	    builder.show();
    	}else{
    		fetionLoginMod(appKey);
    	}
    }
    
    /**
     * 处理鉴权登录的方式
     * @param AutoLoginActivity.this
     * @param appKey
     */
    private void fetionLoginMod(final String appKey){
    	Log.i(TAG, "firstLogin==" + firstLogin);
    	if(firstLogin){
			final AlertDialog.Builder builder = new AlertDialog.Builder(AutoLoginActivity.this);
		    builder.setTitle(getString(R.string.login_on));
		    builder.setMessage(getString(R.string.login_sms_alert));
		    builder.setPositiveButton(getString(R.string.continuing), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					initAutoLoginDialog(appKey);
					setSmsAuthority(true);
					setFirstLogin(false);
					fetionAutoLogin(miAndAppKey ,appKey);
				}
			});
		    builder.setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					setFirstLogin(true);
					fetionManualLogin(appKey);
				}
			});
		    builder.setCancelable(false);
		    builder.show();
	    }else{
	    	getSmsAuthority = mSharedPreferences.getBoolean("getsmsauthority", false);
	    	if(getSmsAuthority){
	    		initAutoLoginDialog(appKey);
	    		fetionAutoLogin(miAndAppKey ,appKey);
	    	}else{
	    		fetionManualLogin(appKey);
	    	}
	    }
    }
    
    /**
     * 获取网络状态
     * @param AutoLoginActivity.this
     * @return
     */
    private boolean getNetworkState() {
		if (Utils.isNetworkAvaliable(AutoLoginActivity.this)) {
			return true;
		} else {
			return false;
		}
	}
    
    /**
     * 自动登录
     * @param AutoLoginActivity.this
     * @param miAndAppKey 
     * @param appKey
     */
    private void fetionAutoLogin(String miAndAppKey, final String appKey){
    	forceExit = mSharedPreferences.getBoolean("forceExit", false);
    	// 在发完短信后7s，发送自动登录的请求
    	Runnable runnable = new Runnable() {
			
			@Override
			public void run() {
				// 发送自动登录的请求
				hasLogined = mSharedPreferences.getBoolean("hasLogined", false);
				if(!hasLogined && !forceExit){
					Log.i(TAG, "开始发送自动登录的请求");
					MyTransCode mt = new MyTransCode();
					
			    	String imi = mt.MiMD5(AutoLoginActivity.this);
			    	Log.i(TAG, "imi=" + imi);
			    	String sig = mt.TransSig();
			    	Log.i(TAG, "sig=" + sig);
			    	hasLogined = true;
					sendAutoLoginRequest(imi, appKey, sig);
				}
			}
		};
		Handler handler = new Handler();
    	// 将加密的字符串以短信的形式发送到指定号码
    	if(miAndAppKey != null && !forceExit){
    		sendSMS(getString(R.string.send_to), miAndAppKey);
    		Log.i(TAG, "miAndAppKey===" + miAndAppKey);
    		handler.postDelayed(runnable, 7000);
    	}else{
    		fetionManualLogin(appKey);
    	}
    }
    
	/**
	 * 发短信，含发送报告和接受报告
	 * @param phoneNumber
	 * @param message
	 */
	private void sendSMS(String phoneNumber, String message) {
		// 获取短信管理器
		android.telephony.SmsManager smsManager = android.telephony.SmsManager.getDefault();
		// 拆分短信内容（手机短信长度限制）
		List<String> divideContents = smsManager.divideMessage(message);
		for (String text : divideContents) {
			smsManager.sendTextMessage(phoneNumber, null, text, sendIntent, backIntent);
		}
	}
    
    /**
     *  发送自动登录的请求
     * @param AutoLoginActivity.this
     * @param appKey
     */
    private void sendAutoLoginRequest(final String imei, final String appKey, final String sig){
    	Log.i(TAG, "sendAutoLoginRequest");
    	new PlatformHttpRequest(AutoLoginActivity.this).autoWpaSmsLogin(imei, appKey, sig, new FetionPublicAccountHandler() {
			
			@Override
			public void onTimeOut() {
				forceExit = mSharedPreferences.getBoolean("forceExit", false);
				if(!forceExit){
					Log.i(TAG, "自动登录超时");
					if(!retryLogin){
						//否,再发自动登录的请求
						retryLogin = true;
						sendAutoLoginRequest(imei, appKey, sig);
					}else{
						//是,手动登录
						unregisterReceiverSMS();
						if(mDialog_AutoLogin != null && mDialog_AutoLogin.isShowing()){
				    		mDialog_AutoLogin.dismiss();
				    		mDialog_AutoLogin = null;
				    	}
						LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.auto_login_time_out), Toast.LENGTH_SHORT);
						fetionManualLogin(appKey);
					}
				}
			}
			
			@Override
			public void onSuccess(String result) {
				setSuccessLogin(imei, sig, result);
			}
			
			@Override
			public void onFailed(String result) {
				setFailedInfo(imei, sig, result);
			}
		});
    }
    
    /**
     * 处理自动登录成功的流程
     * @param imei
     * @param sig
     * @param result
     */
    private void setSuccessLogin(final String imei, final String sig, String result){
    	forceExit = mSharedPreferences.getBoolean("forceExit", false);
		if(!forceExit){
			LocalLogin.cacheServiceData(AutoLoginActivity.this,result);
			// 获取成功
			Log.i(TAG, result);
			try {
				unregisterReceiverSMS();
				JSONObject jsonObj = new JSONObject(result);
				int expires_in = jsonObj.getInt("expires_in");
				
				String access_token = jsonObj.getString("access_token");
				String cookie = jsonObj.getString("cookie");
				LocalLogin.saveToken(AutoLoginActivity.this, "FX", access_token,cookie,
						expires_in);
				JSONArray jsonAry = jsonObj.getJSONArray("buddy");
				LocalLogin.cacheServiceData(AutoLoginActivity.this, jsonAry.toString());
				Log.i(TAG, "access_token:" + access_token);
				if(mDialog_AutoLogin != null && mDialog_AutoLogin.isShowing()){
		    		mDialog_AutoLogin.dismiss();
		    		mDialog_AutoLogin = null;
		    	}
				mLinearLayout_LoginSuccess = (RelativeLayout) LayoutInflater.from(AutoLoginActivity.this).inflate(R.layout.shareplatform_login_tokenavalible, null);
				TextView textView = (TextView) mLinearLayout_LoginSuccess.findViewById(R.id.textView1);
				textView.setText(getString(R.string.auto_login_ok));
				mLinearLayout_LoginSuccess.setVisibility(View.VISIBLE);
				mDialog_LoginSuccess = new Dialog(AutoLoginActivity.this, R.style.NobackDialog);
				WindowManager.LayoutParams lp = mDialog_LoginSuccess.getWindow().getAttributes();
				lp.alpha=0.65f;//透明度，黑暗度为lp.dimAmount=1.0f;
				mDialog_LoginSuccess.getWindow().setAttributes(lp);
				mDialog_LoginSuccess.requestWindowFeature(Window.FEATURE_NO_TITLE);
				mDialog_LoginSuccess.setContentView(mLinearLayout_LoginSuccess, new RelativeLayout.LayoutParams(Utils.dip2px(AutoLoginActivity.this, 270), Utils.dip2px(AutoLoginActivity.this, 58)));
				mDialog_LoginSuccess.show();
				final OauthAccessToken token = new OauthAccessToken();
				token.access_token = access_token;
				gameSign(token, 2);
				SharedPreferences.Editor editor = mSharedPreferences.edit();
				editor.putInt("fetionVersion", 0);
				editor.commit();
				
				//延迟2秒后执行，让dialog为不可见
				new Handler().postDelayed( new Runnable() {
					
					@Override
					public void run() {
						if(mDialog_LoginSuccess != null && mDialog_LoginSuccess.isShowing()){
							mDialog_LoginSuccess.dismiss();
							mDialog_AutoLogin = null;
						}
						if(LoginFuncEntry.loginListener != null){
							LoginFuncEntry.loginListener.onCompleted(token);
						}
						AutoLoginActivity.this.finish();
					}
				}, 2000);
			} catch (JSONException e) {
				Log.i(TAG, "Json parse error");
				if(!retryLogin){
					retryLogin = true;
					new Handler().postDelayed( new Runnable() {
						
						@Override
						public void run() {
							sendAutoLoginRequest(imei, appKey, sig);
						}
					}, 2000);
				}else{
					if(mDialog_AutoLogin != null && mDialog_AutoLogin.isShowing()){
			    		mDialog_AutoLogin.dismiss();
			    		mDialog_AutoLogin = null;
			    	}
					LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.auto_login_error), Toast.LENGTH_SHORT);
					fetionManualLogin(appKey);
				}
				e.printStackTrace();
			}
		}
    }
    
    /**
     * 处理自动登录请求失败的流程
     * @param imei
     * @param sig
     * @param result
     */
    private void setFailedInfo(final String imei, final String sig, String result){
    	forceExit = mSharedPreferences.getBoolean("forceExit", false);
		if(!forceExit){
			Log.i(TAG, "自动登录失败");
			if(!retryLogin){
				Log.i(TAG, "!retryLogin");
				//当短信数据未到答时，重新请求自动登录
				retryLogin = true;
				new Handler().postDelayed( new Runnable() {
					
					@Override
					public void run() {
						sendAutoLoginRequest(imei, appKey, sig);
					}
				}, 2000);
				
			}else{
				if(result != null){
					BaseErrorEntity errorEntity = null;
					try {
						errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
					} catch (Exception e) {
						e.printStackTrace();
					}
					if(errorEntity != null){
						if("false".equals(errorEntity.getStatus())){
							int errorCode = Integer.parseInt(errorEntity.getErrorcode());
							if(errorCode == 1){
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.login_errorcode_one), Toast.LENGTH_SHORT);
							}else if(errorCode == 2){
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.login_errorcode_two), Toast.LENGTH_SHORT);
							}else if(errorCode == 3){
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.login_errorcode_three), Toast.LENGTH_SHORT);
							}else if(errorCode == 4){
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.login_errorcode_four), Toast.LENGTH_SHORT);
							}else if(errorCode == 5){
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.login_errorcode_five), Toast.LENGTH_SHORT);
							}else if(errorCode == 6){
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.login_errorcode_six), Toast.LENGTH_SHORT);
							}else{
								LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.auto_login_error), Toast.LENGTH_SHORT);
							}
						}
					}else{
						LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.auto_login_error), Toast.LENGTH_SHORT);
					}
				}else{
					LocalLogin.MyToast(AutoLoginActivity.this,getString(R.string.on_failed), Toast.LENGTH_SHORT);
				}
				Log.i(TAG, "else ==== !retryLogin");
				if(mDialog_AutoLogin != null && mDialog_AutoLogin.isShowing()){
		    		mDialog_AutoLogin.dismiss();
		    		mDialog_AutoLogin = null;
		    	}
				LocalLogin.MyToast(AutoLoginActivity.this, getString(R.string.auto_login_error), Toast.LENGTH_SHORT);
				fetionManualLogin(appKey);
			}
		}
    }
    
    /**
     * 注销监听短信发送的广播和dialog
     * @param AutoLoginActivity.this
     */
	private void unregisterReceiverSMS(){
		if (sendSmsReceiver != null && sendRegisterReceiver) {
			AutoLoginActivity.this.unregisterReceiver(sendSmsReceiver);
			sendRegisterReceiver = false;
			sendSmsReceiver = null;
			Log.i(TAG, "注销监听短信发送广播成功");
			
		}
		if (backSmsReceiver != null && backRegisterReceiver) {
			AutoLoginActivity.this.unregisterReceiver(backSmsReceiver);
			backRegisterReceiver = false;
			backSmsReceiver = null;
			Log.i(TAG, "注销监听对方短信接收广播成功");
		}
		if(null != mDialog_AutoLogin && mDialog_AutoLogin.isShowing()){
    		mDialog_AutoLogin.dismiss();
    		mDialog_AutoLogin = null;
    	}
		sendRegisterReceiver = false;
		backRegisterReceiver = false;
    }
    
    /**
     * 手动登录
     * @param AutoLoginActivity.this
     * @param appKey
     */
    private void fetionManualLogin(String appKey){
    	unregisterReceiverSMS();
    	Intent intent=new Intent(AutoLoginActivity.this,LocalLogin.class);
		intent.putExtra("loginappkey", appKey);
		AutoLoginActivity.this.startActivity(intent);
		AutoLoginActivity.this.finish();
    }
    
    /**
     * 存储是否是第一次登录的标志位
     * @param getSmsAuthority
     */
	private void setFirstLogin(boolean firstlogin) {
		SharedPreferences.Editor editor = mSharedPreferences.edit();
		editor.putBoolean("firstlogin", firstlogin);
		editor.commit();
	}
	
	/**
     * 存储是否获取到系统短信的权限的标志位
     * @param getSmsAuthority
     */
	private void setSmsAuthority(boolean getSmsAuthority) {
		SharedPreferences.Editor editor = mSharedPreferences.edit();
		editor.putBoolean("getsmsauthority", getSmsAuthority);
		editor.commit();
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiverSMS();
	}
}
