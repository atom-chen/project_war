package com.onekes.kittycrush;

import java.util.ArrayList;

import com.sdk.commplatform.entry.BuyInfo;
import com.utils.Database;

import android.content.ContentValues;
import android.database.Cursor;
import android.util.Log;

public class OrderTable {
	
    public static final String ORDER_TABLE = "order_table";
    public static final String ID = "_id";
    public static final String ORDER_ID = "orderId";
    public static final String PRODUCT_ID = "product_id";
    public static final String PRODUCT_NAME = "product_name";
    public static final String PRODUCT_PRICE = "product_price";
    public static final String PRODUCT_ORGINAL_PRICE = "product_orginal_price";
    public static final String COUNT = "count";
    public static final String PAY_DESCRIPTION = "pay_description";
    // 构造创建数据库的执行语句
    public static final StringBuffer CREATE_TABLE_STR =
        new StringBuffer().append("create table if not exists ")
            .append(ORDER_TABLE)
            .append("(")
            .append(ID)
            .append(" INTEGER primary key autoincrement,")
            .append(ORDER_ID)
            .append(" text,")
            .append(PRODUCT_ID)
            .append(" text,")
            .append(PRODUCT_NAME)
            .append(" text,")
            .append(PRODUCT_PRICE)
            .append(" double,")
            .append(PRODUCT_ORGINAL_PRICE)
            .append(" double,")
            .append(COUNT)
            .append(" integer,")
            .append(PAY_DESCRIPTION)
            .append(" text")
            .append(")");
    
    public static void create() {
    	Log.e("cocos2d", "OrderTable -> create");
    	Database.execute(CREATE_TABLE_STR.toString());
    }
    
    /**
     * 插入数据库
     * @param context 上下文
     * @param model 插入的数据对象
     * @return -1 为失败
     */
    public static long insert(BuyInfo order) {
        Log.e("cocos2d", "OrderTable -> insert");
        ContentValues values = new ContentValues();
        values.put(ORDER_ID, order.getSerial());
        values.put(PRODUCT_ID, order.getProductId());
        values.put(PRODUCT_NAME, order.getProductName());
        values.put(PRODUCT_PRICE, order.getProductPrice());
        values.put(PRODUCT_ORGINAL_PRICE, order.getProductOrginalPrice());
        values.put(COUNT, order.getCount());
        values.put(PAY_DESCRIPTION, order.getPayDescription());
        
        return Database.insert(ORDER_TABLE, values);
    }
    
    public static BuyInfo queryByOrderId(String orderId) {
    	Log.e("cocos2d", "OrderTable -> queryByOrderId -> " + orderId);
        BuyInfo order = null;
        Cursor cursor = null;
        try {
            cursor = Database.query(
						ORDER_TABLE,
						null,
						ORDER_ID + " = ?",
						new String[] {orderId},
						null,
						null,
						ID
					);
            if (null != cursor && cursor.getCount() > 0) {
                cursor.moveToFirst();
                while (!cursor.isAfterLast()) {
                    order = parserOrder(cursor);
                    cursor.moveToNext();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            if (null != cursor) {
                cursor.close();
                cursor = null;
            }
        }
        return order;
    }
    
    private static BuyInfo parserOrder(Cursor cursor) {
        BuyInfo order = new BuyInfo();
        order.setSerial(cursor.getString(cursor.getColumnIndex(ORDER_ID)));
        order.setProductId(cursor.getString(cursor.getColumnIndex(PRODUCT_ID)));
        order.setProductName(cursor.getString(cursor.getColumnIndex(PRODUCT_NAME)));
        order.setProductPrice(cursor.getDouble(cursor.getColumnIndex(PRODUCT_PRICE)));
        order.setProductOrginalPrice(cursor.getDouble(cursor.getColumnIndex(PRODUCT_ORGINAL_PRICE)));
        order.setCount(cursor.getInt(cursor.getColumnIndex(COUNT)));
        order.setPayDescription(cursor.getString(cursor.getColumnIndex(PAY_DESCRIPTION)));
        return order;
    }
    
    /**
     * 查询所有订单
     * @return 订单列表
     */
    public static ArrayList<BuyInfo> query() {
    	Log.e("cocos2d", "OrderTable -> query");
        ArrayList<BuyInfo> orderList = new ArrayList<BuyInfo>();
        Cursor cursor = null;
        try {
            cursor = Database.query(
            			ORDER_TABLE,
            			null,
            			null,
						null,
						null,
						null,
						ID
					);
            
            if (null != cursor && cursor.getCount() > 0) {
                cursor.moveToFirst();
                while (!cursor.isAfterLast()) {
                    orderList.add(parserOrder(cursor));
                    cursor.moveToNext();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            if (null != cursor) {
                cursor.close();
                cursor = null;
            }
        }
        return orderList;
    }
    
    /**
     * 删除订单
     * @param orderId 订单号
     * @return 结果
     */
    public static long deleteByOrderId(String orderId) {
        Log.d("cocos2d", "OrderTable -> deleteByOrderId -> " + orderId);
        return Database.delete(
        			ORDER_TABLE,
        			ORDER_ID + "= ?",
        			new String[] {orderId}
        		);
    }
    
    /**
     * 清空所有订单
     * @return 结果
     */
    public static long delete() {
    	Log.e("cocos2d", "OrderTable -> delete");
        return Database.delete(
        			ORDER_TABLE,
        			null,
        			null
        		);
    }
}
