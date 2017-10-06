package com.onekes.kxllx.wxapi;

import org.cocos2dx.lua.AppActivity;

import cn.sharesdk.wechat.utils.WechatHandlerActivity;

import com.onekes.kxllx.R;
import com.onekes.kxllx.CONFIG;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

public class WXPayEntryActivity extends WechatHandlerActivity implements IWXAPIEventHandler {
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    	api = WXAPIFactory.createWXAPI(this, CONFIG.WX_APP_ID);
        api.handleIntent(getIntent(), this);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
	}

	@Override
	public void onResp(BaseResp resp) {
		Log.d("kxllx", "onResp, errCode = " + resp.errCode + ", errString = " + resp.errStr);
		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
			Message msg = null;
			if (BaseResp.ErrCode.ERR_OK == resp.errCode) {
				msg = new Message();
				msg.what = AppActivity.MT_PAY_SUCCESS;
				msg.obj = R.string.onekes_pay_success;
				msg.arg1 = Toast.LENGTH_LONG;
		        AppActivity.sHandler.sendMessage(msg);
			} else if(BaseResp.ErrCode.ERR_USER_CANCEL == resp.errCode) {
				msg = new Message();
				msg.what = AppActivity.MT_PAY_CANCEL;
				msg.obj = R.string.onekes_pay_cancel;
				msg.arg1 = Toast.LENGTH_LONG;
		        AppActivity.sHandler.sendMessage(msg);
			} else {
				msg = new Message();
				msg.what = AppActivity.MT_PAY_FAIL;
				msg.obj = R.string.onekes_pay_fail;
				msg.arg1 = Toast.LENGTH_LONG;
		        AppActivity.sHandler.sendMessage(msg);
			}
		}
	}
}