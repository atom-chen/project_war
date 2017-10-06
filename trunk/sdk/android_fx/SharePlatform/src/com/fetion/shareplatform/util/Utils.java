package com.fetion.shareplatform.util;

import java.io.BufferedReader;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import com.fetion.shareplatform.db.TokensDB;

public class Utils {

	/**
	 * 程序是否安装
	 * @param context 上下文
	 * @param packageName 检测是否安装的进程的包名
	 * @return true:该进程安装 false:该进程未安装
	 */
	public static boolean isApplicationInstalled(Context context, String packageName) {
		
		PackageInfo packageInfo = null;
		try {
			packageInfo = context.getPackageManager().getPackageInfo(packageName, 0);
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			packageInfo = null;
		}

		return packageInfo != null;
	}

	public static String getVersionName(Context context, String packageName) {
		PackageInfo packageInfo = null;

		try {
			packageInfo = context.getPackageManager().getPackageInfo(packageName, 0);
			if(packageInfo != null){
				return packageInfo.versionName;
			} else {
				return null;
			}
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return null;

	}

	private static String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}

	/**
	 * 获取当前的网络状态 -1：没有网络 1：WIFI网络2：wap网络3：net网络
	 * 
	 * @param context
	 * @return
	 */
	@SuppressLint("DefaultLocale")
	public static String getAPNType(Context context) {
		String netType = "";
		ConnectivityManager connMgr = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();

		if (networkInfo == null) {
			return netType;
		}
		int nType = networkInfo.getType();
		if (nType == ConnectivityManager.TYPE_MOBILE) {
			if (networkInfo.getExtraInfo().toLowerCase().equals("cmnet")) {
				netType = "CMNET";
			} else {
				netType = "CMWAP";
			}
		} else if (nType == ConnectivityManager.TYPE_WIFI) {
			netType = "WIFI";
		}
		return netType;
	}

	public static String getPhoneMode() {
		return android.os.Build.MODEL;
	}

	// log的标签
	public static final String TAG = "location";
	public static final boolean DEBUG = true;
	public static final String LOCATION_URL = "http://www.google.com/loc/json";
	public static final String LOCATION_HOST = "maps.google.com";

