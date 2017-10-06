package com.fetion.shareplatform.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.util.EncodingUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlSerializer;

import android.content.Context;
import android.os.Environment;
import android.util.Log;
import android.util.Xml;

import com.fetion.shareplatform.model.FetionAddressContactEntity;
import com.fetion.shareplatform.model.PhoneContactEntity;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public class ContactJSONUtils {
	private static String TAG = ContactJSONUtils.class.getSimpleName();

	public static List<PhoneContactEntity> getPhoneContactEntities(Context context){
		List<PhoneContactEntity> phoneContactEntities = new ArrayList<PhoneContactEntity>();
		String json = "";
		try {
			json = new GetContactsInfo(context).getContactInfo();
			if(json.length() > 0){
				phoneContactEntities = new Gson().fromJson(json.trim(),new TypeToken<List<PhoneContactEntity>>(){}.getType());
			}else{
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return phoneContactEntities;
	}
	
	/** 获得本地通讯录 */
	public static List<FetionAddressContactEntity> getFetionAddressContacts(Context context){
		List<FetionAddressContactEntity> addressList = new ArrayList<FetionAddressContactEntity>();
		List<PhoneContactEntity> phoneContactEntities = getPhoneContactEntities(context);
		for (int i = 0; i < phoneContactEntities.size(); i++) {
			FetionAddressContactEntity addressContactEntity = new FetionAddressContactEntity();
			PhoneContactEntity entity = phoneContactEntities.get(i);
			String id = entity.getId();
			addressContactEntity.setAddressid(id);
			String name = entity.getFirstName() + entity.getMiddleName() + entity.getLastname();
			addressContactEntity.setAddressname(name);
			String mobile = entity.getMobile().replaceAll(" ","");
	
			if(mobile != null){
				if(Utils.checkPhone(mobile)){
					addressContactEntity.setAddressmobile(mobile);
				}else{
					continue;
				}
			}else{
				continue;
			}
			String version = entity.getVersion();
			addressContactEntity.setAddressversion(version);
			addressList.add(addressContactEntity);
		}
		return addressList;
	}
	
    /**
     * 保存内容到缓存文件中
     * @param fileName 缓存文件名
     * @param addressList
     * @throws Exception
     */
	public static void saveContactToPackage(Context context, String fileName,List<FetionAddressContactEntity> addressList) {
		String content = getContactJSON(context, addressList);
		Log.i(TAG, "content:"+content);
		FileOutputStream fos = null;
		if (content.length() > 0) {
			try {
				fos = context.openFileOutput(fileName, Context.MODE_PRIVATE);
				fos.write(content.getBytes());
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				if(fos != null){
					try {
						fos.close();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
		}else{
			Log.i(TAG, "需要缓存的数据为空");
		}
	}
     
    /**
     * 读取缓存文件内容
     * @param fileName 缓存文件名
     * @return
     */
    public static List<FetionAddressContactEntity> readContactFromPackage(Context context, String fileName){
		List<FetionAddressContactEntity> addressList = new ArrayList<FetionAddressContactEntity>();
		String cache = null;
		FileInputStream fis = null;
		File file = new File(context.getFilesDir(), fileName);
		if(file.exists()){
			try {
				Log.i(TAG, "开始读取本地缓存");
				fis = context.openFileInput(fileName);
				int length = fis.available();
				byte[] buffer = new byte[length];
				fis.read(buffer);
				cache = EncodingUtils.getString(buffer, "UTF-8");
				if (cache != null) {
					List<FetionAddressContactEntity> addressList1 = new Gson().fromJson(cache.trim(),
									new TypeToken<List<FetionAddressContactEntity>>() {}.getType());
					addressList.addAll(addressList1);
				} else {
					Log.i(TAG, "本地无缓存=" + cache);
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				if(fis != null){
					try {
						fis.close();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
		}
		return addressList;
    }
	
    /** 将通讯录数据生成JSON格式数据 */
    private static String getContactJSON(Context context, List<FetionAddressContactEntity> addressList){
		JSONArray contactData = new JSONArray();
		JSONObject jsonObject = null;
		int num = 0;
		for (int i = 0; i < addressList.size(); i++) {
			jsonObject = new JSONObject();
			try {
				contactData.put(num, jsonObject);
				num++;
				String id = addressList.get(i).getAddressid();
				jsonObject.putOpt("addressid", id);
				
				String mobile = addressList.get(i).getAddressmobile();
				if(mobile != null){
					if(Utils.checkPhone(mobile)){
						jsonObject.putOpt("addressmobile", mobile);
					}else{
						continue;
					}
				}else{
					continue;
				}
				String name = addressList.get(i).getAddressname();
				if(name == null){
					name = mobile;
				}
				jsonObject.putOpt("addressname", name);
				String version = addressList.get(i).getAddressversion();
				jsonObject.putOpt("addressversion", version);
				String firstchar = addressList.get(i).getFirstchar();
				jsonObject.putOpt("firstchar", firstchar);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		Log.i(TAG, "需要缓存的数据：" + contactData.toString());
		return contactData.toString();
	}
    
    /** 生成全量增量上传的JSON格式数据 */
	public static String createJSONForAdd(Context context, List<FetionAddressContactEntity> addressContactEntities){
		JSONArray contactData = new JSONArray();
		JSONObject jsonObject = null;
		int num = 0;
		for (int i = 0; i < addressContactEntities.size(); i++) {
			jsonObject = new JSONObject();
			try {
				contactData.put(num, jsonObject);
				num++;
				String addressmobile = addressContactEntities.get(i).getAddressmobile();
				jsonObject.putOpt("addressmobile", addressmobile);
				String addressname = addressContactEntities.get(i).getAddressname();
				jsonObject.putOpt("addressname", addressname);
				String addressid = addressContactEntities.get(i).getAddressid();
				jsonObject.putOpt("addressid", addressid);
				String addressversion = addressContactEntities.get(i).getAddressversion();
				jsonObject.putOpt("addressversion", addressversion);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		return contactData.toString();
	}
	
	/** 获取到本地添加的联系人 */
	public static String getAddContacts(Context context, List<FetionAddressContactEntity> cacheAddressLists){
		List<FetionAddressContactEntity> localAddressLists =  getFetionAddressContacts(context);
		List<FetionAddressContactEntity> addAdressLists = new ArrayList<FetionAddressContactEntity>();
		for (int i = 0; i < localAddressLists.size(); i++) {
			boolean hasAdd = true;
			for (int j = 0; j < cacheAddressLists.size(); j++) {
				if(localAddressLists.get(i).getAddressid().equals(cacheAddressLists.get(j).getAddressid())){
					hasAdd = false;
				}else{
				}
			}
			if(hasAdd){
				addAdressLists.add(localAddressLists.get(i));
			}
		}
		if(addAdressLists.size() > 0){
			String addJSON = createJSONForAdd(context, addAdressLists);
			return addJSON;
		}else{
			return null;
		}
	}
	
	/** 获取到本地修改的联系人 */
	public static String getUpdateContact(Context context, List<FetionAddressContactEntity> cacheAddressLists){
		List<FetionAddressContactEntity> localAddressLists =  getFetionAddressContacts(context);
		JSONObject jsonObject = new JSONObject();
		JSONObject jsonObject1 = null;
		for (int i = 0; i < localAddressLists.size(); i++) {
			jsonObject1 = new JSONObject();
			for (int j = 0; j < cacheAddressLists.size(); j++) {
				if(localAddressLists.get(i).getAddressid().equals(cacheAddressLists.get(j).getAddressid())){
					if(localAddressLists.get(i).getAddressversion().equals(cacheAddressLists.get(j).getAddressversion())){
					}else{
						try {
							jsonObject1.putOpt("addressmobile", localAddressLists.get(i).getAddressmobile());
							jsonObject1.putOpt("addressname", localAddressLists.get(i).getAddressname());
							jsonObject1.putOpt("addressversion", localAddressLists.get(i).getAddressversion());
							jsonObject1.putOpt("addressid", localAddressLists.get(i).getAddressid());
							jsonObject.put(cacheAddressLists.get(j).getAddressmobile(), jsonObject1);
						} catch (JSONException e) {
							e.printStackTrace();
						}
					}
				}
			}
		}
		return jsonObject.toString();
	}
	
	/** 获取到本地删除的联系人 */
	public static String getDeleteContact(Context context, List<FetionAddressContactEntity> cacheAddressLists){
		List<FetionAddressContactEntity> localAddressLists =  getFetionAddressContacts(context);
		JSONObject jsonObject = new JSONObject();
		JSONObject jsonObject1 = null;
		if(localAddressLists == null || localAddressLists.size() == 0){
			
		}else{
			for (int i = 0; i < cacheAddressLists.size(); i++) {
				if(!isExist(cacheAddressLists.get(i).getAddressid(), localAddressLists)){
					try {
						jsonObject1 = new JSONObject();
						jsonObject1.putOpt("addressmobile", cacheAddressLists.get(i).getAddressmobile());
						jsonObject1.putOpt("addressname", cacheAddressLists.get(i).getAddressname());
						jsonObject1.putOpt("addressversion", cacheAddressLists.get(i).getAddressversion());
						jsonObject1.putOpt("addressid", cacheAddressLists.get(i).getAddressid());
						jsonObject.put(cacheAddressLists.get(i).getAddressmobile(), jsonObject1);
					} catch (JSONException e) {
						e.printStackTrace();
					}
				}
			}
		}
		return jsonObject.toString();
	}
	
	private static boolean isExist(String id, List<FetionAddressContactEntity> localAddressLists){
		boolean exist = false;
		for (int i = 0; i < localAddressLists.size(); i++) {
			if(id.equals(localAddressLists.get(i).getAddressid())){
				exist = true;
				break;
			}
		}
		return exist;
	}
	
	public void toXml(Context context) {
		String json = null;
		try {
			json = new GetContactsInfo(context).getContactInfo();
			madeXml(json);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private boolean madeXml(String json) throws JSONException {
		boolean bFlag = false;
		if (Environment.getExternalStorageState().equals(
				Environment.MEDIA_MOUNTED)) {
			FileOutputStream fileos = null;
			File path=Environment.getExternalStorageDirectory();
			File newXmlFile = new File(path,"tempfeinno.xml");

			if (newXmlFile.exists()) {
				bFlag = newXmlFile.delete();
			} else {
				bFlag = true;
			}

			if (bFlag) {

				try {
					if (newXmlFile.createNewFile()) {
						Log.e("开始生成xml", "开始生成xml");
						fileos = new FileOutputStream(newXmlFile);
						XmlSerializer serializer = Xml.newSerializer();
						serializer.setOutput(fileos, "UTF-8");
						serializer.startDocument("UTF-8", null);

						JSONArray array = new JSONArray(json);
						serializer.startTag(null, "root");
						for (int i = 0; i < array.length(); i++) {
							serializer.startTag(null, "user");

							JSONObject object = (JSONObject) array.get(i);
							String name = "";
							String mobile = "";
							String jobEmail = "";
							String id = "";
							if (!object.isNull("firstName")) {
								name = name + object.getString("firstName");
							}
							if (!object.isNull("lastname")) {
								name = name + object.getString("lastname");
							}

							if (!object.isNull("mobile")) {
								mobile = object.getString("mobile");
							}

							if (!object.isNull("jobEmail")) {
								jobEmail = object.getString("jobEmail");
							}
							if (!object.isNull("id")) {
								id = object.getString("id");
							}

							serializer.startTag(null, "name");
							serializer.text(name);
							serializer.endTag(null, "name");
							serializer.startTag(null, "mobile");
							serializer.text(mobile);
							serializer.endTag(null, "mobile");
							serializer.startTag(null, "jobEmail");
							serializer.text(jobEmail);
							serializer.endTag(null, "jobEmail");

							serializer.endTag(null, "user");
						}

						serializer.endTag(null, "root");
						serializer.endDocument();
						serializer.flush();
						fileos.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return bFlag;
	}
}
