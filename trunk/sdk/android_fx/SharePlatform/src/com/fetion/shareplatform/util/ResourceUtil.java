package com.fetion.shareplatform.util;

import android.content.Context;

public class ResourceUtil {

	public static int getLayoutId(Context mContext, String paramString){
		return mContext.getResources().getIdentifier(paramString, "layout", mContext.getPackageName());
	}
	
	public static int getStringId(Context mContext, String paramString){
		return mContext.getResources().getIdentifier(paramString, "string", mContext.getPackageName());
	}
	
	public static int getDrawableId(Context mContext, String paramString){
		return mContext.getResources().getIdentifier(paramString, "drawable", mContext.getPackageName());
	}
	
	public static int getStyleId(Context mContext, String paramString){
		return mContext.getResources().getIdentifier(paramString, "style", mContext.getPackageName());
	}
	
	public static int getId(Context mContext, String paramString){
		return mContext.getResources().getIdentifier(paramString, "id", mContext.getPackageName());
	}
	
	public static int getColorId(Context mContext, String paramString){
		return mContext.getResources().getIdentifier(paramString, "color", mContext.getPackageName());
	}
}
