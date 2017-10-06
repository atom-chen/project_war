package com.fetion.shareplatform.func.login;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.database.Cursor;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Environment;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;
import android.widget.Toast;

import com.example.strans.MyTransCode;
import com.fetion.shareplatform.R;
import com.fetion.shareplatform.db.TokensDB;
import com.fetion.shareplatform.json.handle.FetionErrorHandler;
import com.fetion.shareplatform.json.handle.FetionPublicAccountHandler;
import com.fetion.shareplatform.model.BaseErrorEntity;
import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.network.PlatformHttpRequest;
import com.fetion.shareplatform.util.IncrementalUploadContact;
import com.fetion.shareplatform.util.Utils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class LocalLogin extends Activity {
	private static String TAG = LocalLogin.class.getSimpleName();
	//最外层布局
	private RelativeLayout mRelativeLayout_outer;
	//鉴权的主界面
	private LinearLayout mLinearLayout_login;
	// 第一页验证码
	private EditText code;
	// 第一页手机号，账号
	private EditText phone;
	private TimeCount time;
	// 授权登录按钮
	private Button btn_login;
	// 获取验证码
	private TextView getcode;
	private Dialog mDialog_AutoLogin = null;
	// 取消按钮
	private Button btn_cancel;
	private String client_id;
	private static int temp_id;
	private OauthAccessToken token = new OauthAccessToken();
	private Dialog dialog;

	private String sms_account = null;
	private String sms_code = null;

	private boolean sms_account_focus = false;
	private boolean sms_code_focus = false;
	private final int LOGIN_SMS = 0;
	private final int LOGIN_ACC = 1;
	private int login_way = LOGIN_SMS;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		client_id = this.getIntent().getStringExtra("loginappkey");
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.shareplatform_locallogin);
		getWindow().setSoftInputMode(
				WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
		initwidgetView();
		setWidgetListener();
	}

	public void onConfigurationChanged(Configuration newConfig) {
		// 一定要先调用父类的同名函数，让框架默认函数先处理
		super.onConfigurationChanged(newConfig);

		// 检测屏幕的方向：纵向或横向
		if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
			// 当前为横屏， 在此处添加额外的处理代码
			setContentView(R.layout.shareplatform_locallogin);
			initwidgetView();
			setWidgetListener();
			Log.i(TAG, "code=" + sms_code_focus + sms_account_focus);
			if (sms_account_focus) {
				phone.setFocusable(true);
				phone.setFocusableInTouchMode(true);
				phone.requestFocus();
				phone.requestFocusFromTouch();
			} else if (sms_code_focus) {
				code.setFocusable(true);
				code.setFocusableInTouchMode(true);
				code.requestFocus();
				code.requestFocusFromTouch();
			}
		} else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
			// 当前为竖屏， 在此处添加额外的处理代码
			setContentView(R.layout.shareplatform_locallogin);
			initwidgetView();
			setWidgetListener();
			Log.i(TAG, "code=" + sms_code_focus + sms_account_focus);
			if (sms_account_focus) {
				phone.setFocusable(true);
				phone.setFocusableInTouchMode(true);
				phone.requestFocus();
				phone.requestFocusFromTouch();
			} else if (sms_code_focus) {
				code.setFocusable(true);
				code.setFocusableInTouchMode(true);
				code.requestFocus();
				code.requestFocusFromTouch();
			}
		}
		// 检测实体键盘的状态：推出或者合上
		if (newConfig.hardKeyboardHidden == Configuration.HARDKEYBOARDHIDDEN_NO) {
			// 实体键盘处于推出状态，在此处添加额外的处理代码
		} else if (newConfig.hardKeyboardHidden == Configuration.HARDKEYBOARDHIDDEN_YES) {
			// 实体键盘处于合上状态，在此处添加额外的处理代码
		}
	}

	private void initwidgetView() {
		mRelativeLayout_outer = (RelativeLayout) findViewById(R.id.shareplatform_locallogin_background_id);
		mLinearLayout_login = (LinearLayout) findViewById(R.id.shareplatform_locallogin_view_id);
		code = (EditText) findViewById(R.id.shareplatform_locallogin_sms_code_id);
		code.addTextChangedListener(new MyTextWatcher(1));
		if (sms_code != null) {
			code.setText(sms_code);
			code.setSelection(sms_code.length());
		}
		phone = (EditText) findViewById(R.id.shareplatform_locallogin_sms_phonenumber_id);
		phone.addTextChangedListener(new MyTextWatcher(2));
		if (sms_account != null) {
			phone.setText(sms_account);
			phone.setSelection(sms_account.length());
		}
		btn_login = (Button) findViewById(R.id.shareplatform_locallogin_sms_login_btn_id);
		getcode = (TextView) findViewById(R.id.shareplatform_locallogin_sms_getcode_id);
		btn_cancel = (Button) findViewById(R.id.shareplatform_locallogin_cancel_id);
	}

	private class MyTextWatcher implements TextWatcher {
		int edeitId = 1;

		public MyTextWatcher(int id) {
			edeitId = id;
		}

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
			switch (edeitId) {
			case 1:
				String select = code.getText().toString();
				Log.i(TAG, "select=====" + select);
				if (select.length() > 0) {
					sms_code = select;
				} else {
					sms_code = null;
				}
				break;
			case 2:
				String select1 = phone.getText().toString();
				Log.i(TAG, "select1=====" + select1);
				if (select1.length() > 0) {
					sms_account = select1;
				} else {
					sms_account = null;
				}
				break;
			}
		}
	}

	private void setWidgetListener() {
		code.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View arg0, MotionEvent arg1) {
				sms_code_focus = true;
				sms_account_focus = false;
				Log.i(TAG, "code=" + sms_code_focus + sms_account_focus);
				return false;
			}
		});
		phone.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View arg0, MotionEvent arg1) {
				sms_account_focus = true;
				sms_code_focus = false;
				Log.i(TAG, "phone=" + sms_code_focus + sms_account_focus);
				return false;
			}
		});
		phone.setOnEditorActionListener(new OnEditorActionListener() {

			@Override
			public boolean onEditorAction(TextView v, int actionId,
					KeyEvent event) {
				if (actionId == EditorInfo.IME_ACTION_NEXT) {
					sms_code_focus = true;
					sms_account_focus = false;
				}
				return false;
			}
		});
		code.setOnEditorActionListener(new OnEditorActionListener() {

			@Override
			public boolean onEditorAction(TextView v, int actionId,
					KeyEvent event) {
				if (actionId == EditorInfo.IME_ACTION_NEXT) {
					sms_code_focus = false;
					sms_account_focus = false;
				}
				return false;
			}
		});
		/*mRelativeLayout_outer.setOnTouchListener(new View.OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(LoginFuncEntry.loginListener != null){
					LoginFuncEntry.loginListener.onCancle();
				}
				LocalLogin.this.finish();
				return false;
			}
		});*/
		mLinearLayout_login.setOnTouchListener(new View.OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				return true;
			}
		});

		getcode.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				if (checkPhoneNumber(phone)) {
					getSmsCode();
				} else {
				}
			}
		});
		
		btn_login.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				if (checkPhoneNumber(phone) && checkcode(code)) {
					// dialog.show();
					getLoginByCode();
				} else {

				}
			}
		});
		btn_cancel.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				if(LoginFuncEntry.loginListener != null){
					LoginFuncEntry.loginListener.onCancle();
				}
				finish();
			}
		});
		// 为获取验证码加入倒计时
		time = new TimeCount(60000, 1000);
		// 设置输入框最大文字数
		phone.setFilters(new InputFilter[] { new InputFilter.LengthFilter(11) });
		code.setFilters(new InputFilter[] { new InputFilter.LengthFilter(6) });
	}

	private void setGetCode( boolean isEnable){
		getcode.setClickable(isEnable);
		getcode.setEnabled(isEnable);
		
		if(isEnable){
			getcode.setTextColor(0xff138fe0);
		}else{
			getcode.setTextColor(0xffaaaaaa);
		}
	}
	private boolean isNumeric(String str) {
		for (int i = str.length(); --i >= 0;) {
			int chr = str.charAt(i);
			if (chr < 48 || chr > 57)
				return false;
		}
		return true;
	}

	private boolean checkcode(EditText editcode) {
		if (editcode.getText().toString().trim().length() > 0) {
			return true;
		} else {
			MyToast(this, getString(R.string.locallogin_code_null), Toast.LENGTH_SHORT);
			return false;
		}
	}

	private boolean checkPhoneNumber(EditText editPhone) {
		if (editPhone.getText().toString().trim().length() == 0) {
			MyToast(this, getString(R.string.locallogin_phone_null), Toast.LENGTH_SHORT);
			return false;
		} else {
			if (editPhone.getText().toString().trim().length() < 11) {
				MyToast(this, getString(R.string.locallogin_phone_lengtherror), Toast.LENGTH_SHORT);
				return false;
			} else {
				if (Utils.checkPhone(editPhone.getText().toString().trim())) {
					// 验证通过
					return true;
				} else {
					MyToast(this, getString(R.string.locallogin_getcode_errorothree), Toast.LENGTH_SHORT);
					return false;
				}
			}
		}
	}

	private boolean checkMain(String s) {

		boolean b = false;
		if (s.contains("@") && s.contains(".")) {
			int no1 = s.indexOf("@");
			int no2 = s.indexOf(".");
			int max = s.length();
			if (no2 > no1 && no2 > 1 && no2 - 1 > no1 && no2 != max - 1) {
				b = true;
				for (int i = 0; i < s.length(); i++) {
					if (String.valueOf(s.charAt(i)).getBytes().length == 2) {
						b = false;
						break;
					}
				}
				return b;
			}
		}
		return b;

	}

	class TimeCount extends CountDownTimer {
		public TimeCount(long millisInFuture, long countDownInterval) {
			super(millisInFuture, countDownInterval);
		}

		@Override
		public void onFinish() {
			getcode.setText("获取验证码");
			setGetCode(true);
//			getcode.setClickable(true);
//			getcode.setEnabled(true);
		}

		@Override
		public void onTick(long millisUntilFinished) {
			setGetCode(false);
//			getcode.setClickable(false);
//			getcode.setEnabled(false);
			getcode.setText("重新获取(" + millisUntilFinished / 1000 + ")");
		}
	}

	public void hideSoftInputFromWindow(Context context) {
		if (null != ((Activity) context).getCurrentFocus()) {
			((InputMethodManager) context
					.getSystemService(context.INPUT_METHOD_SERVICE))
					.hideSoftInputFromWindow(((Activity) context)
							.getCurrentFocus().getWindowToken(),
							InputMethodManager.HIDE_NOT_ALWAYS);
		}
	}

	public static void MyToast(Context context, String str, int longer) {
		Toast toast = Toast.makeText(context, str, longer);
		toast.setGravity(Gravity.CENTER, 0, 0);
		toast.show();
	}

	public static void cacheServiceData(final Context context, final String result) {
		if (result != null && !result.toLowerCase().contains("\"error:\"")) {
			File file = null;
			if (Environment.getExternalStorageState().equals(
					android.os.Environment.MEDIA_MOUNTED)) {
				File path = Environment.getExternalStorageDirectory();
				file = new File(path, "fetion.txt");
			} else {
				File path = context.getCacheDir();
				file = new File(path, "fetion.txt");
			}
			file.deleteOnExit();
			try {
				file.createNewFile();
			} catch (IOException e) {
				e.printStackTrace();
			}
			try {
				FileOutputStream fos = new FileOutputStream(file);
				fos.write(result.getBytes());
				fos.flush();
				fos.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			Log.i(TAG, "result is null");
		}
	}

	public static void saveToken(Context context, String appName, String token,String cookie,
			int expiresTime) {
		SimpleDateFormat sDateFormat = new SimpleDateFormat(
				"yyyy-MM-dd hh:mm:ss");
		String date = sDateFormat.format(new java.util.Date());
		// 向数据库添加或者修改token信息
		if (selectTokenByAppName(context, appName)) {
			// 已经拥有token做修改操作
			TokensDB db = TokensDB.getInstance(context);
			db.update(temp_id, "", token, cookie, expiresTime, date, appName);
			db.close();
		} else {
			// 新增token信息
			TokensDB db = TokensDB.getInstance(context);
			long num = db.insert("", token, cookie, expiresTime, date, appName);
			if (num >= 0) {
				Log.i(TAG, "token新增到数据库完成");
			}
			db.close();
		}
	}

	public static boolean selectTokenByAppName(Context context, String appName) {
		Log.i(TAG, "准备查询获取cursor");
		TokensDB db = TokensDB.getInstance(context);
		Cursor cursor = db.select();
		if (cursor.getCount() == 0) {
			Log.i(TAG, "cursor内没有数据");
		} else {
			// 循环遍历cursor
			while (cursor.moveToNext()) {
				if (appName.equals(cursor.getString(5))) {
					temp_id = cursor.getInt(0);
					return true;
				}
			}
		}
		cursor.close();
		db.close();
		return false;
	}

	private void getSmsCode() {
		LinearLayout mLinearLayout_LoginSuccess = (LinearLayout) LayoutInflater.from(LocalLogin.this).inflate(R.layout.shareplatform_login_request, null);
		TextView textView = (TextView) mLinearLayout_LoginSuccess.findViewById(R.id.textView1);
//		getcode.setClickable(false);
//		getcode.setEnabled(false);
		setGetCode(false);
		textView.setText(getString(R.string.get_code));
		mLinearLayout_LoginSuccess.setVisibility(View.VISIBLE);
		dialog = new Dialog(LocalLogin.this, R.style.NobackDialog);
		WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
		lp.alpha=0.65f;//透明度，黑暗度为lp.dimAmount=1.0f;
		dialog.getWindow().setAttributes(lp);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(mLinearLayout_LoginSuccess, new RelativeLayout.LayoutParams(Utils.dip2px(LocalLogin.this, 270), Utils.dip2px(LocalLogin.this, 52)));
		dialog.show();
		
		if (Utils.isNetworkAvaliable(LocalLogin.this)) {
			new PlatformHttpRequest(LocalLogin.this).getcode(phone.getText()
					.toString().trim(), new FetionPublicAccountHandler() {

				@Override
				public void onTimeOut() {
					dialog.dismiss();
					setGetCode(true);
//					getcode.setClickable(true);
//					getcode.setEnabled(true);
					MyToast(LocalLogin.this, getString(R.string.on_time_out), Toast.LENGTH_SHORT);
				}

				@Override
				public void onSuccess(String result) {
					// 获取成功
					dialog.dismiss();
					Log.i(TAG, result);
					if(result != null){
						MyToast(LocalLogin.this, getString(R.string.code_is_send), Toast.LENGTH_SHORT);
						time.start();
					}else{
						setGetCode(true);
						Log.i(TAG, "onSuccess 获取验证码失败");
						MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_failed), Toast.LENGTH_SHORT);
					}
				}

				@Override
				public void onFailed(String result) {
//					getcode.setClickable(true);
//					getcode.setEnabled(true);
					setGetCode(true);
					dialog.dismiss();
					if(result != null){
						BaseErrorEntity errorEntity = null;
						try {
							errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
							if(errorEntity != null){
								if("false".equals(errorEntity.getStatus())){
									int errorCode = Integer.parseInt(errorEntity.getErrorcode());
									Log.i(TAG, "errorCode =="+ errorCode);
									if(errorCode == 1502){
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_errorone), Toast.LENGTH_SHORT);
									}else if(errorCode == 1102){
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_errortwo), Toast.LENGTH_SHORT);
									}else if(errorCode == 1){
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_errorothree), Toast.LENGTH_SHORT);
									}else if(errorCode == 1101){
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_errorfour), Toast.LENGTH_SHORT);
									}else if(errorCode == 1501){
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_errorfive), Toast.LENGTH_SHORT);
									}else if(errorCode == 1503){
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_errorsix), Toast.LENGTH_SHORT);
									}else{
										MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_failed), Toast.LENGTH_SHORT);
									}
								}
							}else{
								Log.i(TAG, "errorEntity == null");
								MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_failed), Toast.LENGTH_SHORT);
							}
						} catch (Exception e) {
							Log.i(TAG, "onFailed Exception");
							MyToast(LocalLogin.this, getString(R.string.locallogin_getcode_failed), Toast.LENGTH_SHORT);
							e.printStackTrace();
						}
					}else{
						MyToast(LocalLogin.this, getString(R.string.on_failed), Toast.LENGTH_SHORT);
					}
				}
			});
		} else {
			dialog.dismiss();
//			getcode.setClickable(true);
//			getcode.setEnabled(true);
			setGetCode(true);
			MyToast(LocalLogin.this, getString(R.string.on_error), Toast.LENGTH_SHORT);
		}

	}

	private void getLoginByCode() {
		RelativeLayout mRelativeLayout_login = (RelativeLayout) LayoutInflater.from(LocalLogin.this).inflate(R.layout.shareplatform_login_alter, null);
		mDialog_AutoLogin = new Dialog(LocalLogin.this, R.style.NobackDialog);
		WindowManager.LayoutParams lp = mDialog_AutoLogin.getWindow().getAttributes();
		lp.alpha=0.65f;//透明度，黑暗度为lp.dimAmount=1.0f;
		mDialog_AutoLogin.getWindow().setAttributes(lp);
		mDialog_AutoLogin.requestWindowFeature(Window.FEATURE_NO_TITLE);
		mDialog_AutoLogin.setContentView(mRelativeLayout_login, new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		mDialog_AutoLogin.setOnCancelListener(new DialogInterface.OnCancelListener() {
			
			@Override
			public void onCancel(DialogInterface dialog) {
			}
		});
		mDialog_AutoLogin.show();
		
		if (Utils.isNetworkAvaliable(LocalLogin.this)) {
			MyTransCode mt = new MyTransCode();
	    	String sig = mt.TransSig();
	    	Log.i(TAG, "sig="+sig);
	    	
			new PlatformHttpRequest(LocalLogin.this).loginBycode(phone
					.getText().toString().trim(), code.getText().toString()
					.trim(), client_id, sig, new FetionPublicAccountHandler() {
				@Override
				public void onTimeOut() {
					mDialog_AutoLogin.dismiss();
					MyToast(LocalLogin.this, getString(R.string.on_time_out), Toast.LENGTH_SHORT);
				}

				@Override
				public void onSuccess(String result) {
					cacheServiceData(LocalLogin.this,result);
					// 获取成功
					Log.i(TAG, result);
					try {
						JSONObject jsonObj = new JSONObject(result);
						int expires_in = jsonObj.getInt("expires_in");
						String access_token = jsonObj.getString("access_token");
						Log.i(TAG, "access_token=" + access_token);
						String cookie = jsonObj.getString("cookie");
						saveToken(LocalLogin.this, "FX", access_token,cookie,
								expires_in);
						JSONArray jsonAry = jsonObj.getJSONArray("buddy");
						cacheServiceData(LocalLogin.this, jsonAry.toString());
						mDialog_AutoLogin.dismiss();
						MyToast(LocalLogin.this, getString(R.string.login_ok), Toast.LENGTH_SHORT);
						token.access_token = access_token;
						if(LoginFuncEntry.loginListener != null){
							LoginFuncEntry.loginListener.onCompleted(token);
						}
						SharedPreferences.Editor editor = LocalLogin.this.getSharedPreferences("shareplatform", Context.MODE_PRIVATE).edit();
						editor.putInt("fetionVersion", 0);
						editor.commit();
                        new PlatformHttpRequest(LocalLogin.this).gameSign(token.access_token, new FetionErrorHandler() {
							
							@Override
							public void onTimeOut() {
								Log.i(TAG, "手动登录成功签到超时");
							}
							
							@Override
							public void onSuccess(BaseErrorEntity result) {
								Log.i(TAG, "手动登录成功签到成功");
							}
							
							@Override
							public void onFailed(String result) {
								if(result != null){
									if("need login".equals(result)){
										Log.i(TAG, "手动登录成功签到时，用户的token失效,须重新登录");
									}else{
										Log.i(TAG, "手动登录成功签到时，签到失败");
									}
								}else{
									Log.i(TAG, "手动登录成功签到时,请求服务器失败");
								}
							}
						});
						new IncrementalUploadContact(LocalLogin.this, access_token).startUploadContact();
						LocalLogin.this.finish();
					} catch (JSONException e) {
						mDialog_AutoLogin.dismiss();
						MyToast(LocalLogin.this, getString(R.string.login_error), Toast.LENGTH_SHORT);
						Log.i(TAG, "Json login data error!");
						e.printStackTrace();
					}
				}

				@Override
				public void onFailed(String result) {
					mDialog_AutoLogin.dismiss();
					if(LoginFuncEntry.loginListener != null){
						LoginFuncEntry.loginListener.onFailure("error");
					}
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
								Log.i(TAG, "getLoginByCode errorCode=" + errorCode);
								if(errorCode == 2){
									MyToast(LocalLogin.this, getString(R.string.locallogin_errorcode_account), Toast.LENGTH_SHORT);
								}else if(errorCode == 3){
									MyToast(LocalLogin.this, getString(R.string.locallogin_errorcode_params), Toast.LENGTH_SHORT);
								}else{
									MyToast(LocalLogin.this, getString(R.string.login_error), Toast.LENGTH_SHORT);
								}
							}
						}else{
							MyToast(LocalLogin.this, getString(R.string.login_error), Toast.LENGTH_SHORT);
						}
					}else{
						MyToast(LocalLogin.this, getString(R.string.on_failed), Toast.LENGTH_SHORT);
					}
				}
			});
		} else {
			mDialog_AutoLogin.dismiss();
			MyToast(LocalLogin.this, getString(R.string.on_error), Toast.LENGTH_SHORT);
		}

	}

	@Override
	public void onBackPressed() {
		if(LoginFuncEntry.loginListener != null){
			LoginFuncEntry.loginListener.onCancle();
		}
		super.onBackPressed();
	}

}
