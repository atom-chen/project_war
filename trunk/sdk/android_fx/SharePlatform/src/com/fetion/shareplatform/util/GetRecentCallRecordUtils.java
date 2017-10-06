package com.fetion.shareplatform.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.CallLog;
import android.provider.ContactsContract;

import com.fetion.shareplatform.model.FetionContactEntity;

/**
 * 获取最近通话记录
 * @author fangmin
 *
 */
public class GetRecentCallRecordUtils {
	private Cursor cursor;
	private String TAG = GetRecentCallRecordUtils.class.getSimpleName();
	private Context context;
    private HashMap<String, String> callMap = new HashMap<String, String>();
	
	
	public GetRecentCallRecordUtils(Context context){
		this.context = context;
	}
	
	/** 获取最近通话记录  */
	@SuppressLint("SimpleDateFormat")
	public List<FetionContactEntity> setContenResolver() {
		callMap.clear();
		List<FetionContactEntity> callRecents = new ArrayList<FetionContactEntity>();
		ContentResolver cr = context.getContentResolver();
		try {
			cursor = cr.query(CallLog.Calls.CONTENT_URI, // 使用系统URI，取得通话记录

					new String[] { CallLog.Calls.NUMBER, // 电话号码

							CallLog.Calls.CACHED_NAME, // 联系人

							CallLog.Calls.TYPE, // 通话类型

							CallLog.Calls.DATE, // 通话时间

							CallLog.Calls.DURATION // 通话时长

					}, null, null, CallLog.Calls.DEFAULT_SORT_ORDER);

			// 遍历每条通话记录
			callRecents.clear();
//			for (cursor.moveToFirst(); !cursor.isLast(); cursor
//					.moveToNext()) {
//			while (cursor.moveToNext()){
			for (int i = 0; i < cursor.getCount(); i++) {
				cursor.moveToPosition(i);
				FetionContactEntity contactEntity = null;
				String strNumber = new String();
				strNumber = cursor.getString(cursor.getColumnIndex(CallLog.Calls.NUMBER)); // 呼叫号码
				
				if(strNumber != null && strNumber.length() > 0){
					if(Utils.checkPhone(strNumber)){
						//移动号码
						if(comparePhone(strNumber)){
							//已存在
							continue;
						}else{
							//无该号码记录
							contactEntity = new FetionContactEntity();
							contactEntity.setNumber(strNumber);
							callMap.put(strNumber, strNumber);
						}
					}else{
						//非移动号码
						continue;
					}
				}else{
					continue;
				}
				String strName = "";
				strName = strName + cursor.getString(cursor.getColumnIndex(CallLog.Calls.CACHED_NAME)); // 联系人姓名

				if(!"null".equals(strName) && strName.length() > 0){
				} else {
					String name = getContactNameFromPhoneBook(strNumber);
					if (name.length() > 0) {
						strName = name;
					} else {
						strName = strNumber;
					}
				}

				contactEntity.setUserId(0);
				contactEntity.setNickname(strName);
				contactEntity.setGroupids("");
				contactEntity.setIsCmUser(1);
				contactEntity.setPortraitLarge("");
				contactEntity.setPortraitMiddle("");
				contactEntity.setPortraitTiny("");
				contactEntity.setFirstchar("最近通话");
				callRecents.add(contactEntity);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}finally{
			if(!cursor.isClosed() && cursor!= null){
				cursor.close();
			}
		}
		return callRecents;
	}
	
	private boolean comparePhone(String number){
		boolean isExist = false;
		if(callMap.containsKey(number)){
			isExist = true;
		}
		return isExist;
	}
	
	/** 通过号码拿到通讯录中的姓名 */
	public String getContactNameFromPhoneBook(String phoneNum) {  
	    String contactName = "";  
	    ContentResolver cr = context.getContentResolver();  
	    Cursor pCur = null;
	    try {
	    	pCur = cr.query(  
		            ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null,  
		            ContactsContract.CommonDataKinds.Phone.NUMBER + " = ?",  
		            new String[] { phoneNum }, null);  
		    if (pCur.moveToFirst()) {  
		        contactName = pCur  
		                .getString(pCur  
		                        .getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)); 
		    }  
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			if(!pCur.isClosed() && pCur != null){
				pCur.close();
			}
		}
	    
	    return contactName;  
	}
}
