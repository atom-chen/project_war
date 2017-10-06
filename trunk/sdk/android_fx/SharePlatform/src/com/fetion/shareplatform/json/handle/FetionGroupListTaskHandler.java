package com.fetion.shareplatform.json.handle;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;

import com.fetion.shareplatform.model.GroupEntity;

public abstract class FetionGroupListTaskHandler extends TaskHandler<List<GroupEntity>>{

	private static String TAG = FetionGroupListTaskHandler.class.getSimpleName();

//	@Override
//	public List<GroupEntity> parseResult(InputStream result) {
//		String data = null;
//		List<GroupEntity> groups = new ArrayList<GroupEntity>();
//		try {
//			data = Utils.stream2String(result);
////			groups = new Gson().fromJson(data.trim(), new TypeToken<List<GroupEntity>>(){}.getType());
//			JSONArray array = new JSONArray(data);
//			for (int i = 0; i < array.length(); i++) {
//				JSONObject jsonObject = array.getJSONObject(i);
//				GroupEntity entity = new GroupEntity();
//				entity.id = jsonObject.getInt("id");
//				entity.groupName = jsonObject.getString("groupName");
//				entity.count = jsonObject.getInt("count");
//				groups.add(entity);
//			}
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} catch (Exception e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} 
//		if(groups != null){
//			Log.i(TAG, "List<GroupEntity>不为空");
//		}else{
//			Log.i(TAG, "List<GroupEntity>为空");
//		}
//		return groups;
//	}

	@Override
	public List<GroupEntity> parseResult(String result) {
		List<GroupEntity> groups = new ArrayList<GroupEntity>();
		try {
//			groups = new Gson().fromJson(data.trim(), new TypeToken<List<GroupEntity>>(){}.getType());
			JSONArray array = new JSONArray(result);
			for (int i = 0; i < array.length(); i++) {
				JSONObject jsonObject = array.getJSONObject(i);
				GroupEntity entity = new GroupEntity();
				entity.id = jsonObject.getInt("id");
				entity.groupName = jsonObject.getString("groupName");
				entity.count = jsonObject.getInt("count");
				groups.add(entity);
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		if(groups != null){
			Log.i(TAG, "List<GroupEntity>不为空");
		}else{
			Log.i(TAG, "List<GroupEntity>为空");
		}
		return groups;
	}
}
