package com.fetion.shareplatform.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class TokensDB extends SQLiteOpenHelper{
	
	/** 数据库名 */
	private static final String DB_NAME = "tokens.db";
	/** 数据库版本 */
	private static final int DB_VERSION = 1;
	/** 表名 */
	public static final String TABLE_NAME = "tokens_table";
	
	private static TokensDB mdb = null;
	
	private TokensDB(Context context) {
		super(context, DB_NAME, null, DB_VERSION);
	}
	
	public synchronized static TokensDB getInstance(Context context) { 
	if (mdb == null) { 
		mdb = new TokensDB(context); 
	} 
	return mdb; 
	};
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		String sql = "CREATE TABLE " + TABLE_NAME + " (" +
				" _id INTEGER primary key autoincrement," +
				" KEY_UID text," +
				" ACCESS_TOKEN text," +
				" EXPIRES_IN INTEGER," +
				" Update_Time DATE," +
				" App_Name text," +
				" COOKIE text );";
		db.execSQL(sql);
	}
	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		String sql = "DROP TABLE IF EXISTS " + TABLE_NAME;
		db.execSQL(sql);
		onCreate(db);
	}
	//查询方法
	public Cursor select() {
		SQLiteDatabase db = this.getReadableDatabase();
		Cursor cursor = db
		.query(TABLE_NAME, null, null, null, null, null, null);
		return cursor;
		}
	//增加操作
	public long insert(String key_uid,String access_token,String cookie,int expires,String update_time,String app_name)
	{
	SQLiteDatabase db = this.getWritableDatabase();
	/* ContentValues */
	ContentValues cv = new ContentValues();
	cv.put("KEY_UID", key_uid);
	cv.put("ACCESS_TOKEN", access_token);
	cv.put("EXPIRES_IN", expires);
	cv.put("Update_Time", update_time);
	cv.put("App_Name", app_name);
	cv.put("COOKIE", cookie);
	long row = db.insert(TABLE_NAME, null, cv);
	return row;
	}
	
	//删除操作
	public void delete(int id)
	{
	SQLiteDatabase db = this.getWritableDatabase();
	String where = "_id" + " = ?";
	String[] whereValue ={ Integer.toString(id) };
	db.delete(TABLE_NAME, where, whereValue);
	}

	//修改操作
    public void update(int id,String key_uid,String access_token,String cookie,int expires,String update_time,String app_name)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String where = "_id" + " = ?";
        String[] whereValue = { Integer.toString(id) };
        ContentValues cv = new ContentValues();
    	cv.put("KEY_UID", key_uid);
    	cv.put("ACCESS_TOKEN", access_token);
    	cv.put("EXPIRES_IN", expires);
    	cv.put("Update_Time", update_time);
    	cv.put("App_Name", app_name);
    	cv.put("COOKIE", cookie);
        db.update(TABLE_NAME, cv, where, whereValue);
     }

}
