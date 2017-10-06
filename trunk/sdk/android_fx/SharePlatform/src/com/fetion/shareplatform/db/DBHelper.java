package com.fetion.shareplatform.db;

import android.content.Context;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

/**
 * SQLiteHelper
 *
 */
public class DBHelper extends SQLiteOpenHelper {
	
	/** instance */
	private static DBHelper mInstance = null;
	/** 数据库名 */
	private static final String DB_NAME = "shareplatform.db";
	/** 数据库版本 */
	private static final int DB_VERSION = 1;
	/** 表名 */
	public static final String STATISTIC_TABLE = "statistic";
	
	/**创建表的SQL语句*/
    private static final String CREATE_TABLE = 
        "CREATE TABLE " + STATISTIC_TABLE + " ("                 
        + StatisticColumn.ID + " INTEGER primary key autoincrement,"
        + StatisticColumn.SHAREURL + " TEXT,"
        + StatisticColumn.RESULT + " TEXT ,"
        + StatisticColumn.APPNAME + " TEXT,"
        + StatisticColumn.PHONEMODEL + " TEXT,"
        + StatisticColumn.NETWORKTYPE + " TEXT,"
        + StatisticColumn.TARGETPLATFORM + " TEXT"
        + ");";

	/**
	 * get instance of DBHelper
	 * @param context context
	 * @return the instance of DBHelper
	 */
	public static synchronized DBHelper getInstance(Context context) {
		if (mInstance == null) {
			mInstance = new DBHelper(context);
		}
		return mInstance;
	}
	
	public DBHelper(Context context) {
		super(context.getApplicationContext(), DB_NAME, null, DB_VERSION);
	}

	public DBHelper(Context context, String name, CursorFactory factory,
			int version) {
		super(context, name, factory, version);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(CREATE_TABLE);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.beginTransaction();
		try {
			db.execSQL("DROP TABLE IF EXISTS " + STATISTIC_TABLE);
			db.execSQL(CREATE_TABLE);
			db.setTransactionSuccessful();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			db.endTransaction();
		}
	}
	
}
