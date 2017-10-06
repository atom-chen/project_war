package com.onekes.kittycrush;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;
import org.cocos2dx.lua.AppActivity;

import com.onekes.kittycrush.hwgame.R;
import com.sdk.commplatform.CallbackListener;
import com.sdk.commplatform.Commplatform;
import com.sdk.commplatform.ErrorCode;
import com.sdk.commplatform.MiscCallbackListener;
import com.sdk.commplatform.entry.AppInfo;
import com.sdk.commplatform.entry.BuyInfo;
import com.sdk.commplatform.entry.PayResultInfo;
import com.sdk.commplatform.entry.SkuDetail;

public class HuaWeiPay{
	 //是否正在支付的标记位
    private Boolean mIsPaying = false;
    private Activity mActivity = null;
    private Handler mHandler = null;
    //保存所有的初始化sdk后获得的数据
    private boolean mInitSuccess = false;
    private List<SkuDetail> mSkuDetailList = null;
    private List<BuyInfo> mResupplyOrderList = null;
    private SDKListener mResupplyListener = null;
    private int mResupplyCount = 0;
	private ProgressDialog mCircleDialog = null;
    
    public HuaWeiPay(Activity activity) {
		mActivity = activity;
		mHandler = new Handler() {
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 1:		// 显示转圈
					showLoading();
					break;
				case 2:		// 隐藏转圈
					hideLoading();
					break;
				}
			}
		};
		mSkuDetailList = new ArrayList<SkuDetail>();
		mResupplyOrderList = new ArrayList<BuyInfo>();
		OrderTable.create();
		//init huawei
		int appid = 1000018025;
		String appkey = "1ad008b61b724a0a95360a8e3638cc42";
		AppInfo appInfo = new AppInfo();
        appInfo.setAppId(appid);		// 应用ID
        appInfo.setAppKey(appkey);		// 应用Key
        appInfo.setCtx(activity);
        appInfo.setVersionCheckStatus(AppInfo.VERSION_CHECK_LEVEL_NORMAL);	//版本检查结果
        Commplatform.getInstance().SetDebugMode(activity, true, 0, 0);
        Commplatform.getInstance().Init(0, appInfo, new CallbackListener<Integer>() {
	        @Override
	        public void callback(int paramInt, Integer paramT) {
		        if (ErrorCode.COM_PLATFORM_SUCCESS == paramInt) {
		        	Log.e("cocos2d", "init huawei success");
		        	mInitSuccess = true;
		        	//漏单处理
		        	checkResupplyOrder(null);
		        	//从服务端获取的所有的商品的信息
		        	querySkuDetails(null);
		        } else if (ErrorCode.COM_PLATFORM_ERROR_FORCE_CLOSE == paramInt) {
		        	Log.e("cocos2d", "init huawei fail");
		        	new AlertDialog.Builder(mActivity)
		    		.setTitle(R.string.onekes_tishi)
		    		.setMessage(R.string.onekes_exit_msg)
		    		.setPositiveButton(R.string.onekes_queding, new DialogInterface.OnClickListener() {
			    		@Override
			    		public void onClick(DialogInterface arg0, int arg1) {
		    				AppActivity.javaProxy(302, "", 0);
			    		}
		    		})
		    		.setNegativeButton(R.string.onekes_quxiao, null)
		    		.show();
		        } else if (ErrorCode.COM_PLATFORM_ERROR_ONLINE_CHECK_FAILURE == paramInt) {
		        	Log.e("cocos2d", "init huawei network not connect");
		        } else {
		        	Log.e("cocos2d", "init huawei error: " + paramInt);
		        }
	        }
        });
	}
    
    // 显示转圈
    public void showLoading() {
    	hideLoading();
    	mCircleDialog = new ProgressDialog(mActivity);
    	mCircleDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
    	mCircleDialog.setCancelable(false);
    	mCircleDialog.show();
    }
    
    // 隐藏转圈
    public void hideLoading() {
    	if (null == mCircleDialog) {
    		return;
    	}
		mCircleDialog.dismiss();
		mCircleDialog = null;
    }
    
    // 商品列表转为json字符串
    public JSONObject skuDetailListToJSONObject(List<SkuDetail> skuDetailList) {
    	if (null == skuDetailList || 0 == skuDetailList.size()) {
    		return null;
    	}
    	try {
    		JSONObject listObj = new JSONObject();
			for (SkuDetail detail : skuDetailList) {
				JSONObject obj = new JSONObject();
				obj.put("price_amount", detail.price_amount);
				obj.put("description", detail.description);
				obj.put("price", detail.price);
				obj.put("price_currency_code", detail.price_currency_code);
				obj.put("product_id", detail.productId);
				obj.put("title", detail.title);
				listObj.put(detail.productId, obj);
			}
			return listObj;
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    	return null;
    }
    
    // 请求商品信息
    public void querySkuDetails(final SDKListener listener) {
    	// 初始化未成功
    	if (!mInitSuccess) {
    		if (null != listener) {
    			listener.onCallback(2, null);
    		}
    		return;
    	}
    	//商品信息已经获取,直接返回
    	if (mSkuDetailList.size() > 0) {
    		if (null != listener) {
    			listener.onCallback(1, skuDetailListToJSONObject(mSkuDetailList));
    		}
    		return;
    	}
    	//无网络连接
    	if (!AppActivity.sActivity.isNetworkConnected()) {
    		if (null != listener) {
    			listener.onCallback(2, null);
    		}
    		return;
    	}
    	//显示转圈
    	if (null != listener) {
	    	Message msg = new Message();
	    	msg.what = 1;
	    	mHandler.sendMessage(msg);
    	}
    	//从服务端获取的所有的商品的信息
    	Commplatform.getInstance().getSkuDetails(mActivity, new CallbackListener<List<SkuDetail>>() {
			public void callback(int errorCode, List<SkuDetail> skuDetails) {
				try {
					if (ErrorCode.COM_PLATFORM_SUCCESS == errorCode && null != skuDetails) {	//商品信息获取成功
						Log.e("cocos2d", "querySkuDetails -> success, count: " + skuDetails.size());
						mSkuDetailList = skuDetails;
						if (null != listener) {
							listener.onCallback(1, skuDetailListToJSONObject(skuDetails));
						}
					} else {	//商品信息获取失败
						Log.e("cocos2d", "querySkuDetails -> errorCode: " + errorCode);
						if (null != listener) {
							listener.onCallback(2, null);
						}
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
				//隐藏转圈
				if (null != listener) {
					Message msg = new Message();
			    	msg.what = 2;
			    	mHandler.sendMessage(msg);
				}
			}
		});
    }
  
	// 产品的详细信息
	public BuyInfo getBuyInfo(String productId) {
		for (SkuDetail detail : mSkuDetailList) {
			if (productId.equals(detail.productId)) {
				return createBuyInfo(detail.productId, detail.title, Double.valueOf(detail.price_amount), detail.description); 
			}
		}
		Log.e("cocos2d", "HuaWeiPay -> getBuyInfo -> can't find product, productId: " + productId);	
		return null;
	}
	
    private BuyInfo createBuyInfo(String productId, String productName, double productPrice, String description) {
        BuyInfo buyInfo = new BuyInfo();
        buyInfo.setProductId(productId);
        buyInfo.setProductName(productName);
        buyInfo.setProductPrice(productPrice);
        buyInfo.setProductOrginalPrice(productPrice);
        buyInfo.setPayDescription(description);
        buyInfo.setDescription(description);
        buyInfo.setCount(1);
        return buyInfo;
    }

    public int pay(final String orderId, final String productId, final SDKListener listener) {
    	Log.e("cocos2d", "HuaWeiPay -> pay -> orderId: " + orderId + ", productId： " + productId);
        //同步支付
        BuyInfo order = null;
        try {
            order = getBuyInfo(productId);
            order.setSerial(orderId);
        } catch (Exception e) {
            order = null;
        }
        if (null == order) {
            return -1 ;
        }
        mIsPaying = true;
        OrderTable.insert(order);
        int aError = Commplatform.getInstance().UniPay(order, mActivity, new MiscCallbackListener.OnPayProcessListener() {
            @Override
            public void finishPayProcess(int code) {
            	Log.e("cocos2d", "HuaWeiPay -> pay -> finishPayProcess -> code: " + code);
                //回调结果，即支付过程结束
            	OrderTable.deleteByOrderId(orderId);
                mIsPaying = false;
                if (ErrorCode.COM_PLATFORM_SUCCESS == code) {
			        listener.onCallback(1, null);
			        Toast.makeText(mActivity, R.string.onekes_pay_success, Toast.LENGTH_SHORT).show();
                } else if (ErrorCode.COM_PLATFORM_ERROR_PAY_FAILURE == code) {
			        listener.onCallback(2, null);
			        Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
                } else if (ErrorCode.COM_PLATFORM_ERROR_PAY_CANCEL == code) {
			        listener.onCallback(3, null);
			        Toast.makeText(mActivity, R.string.onekes_pay_cancel, Toast.LENGTH_SHORT).show();
                } else {
			        listener.onCallback(2, null);
			        Toast.makeText(mActivity, R.string.onekes_pay_fail, Toast.LENGTH_SHORT).show();
                }
            }
        });
        Log.e("cocos2d", "HuaWeiPay -> pay -> aError: " + aError);
        if (0 == aError) {
            return 0;
        } else {
            //返回错误，即支付过程结束
        	OrderTable.deleteByOrderId(orderId);
            mIsPaying = false;
            return -1;
        }
	}
    
    public JSONObject buyInfoToJSONObject(BuyInfo info) {
    	if (null == info ) {
    		return null;
    	}
    	try {
    		JSONObject obj = new JSONObject();
			obj.put("count", info.getCount());
			obj.put("original_price", info.getProductOrginalPrice());
			obj.put("price", info.getProductPrice());
			obj.put("description", info.getDescription());
			obj.put("pay_description", info.getPayDescription());
			obj.put("product_id", info.getProductId());
			obj.put("product_name", info.getProductName());
			obj.put("order_id", info.getSerial());
			return obj;
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    	return null;
    }
    
    public void checkResupplyOrder(SDKListener listener) {
    	// 保存漏单查询监听器
    	if (null != listener) {
    		mResupplyListener = listener;
    	}
    	// 初始化未成功,或正在查询漏单
    	if (!mInitSuccess || mResupplyCount > 0) {
    		return;
    	}
    	// 处理已查询漏单
    	if (null != mResupplyOrderList && mResupplyOrderList.size() > 0) {
    		if (null != mResupplyListener) {
    			for (BuyInfo info : mResupplyOrderList) {
            		mResupplyListener.onCallback(1, buyInfoToJSONObject(info));
    			}
    			mResupplyOrderList.clear();
    			mResupplyListener = null;
    		}
    		return;
    	}
    	// 查询漏单
    	ArrayList<BuyInfo> orderList = OrderTable.query();
    	if (null == orderList || 0 == orderList.size()) {
    		return;
    	}
    	mResupplyCount = orderList.size();
		for (BuyInfo order : orderList) {
			checkPay(order.getSerial());
		}
    }
    
    // 根据订单号查询对应交易是否正常(漏单处理)
    private void checkPay(final String orderId) {
        if (null == orderId || orderId.equals("")) {
        	Log.e("cocos2d", "checkPay -> 根据订单号查询对应交易是否正常,订单号不存在 ");
        	return;
        }
        Log.e("cocos2d", "checkPay -> orderId: " + orderId);
        CallbackListener<PayResultInfo> callback = new CallbackListener<PayResultInfo>() {
            @Override
            public void callback(int responseCode, PayResultInfo info) {
                Log.e("cocos2d", "checkPay -> callback -> responseCode = " + responseCode + ", orderId = " + orderId);
                if (ErrorCode.COM_PLATFORM_SUCCESS == responseCode) {	//订单支付成功,可以根据订单号查询订单详细信息,在做订单的处理，比如查询道具，发放道具等
                	BuyInfo order = OrderTable.queryByOrderId(orderId);
                	if (null != order) {
	                	OrderTable.deleteByOrderId(orderId);
	                	if (null == mResupplyListener) {	// 未监听,暂时保存
	                		mResupplyOrderList.add(order);
	                	} else {							// 有监听,直接处理漏单
	                		mResupplyListener.onCallback(1, buyInfoToJSONObject(order));
	                	}
                	}
                } else if (ErrorCode.COM_PLATFORM_ERROR_UNEXIST_ORDER == responseCode) {	//订单不存在  从数据库删除此订单号
                	OrderTable.deleteByOrderId(orderId);
                } else if (ErrorCode.COM_PLATFORM_ERROR_PAY_FAILURE == responseCode) {	//订单支付失败  从数据库删除此订单号
                	OrderTable.deleteByOrderId(orderId);
                } else if (ErrorCode.COM_PLATFORM_ERROR_SERVER_RETURN_ERROR == responseCode) {	//服务端返回错误  从数据库删除此订单号
                	OrderTable.deleteByOrderId(orderId);
                } else if (ErrorCode.COM_PLATFORM_ERROR_PAY_REQUEST_SUBMITTED == responseCode) {	//订单已提交
                } else {	//未知错误
                }
                mResupplyCount--;
            }
        };
        Commplatform.getInstance().SearchPayResultInfo(orderId, mActivity, callback);
    }
    
    // 对于支付流程比较长而游戏不能等待，可以在onResume的系统回调中，继续游戏
    public void onResume(Activity activity) {
    	if (mIsPaying) {
    		//支付页面关闭，回到游戏，可以继续进行游戏
    	}
	}
}
