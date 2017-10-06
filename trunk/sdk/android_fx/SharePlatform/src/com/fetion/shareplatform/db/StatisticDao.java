package com.fetion.shareplatform.db;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import com.fetion.shareplatform.model.StatisticInfo;

public class StatisticDao {

	/** db */
	private DBHelper mDBHelper = null;
	/** instance */
	private static StatisticDao mInstance = null;
	/** 写操作DB */
	private SQLiteDatabase mWriteDB;
	/** 读操作DB */
	private SQLiteDatabase mReadDB;
	
	public StatisticDao(Context context) {
		mDBHelper = new DBHelper(context);
		mWriteDB = mDBHelper.getWritableDatabase();
		mReadDB = mDBHelper.getReadableDatabase();
	}
	
	public static synchronized StatisticDao getInstance(Context context) {
		if (mInstance == null) {
			mInstance = new StatisticDao(context);
		}
		return mInstance;
	}
	
	private void insert(StatisticInfo info) {
		final ContentValues values = new ContentValues();
		values.put(StatisticColumn.SHAREURL, info.getShareUrl());
		values.put(StatisticColumn.RESULT, info.getResult());
		values.put(StatisticColumn.APPNAME, info.getAppName());
		values.put(StatisticColumn.PHONEMODEL, info.getPhoenModel());
		values.put(StatisticColumn.NETWORKTYPE, info.getNetworkType());
		values.put(StatisticColumn.TARGETPLATFORM, info.getTargetPlatform());
		mWriteDB.beginTransaction();
		try {
			mWriteDB.insert(DBHelper.STATISTIC_TABLE, null, values);
			mWriteDB.setTransactionSuccessful();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			mWriteDB.endTransaction();
		}
	}
	
	public void insertAsync(final StatisticInfo info) {
		new Thread() {
			public void run() {
				insert(info);
			};
		}.start();
	}
	
	private void delete() {
		mWriteDB.delete(DBHelper.STATISTIC_TABLE, null, null);
	}
	
	public void deleteAsync() {
		new Thread() {
			public void run() {
				delete();
			};
		}.start();
	}
	
	public List<StatisticInfo> query() {
		List<StatisticInfo> infos = new ArrayList<StatisticInfo>();
		StringBuilder query = new StringBuilder("select * from ").append(DBHelper.STATISTIC_TABLE);
		Cursor cursor = mReadDB.rawQuery(query.toString(), null);
		if (cursor != null && cursor.moveToFirst()) {
			do {
				StatisticInfo info = new StatisticInfo();
				info.setShareUrl(cursor.getString(cursor.getColumnIndex(StatisticColumn.SHAREURL)));
				info.setResult(cursor.getString(cursor.getColumnIndex(StatisticColumn.RESULT)));
				info.setAppName(cursor.getString(cursor.getColumnIndex(StatisticColumn.APPNAME)));
				info.setPhoenModel(cursor.getString(cursor.getColumnIndex(StatisticColumn.PHONEMODEL)));
				info.setNetworkType(cursor.getString(cursor.getColumnIndex(StatisticColumn.NETWORKTYPE)));
				info.setTargetPlatform(cursor.getString(cursor.getColumnIndex(StatisticColumn.TARGETPLATFORM)));
				infos.add(info);
			} while(cursor.moveToNext());
		}
		if (cursor != null) {
			cursor.close();
		}
		return infos;
	}
}
