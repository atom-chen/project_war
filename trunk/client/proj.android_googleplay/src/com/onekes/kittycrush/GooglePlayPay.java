package com.onekes.kittycrush;

import java.util.ArrayList;

import android.app.Activity;
import android.util.Log;
import android.widget.Toast;

import com.onekes.googleplay.IabHelper;
import com.onekes.googleplay.IabResult;
import com.onekes.googleplay.Inventory;
import com.onekes.googleplay.Purchase;

public class GooglePlayPay {
	public IabHelper helper = null;
	private Activity mActivity = null;
	private boolean mIsGooglePlayReady = false;
	private boolean mIsPrepareSetup = false;
	private ArrayList<String> mQueryInventoryList = new ArrayList<String>();
	private ArrayList<String> mInitQueryInventoryList = new ArrayList<String>();
	private String mSku = null;
	private boolean mIsInventory = false;
	private static SDKListener mPayListener = null;
	
	public GooglePlayPay(Activity activity, ArrayList<String> initInventoryList) {
		mActivity = activity;
		if (null != initInventoryList) {
			for (int i = 0; i < initInventoryList.size(); i++) {
				mInitQueryInventoryList.add(initInventoryList.get(i));
			}
		}
	}
	
	public void pay(final String sku, final SDKListener listener) {
		Log.e("cocos2d", "GooglePlayPay -> pay -> is google play ready: " + String.valueOf(mIsGooglePlayReady));
		mPayListener = listener;
		if (mIsGooglePlayReady) {
			if (null != sku && sku.length() > 0) {
				ArrayList<String> inventoryList = new ArrayList<String>();
				inventoryList.add(sku);
				mSku = sku;
				queryInventory(inventoryList);
			}
			return;
		}
		if (null == helper) {
			String base64EncodedPublicKey = mActivity.getResources().getString(R.string.base64EncodedPublicKey);
			helper = new IabHelper(mActivity, base64EncodedPublicKey);
		}
		if (mIsPrepareSetup) {
			Log.e("cocos2d", "GooglePlayPay -> pay -> in setup google play");
			Toast.makeText(mActivity, "Start setup googleplay service, please waiting", Toast.LENGTH_LONG).show();
			return;
		}
		Log.e("cocos2d", "GooglePlayPay -> pay -> start setup google play");
		mIsPrepareSetup = true;
		helper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
			public void onIabSetupFinished(IabResult result) {
				if (result.isSuccess()) {
					Log.e("cocos2d", "GooglePlayPay -> pay -> setup google play success");
					mIsGooglePlayReady = true;
					mSku = sku;
					queryInventory(mInitQueryInventoryList);
				} else {
					Toast.makeText(mActivity, "Please confirm your mobile support the googleplay", Toast.LENGTH_LONG).show();
				}
				mIsPrepareSetup = false;
			}
		});
	}
	
	void queryInventory(ArrayList<String> inventoryList) {
		if (false == mIsGooglePlayReady) {
			Log.e("cocos2d", "GooglePlayPay -> queryInventory -> google play is not ready");
			return;
		}
		Log.e("cocos2d", "GooglePlayPay -> queryInventory -> inventory list count: " + inventoryList.size());
		for (int i = 0; i < inventoryList.size(); i++) {
			String sku = inventoryList.get(i);
			if (false == mQueryInventoryList.contains(sku)) {
				mQueryInventoryList.add(sku);
			}
		}
		helper.queryInventoryAsync(mGotInventoryListener, inventoryList);
	}
	
	IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
		public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
			if (result.isFailure()) {
				Log.e("cocos2d", "GooglePlayPay -> onQueryInventoryFinished -> failure: " + result.toString());
				return;
			}
			boolean consumeFlag = false;
			mIsInventory = false;
			for (int i = 0; i < mQueryInventoryList.size(); i++) {
				String sku = mQueryInventoryList.get(i);
				Log.e("cocos2d", "GooglePlayPay -> onQueryInventoryFinished -> i: " + i + ", sku: " + sku);
				if (sku.equals(mSku)) {
					mIsInventory = true;
				}
				Purchase purchase = inventory.getPurchase(sku);
				if (null == purchase) {
					continue;
				}
				consumeFlag = true;
				helper.consumeAsync(purchase, mConsumeFinishedListener);
			}
			Log.e("cocos2d", "GooglePlayPay -> onQueryInventoryFinished -> is inventory: " + String.valueOf(mIsInventory));
			if ((false == mIsInventory || false == consumeFlag) && null != mSku && mSku.length() > 0) {
				Log.e("cocos2d", "GooglePlayPay -> onQueryInventoryFinished -> sku: " + mSku);
				helper.launchPurchaseFlow(mActivity, mSku, 10001, mPurchaseFinishedListener, null);
			}
		}
	};
	
	IabHelper.OnConsumeFinishedListener mConsumeFinishedListener = new IabHelper.OnConsumeFinishedListener() {
		public void onConsumeFinished(Purchase purchase, IabResult result) {
			String sku = purchase.getSku();
			if (result.isSuccess()) {
				Log.e("cocos2d", "GooglePlayPay -> onConsumeFinished -> success, sku: " + sku);
				mQueryInventoryList.remove(sku);
				if (sku.equals(mSku) && mIsInventory && null != mSku && mSku.length() > 0) {
					mIsInventory = false;
					helper.launchPurchaseFlow(mActivity, mSku, 10001, mPurchaseFinishedListener, null);
				}
			} else {
				Log.e("cocos2d", "GooglePlayPay -> onConsumeFinished -> failure, sku: " + sku + ", result: " + result.toString());
			}
		}
	};
	
	IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
		public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
			if (result.isFailure()) {
				Log.e("cocos2d", "GooglePlayPay -> onIabPurchaseFinished -> failure1: " + result.toString());
				if (null != mPayListener) {
			        mPayListener.onCallback(2, null);
			        Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
				}
			} else {
				try {
					Log.e("cocos2d", "GooglePlayPay -> onIabPurchaseFinished -> success");
					helper.consumeAsync(purchase, mConsumeFinishedListener);
					if (null != mPayListener) {
						mPayListener.onCallback(1, null);
			        	Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
					}
				} catch (Exception e) {
					Log.e("cocos2d", "GooglePlayPay -> onIabPurchaseFinished -> failure2: " + e.toString());
					if (null != mPayListener) {
						mPayListener.onCallback(2, null);
						Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
					}
				}
			}
		}
	};
}
