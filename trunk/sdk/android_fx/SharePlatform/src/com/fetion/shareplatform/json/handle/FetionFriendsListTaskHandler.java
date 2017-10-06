package com.fetion.shareplatform.json.handle;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import android.content.Context;
import android.os.Environment;
import android.util.Log;

import com.fetion.shareplatform.model.FetionContactEntity;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public abstract class FetionFriendsListTaskHandler extends TaskHandler<List<FetionContactEntity>>{

	private static String TAG = FetionFriendsListTaskHandler.class.getSimpleName();
	private Context context;
	private int page;

	public FetionFriendsListTaskHandler(Context context, int page){
		this.context = context;
		this.page = page;
	}
	
	@Override
	public void onFailed(String result) {
		onFailure(result);
	}

	public abstract void onFailure(String result);
	
	@Override
	public List<FetionContactEntity> parseResult(String result) {
		List<FetionContactEntity> friends = null;
		try {
			friends = new Gson().fromJson(result.trim(), new TypeToken<List<FetionContactEntity>>(){}.getType());
			if(page == 1 && friends != null){
				cacheServiceData(context, result);
			}else{
				Log.i(TAG, "result="+result);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} 
		return friends;
	}
	
	private void cacheServiceData(final Context context, final String result) {
		if (result != null) {
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
			Log.i("", "result is null");
		}
	}
}