	/**
	 * 获取地理位置
	 * 
	 * @throws Exception
	 */
	public static String getLocation(String latitude, String longitude) throws Exception {
		String resultString = "";

		/** 这里采用get方法，直接将参数加到URL上 */
		String urlString = String.format("http://maps.google.cn/maps/geo?key=abcdefg&q=%s,%s", latitude, longitude);

		/** 新建HttpClient */
		HttpClient client = new DefaultHttpClient();
		/** 采用GET方法 */
		HttpGet get = new HttpGet(urlString);
		try {
			/** 发起GET请求并获得返回数据 */
			HttpResponse response = client.execute(get);
			HttpEntity entity = response.getEntity();
			BufferedReader buffReader = new BufferedReader(new InputStreamReader(entity.getContent()));
			StringBuffer strBuff = new StringBuffer();
			String result = null;
			while ((result = buffReader.readLine()) != null) {
				strBuff.append(result);
			}
			resultString = strBuff.toString();

			/** 解析JSON数据，获得物理地址 */
			if (resultString != null && resultString.length() > 0) {
				JSONObject jsonobject = new JSONObject(resultString);
				JSONArray jsonArray = new JSONArray(jsonobject.get("Placemark").toString());
				resultString = "";
				for (int i = 0; i < jsonArray.length(); i++) {
					resultString = jsonArray.getJSONObject(i).getString("address");
				}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			throw new Exception("获取物理位置出现错误:" + e.getMessage());
		} finally {
			get.abort();
			client = null;
		}

		return resultString;
	}

	/**
	 * 判断网络是否可用
	 * 
	 * @param context
	 * @return
	 */
	public static boolean isNetworkAvaliable(Context context) {
		ConnectivityManager manager = (ConnectivityManager) (context
				.getSystemService(Context.CONNECTIVITY_SERVICE));
		NetworkInfo networkinfo = manager.getActiveNetworkInfo();
		return !(networkinfo == null || !networkinfo.isAvailable());
	}

	/**
	 * 判断网络类型 wifi 3G
	 * 
	 * @param context
	 * @return
	 */
	public static boolean isWifiNetwrokType(Context context) {
		ConnectivityManager connectivityManager = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = connectivityManager.getActiveNetworkInfo();

		if (info != null && info.isAvailable()) {
			if (info.getTypeName().equalsIgnoreCase("wifi")) {
				return true;
			}
		}
		return false;
	}

	/** Stream reverse to String */
	public static String stream2String(final InputStream instream)
			throws IOException {
		final StringBuilder sb = new StringBuilder();
		try {
			final BufferedReader reader = new BufferedReader(
					new InputStreamReader(instream, "UTF-8"));
			String line = null;
			while ((line = reader.readLine()) != null) {
				sb.append(line + "\n");
			}
			int index = sb.lastIndexOf("\n");
			if (index == sb.length() - 1) {
				sb.deleteCharAt(index);
			}
		}
		catch(Exception ex){
			Log.i("wwwww", "stream2String+"+ex.getMessage());
		}
		finally {
			closeStream(instream);
		}
		return sb.toString();
	}

	/** close Stream */
	public static void closeStream(Closeable stream) {
		if (stream != null) {
			try {
				stream.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				android.util.Log.i("IOUtils", "Could not close stream", e);
			}
		}
	}

	/**
	 * 合并参数
	 * @param params
	 * @param urlEncode 是否编码
	 * @param splitter
	 * @return
	 */
	public static String joinParams(Map<String, String> params,
			boolean urlEncode, String splitter) {
		StringBuilder sb = new StringBuilder();
		int len = params.size();
		for (Map.Entry<String, String> entry : params.entrySet()) {
			if (urlEncode) {
				sb.append(urlEncode(entry.getKey()));
			} else {
				sb.append(entry.getKey());
			}
			sb.append("=");
			if (urlEncode) {
				sb.append(urlEncode(entry.getValue()));
			} else {
				sb.append(entry.getValue());
			}

			if (--len > 0) {
				sb.append(splitter);
			}
		}
		return sb.toString();
	}

	public static String joinUrlParams(Map<String, String> params) {
		return joinParams(params, true, "&");
	}

	/**
	 * 不解释
	 * 
	 * @param value
	 * @return
	 */
	public static String urlEncode(String value) {
		String encoded;
		try {
			encoded = URLEncoder.encode(value, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			encoded = URLEncoder.encode(value);
		}
		return encoded;
	}

	public static String urlDecode(String value) {
		String ret = null;
		try {
			ret = URLDecoder.decode(value, "utf-8");
		} catch (UnsupportedEncodingException e) {
			ret = URLDecoder.decode(value);
		}
		return ret;
	}

	public static String concatUrl(String url, String queryString) {
		if (url.contains("?")) {
			return url + "&" + queryString;
		} else {
			return url + "?" + queryString;
		}
	}

	/**
	 * 配置飞信的sig值（仅适用于飞信同窗的请求）
	 * @param params 请求的map，外面传进来，最终将计算好的sig存入该map
	 * @param sessionKey
	 * @param secretKey
	 * @return
	 */
	// @SuppressLint("NewApi")
	// public static void ConfigFetionSig(Map<String,String> params, String
	// sessionKey, String secretKey){
	//
	// if(!sessionKey.isEmpty()){
	// params.put("session_key", sessionKey);
	// }
	// String baseString = Utils.joinParams(params, false, "") + secretKey;
	// String sig =
	// Encryptor.byte2hex(Encryptor.encodeMD5(baseString.getBytes()));
	// params.put("sig", sig);
	//
	// }

	@SuppressLint("NewApi")
	public static void ConfigFetionSig(Map<String,String> params, String sessionKey){

		if (!sessionKey.isEmpty()) {
			params.put("session_key", sessionKey);
		}
		String baseString = Utils.joinParams(params, false, "");
		String sig = Encryptor.byte2hex(Encryptor.encodeMD5(baseString.getBytes()));
		params.put("sig", sig);

	}

	/** 查看是否存在token **/
	public static boolean selectToken(Context context, String appNames) {
		Log.i("token_time", "准备查询获取cursor");
		boolean b = false;
		boolean isDelete = false;
		int _id = -1;
		TokensDB db = TokensDB.getInstance(context);
		Cursor cursor = db.select();
		if (cursor.getCount() == 0) {
			Log.i("token_time", "cursor内没有数据");
		} else {
			// 循环遍历cursor
			while (cursor.moveToNext()) {
				// 判断是否有本app的token存在
				if (cursor.getString(cursor.getColumnIndex("App_Name")).equals(
						appNames)) {
					SimpleDateFormat sDateFormat = new SimpleDateFormat(
							"yyyy-MM-dd hh:mm:ss");
					String date = sDateFormat.format(new java.util.Date());
					Log.i("token_time", "date" + date);
					String date2 = cursor.getString(cursor
							.getColumnIndex("Update_Time"));
					Log.i("token_time", "date2" + date2);
//					int expires = cursor.getInt(cursor
//					.getColumnIndex("EXPIRES_IN"));
			        int expires =604800;//7天
					Log.i("token_time", "expires" + expires);
					int temp_expries = getTimeDelta(date, date2);
					Log.i("token_time", "当地日期与储存日期比较" + temp_expries);
					// 判断是否过期
					if (temp_expries < expires) {
						Log.i("token_time", "token在有效时间内");
						b = true;
					} else {
						_id = cursor.getInt(0);
						isDelete = true;
					}
				}
			}
		}
		cursor.close();
		
		// 如果过期 删除这条数据 返回false 重新获取token
		if (isDelete) {
			db.delete(_id);
			Log.i("token_time", "数据库update 执行完毕");
			
		}
		db.close();
		return b;
	}

	/** 获取token **/
	public static String getAccessToken(Context context, String appNames) {
		Log.i("token_time", "开始查询获取cursor");
		TokensDB db = TokensDB.getInstance(context);
		boolean isDelete = false;
		int _id = -1;
		Cursor cursor = db.select();
		String access_token = null;
		if (cursor.getCount() == 0) {
			Log.i("token_time", "cursor内没有数据");
		} else {
			// 循环遍历cursor
			while (cursor.moveToNext()) {
				// 判断是否有本app的token存在
				if (cursor.getString(cursor.getColumnIndex("App_Name")).equals(
						appNames)) {
					SimpleDateFormat sDateFormat = new SimpleDateFormat(
							"yyyy-MM-dd hh:mm:ss");
					String date = sDateFormat.format(new java.util.Date());
					Log.i("token_time", "date" + date);
					String date2 = cursor.getString(cursor
							.getColumnIndex("Update_Time"));
					Log.i("token_time", "date2" + date2);
//					int expires = cursor.getInt(cursor
//							.getColumnIndex("EXPIRES_IN"));
					int expires =604800;//7天
					Log.i("token_time", "expires" + expires);
					int temp_expries = getTimeDelta(date, date2);
					Log.i("token_time", "当地日期与储存日期比较" + temp_expries);
					// 判断是否过期
					if (temp_expries < expires) {
						Log.i("token_time", "token在有效时间内");
						access_token = cursor.getString(cursor.getColumnIndex("ACCESS_TOKEN"));
					}else{
						Log.i("token_time", "token已过期");
						_id = cursor.getInt(0);
						isDelete = true;
					}
				}
			}
		}
		cursor.close();
		
		// 如果过期 删除这条数据 返回false 重新获取token
		if (isDelete) {
			db.delete(_id);
			Log.i("token_time", "数据库update 执行完毕");
			
		}
		db.close();
		return access_token;
	}

	/** 获取token **/
	public static boolean deleteAccessToken(Context context, String appNames) {
		try {
			TokensDB db = TokensDB.getInstance(context);
			Cursor cursor = db.select();
			while (cursor.moveToNext()) {
				if (cursor.getString(cursor.getColumnIndex("App_Name")).equals(
						appNames)) {
					db.delete(cursor.getInt(0));
				}
			}
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	private final static String yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss";

	/***
	 * 两个日期相差多少秒
	 * 
	 * @param date1
	 * @param date2
	 * @return
	 */
	public static int getTimeDelta(Date date1, Date date2) {
		long timeDelta = (date1.getTime() - date2.getTime()) / 1000;// 单位是秒
		int secondsDelta = timeDelta > 0 ? (int) timeDelta : (int) Math
				.abs(timeDelta);
		return secondsDelta;
	}

	/***
	 * 两个日期相差多少秒
	 * 
	 * @param dateStr1
	 *            :yyyy-MM-dd HH:mm:ss
	 * @param dateStr2
	 *            :yyyy-MM-dd HH:mm:ss
	 */
	public static int getTimeDelta(String dateStr1, String dateStr2) {
		Date date1 = parseDateByPattern(dateStr1, yyyyMMddHHmmss);
		Date date2 = parseDateByPattern(dateStr2, yyyyMMddHHmmss);
		return getTimeDelta(date1, date2);
	}

	public static Date parseDateByPattern(String dateStr, String dateFormat) {
		SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
		try {
			return sdf.parse(dateStr);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	// 获得汉语拼音首字母
	public static String getAlpha(String str) {
		if (str == null) {
			return "#";
		}

		if (str.trim().length() == 0) {
			return "#";
		}

		char c = str.trim().substring(0, 1).charAt(0);
		// 正则表达式，判断首字母是否是英文字母
		Pattern pattern = Pattern.compile("^[A-Za-z]+$");
		if (pattern.matcher(c + "").matches()) {
			return (c + "").toUpperCase();
		} else {
			return "#";
		}
	}

	/**
	 * 从文件中获取图片
	 * @param context
	 * @param fileName
	 * @return
	 */
	public static Bitmap getImageFromAssetsFile(Context context, String fileName) {
		Bitmap image = null;
		AssetManager am = context.getResources().getAssets();
		try {
			InputStream is = am.open(fileName);
			image = BitmapFactory.decodeStream(is);
			is.close();
		} catch (IOException e) {
			// TODO Auto-generated method stub
			e.printStackTrace();
		}

		return image;
	}

	/**
	 * 获取App签名信息
	 * @param context
	 * @return
	 */
	public static String getAppSign(Context context) {
		PackageManager pm = context.getPackageManager();
		List<PackageInfo> apps = pm
				.getInstalledPackages(PackageManager.GET_SIGNATURES);
		Iterator<PackageInfo> iter = apps.iterator();
		String standerAppName = context.getPackageName();
		Log.i("wwwww", "@@@@@@appname=" + standerAppName);
		while (iter.hasNext()) {
			PackageInfo packageinfo = iter.next();
			String packageName = packageinfo.packageName;

			if (packageName.equals(standerAppName)) {
				return packageinfo.signatures[0].toCharsString();
			}
		}
		return null;
	}
	
	/**
	 * 判断号码是否是中国移动号码
	 * @param phone
	 * @return
	 */
	public static boolean checkPhone(String phone) {
		Pattern p = Pattern.compile("^1(3[4-9]|5[012789]|47|78|8[23478])\\d{8}$");
		Matcher m = p.matcher(phone);
		return m.matches();
	}
	
	/**
	 * 将像素px换算成dp
	 * @param context
	 * @param dipValue
	 * @return
	 */
	public static int dip2px(Context context, float dipValue) {
        float scale = context.getResources().getDisplayMetrics().density;  
        return (int) (dipValue * scale + 0.5f);
    }

}
