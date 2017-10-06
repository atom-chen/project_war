package com.fetion.shareplatformsharebeside.func;

import java.net.MalformedURLException;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.fetion.shareplatform.model.OauthAccessToken;
import com.fetion.shareplatform.model.SharePlatformInfo;
import com.fetion.shareplatform.util.Constants;
import com.fetion.shareplatform.util.ImageDownloader;
import com.fetion.shareplatform.util.ImageDownloader.Mode;
import com.fetion.shareplatform.util.Utils;

public class ShareModActivity extends Activity {
	/***/
	public static final String SELECT_APP="apps";
	/***/
	public static final String ACCESS_TOKEN="token";
	/** 分享到同窗         */
	public static final int APP_FETION= 1 ;
	/** 分享类型              */
	public static final String SHARE_TYPE="share_type";
	/** 分享类型：文本 */
	public static final int SHARE_TYPE_TEXT = 1;
	
	ImageView iv_back,iv_share;
	TextView tv_share, tv_send, tv_watcher,tv_share_content;
	EditText et_content;
	
	CharSequence temp;
	String appName;
	String mtoken;
	SharePlatformInfo info;
	private int apps;
	private int type;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(careatView());
		initData();
		try {
			initView();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	/**代码定义布局*/
	 protected ViewGroup careatView() {  
		 //最外层布局
		 LinearLayout mainLayout = new LinearLayout(this);
		 mainLayout.setBackgroundColor(Color.WHITE);
		 mainLayout.setOrientation(LinearLayout.VERTICAL);
		 mainLayout.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
		 //第二层布局   界面头！
		 RelativeLayout relativeLayout=new RelativeLayout(this);
		 relativeLayout.setGravity(Gravity.CENTER_VERTICAL);
		 relativeLayout.setLayoutParams(new RelativeLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
//		 relativeLayout.setBackgroundDrawable(new BitmapDrawable(
//				 Utils.getImageFromAssetsFile(this, "image/title_bg.9.png")));
		 
		 iv_back=new ImageView(this);
		 RelativeLayout.LayoutParams pa= new RelativeLayout.LayoutParams(
				 LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		 pa.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
		 pa.addRule(RelativeLayout.CENTER_VERTICAL);
		 pa.setMargins(10, 10, 10, 10);
		 iv_back.setPadding(10, 0, 0, 0);
		 iv_back.setLayoutParams(pa);
		 iv_back.setImageBitmap(
				 Utils.getImageFromAssetsFile(this, "image/icon_back.png"));
		 
		 
		 tv_share=new TextView(this);
		 pa= new RelativeLayout.LayoutParams(
				 LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		 pa.addRule(RelativeLayout.CENTER_IN_PARENT);
		 tv_share.setLayoutParams(pa);
		 tv_share.setTextColor(Color.BLACK);
		 tv_share.setTextSize(18);
		 
		 tv_send=new TextView(this);
		 tv_send.setText("发送");
		 tv_send.setTextSize(18);
		 tv_send.setTextColor(Color.RED);
		 tv_send.setPadding(0, 0, 10, 0);
		 pa= new RelativeLayout.LayoutParams(
				 LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		 pa.setMargins(10, 10, 10, 10);
		 pa.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		 pa.addRule(RelativeLayout.CENTER_VERTICAL);
		 tv_send.setLayoutParams(pa);
		 
		 
		 relativeLayout.addView(iv_back);
		 relativeLayout.addView(tv_share);
		 relativeLayout.addView(tv_send);
		 //第二层布局的linearLayout
		 LinearLayout linearLayout=new LinearLayout(this);
		 linearLayout.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT));
		 linearLayout.setOrientation(LinearLayout.VERTICAL);
		 linearLayout.setWeightSum(4);
		 //输入栏位布局
		 RelativeLayout rl=new RelativeLayout(this);
		 rl.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT,1));
		 
		 et_content=new EditText(this);
		 et_content.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT));
		 et_content.setFilters(new InputFilter[]{new InputFilter.LengthFilter(140)});  
		 et_content.setGravity(Gravity.LEFT);
		 et_content.setGravity(Gravity.TOP);
		 et_content.setTextSize(20);
		 rl.addView(et_content);
		 //字数显示
		 tv_watcher=new TextView(this);
		 tv_watcher.setText("0/140");
		 pa=new RelativeLayout.LayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.WRAP_CONTENT,  LayoutParams.WRAP_CONTENT));
		 pa.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		 pa.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		 pa.setMargins(0, 0, 10, 17);
		 tv_watcher.setLayoutParams(pa);
		 rl.addView(tv_watcher);

		 //分享信息布局
		 LinearLayout ll=new LinearLayout(this);
		 ll.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT,3));
		 ll.setOrientation(LinearLayout.VERTICAL);
		 ll.setWeightSum(5);
//		 ll.setBackgroundDrawable(new BitmapDrawable(
//				 Utils.getImageFromAssetsFile(this, "image/fujian_bg.9.png")));
		 //第一个linearLayout
		 LinearLayout ll1=new LinearLayout(this);
		 ll1.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT,2));
		 //第二个linearLayout  主要显示分享信息
		 LinearLayout llmid=new LinearLayout(this);
		 llmid.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT,1));
		 llmid.setOrientation(LinearLayout.HORIZONTAL);
		 llmid.setGravity(Gravity.CENTER_VERTICAL);
		 llmid.setWeightSum(5);
		 llmid.setBackgroundColor(android.graphics.Color.parseColor("#D3D3D3"));
//		 llmid.setBackgroundDrawable(new BitmapDrawable(
//				 Utils.getImageFromAssetsFile(this, "image/float_bg_top.9.png")));
		 
		 //分享信息图片 iv_share
		 iv_share=new ImageView(this);
		 iv_share.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT,4));
		 iv_share.setPadding(4, 4, 4, 4);
		 iv_share.setImageBitmap(
				 Utils.getImageFromAssetsFile(this, "image/icon_pic_normal.png"));
		 
		 tv_share_content=new TextView(this);
		 tv_share_content.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.WRAP_CONTENT,1));
		 tv_share_content.setTextColor(Color.BLACK);
		 tv_share_content.setPadding(5, 0, 0, 0);
		 
		 llmid.addView(iv_share);
		 llmid.addView(tv_share_content);
		//第三个linearLayout
		 LinearLayout ll2=new LinearLayout(this);
		 ll2.setLayoutParams(new LinearLayout.LayoutParams(
				 LayoutParams.MATCH_PARENT,  LayoutParams.MATCH_PARENT,2));
		 //将3个linearLayout加入到底部布局

		 ll.addView(ll1);
		 ll.addView(llmid);
		 ll.addView(ll2);
		 
		 linearLayout.addView(rl);
		 linearLayout.addView(ll);
		 //将第二层布局添加到最外层布局
		 mainLayout.addView(relativeLayout);
		 mainLayout.addView(linearLayout);
		 return mainLayout;
	 }
	
	/**加载上个界面传入的数据**/
	private void initData() {
		//判断分享到的app
		apps=getIntent().getIntExtra(SELECT_APP, 0);
		//判断分享类型
		type=getIntent().getIntExtra(SHARE_TYPE, 0);
		//获得token
		mtoken=getIntent().getStringExtra(ACCESS_TOKEN);
		//获得分享实体
		info=(SharePlatformInfo) getIntent().getSerializableExtra(Constants.KEY_SHAREPLATFORM_INFO);
		judgeAppName();
	}


	/** 加载控件 
	  */
	private void initView() throws MalformedURLException {
		//判断是否是文字 是文字取消图片
		if(type==SHARE_TYPE_TEXT){
			iv_share.setVisibility(View.GONE);
		}else{
			//不是文字则看是否有指定图片 没有则选择默认图片
			iv_share.setVisibility(View.VISIBLE);
			if(info.getThumbUrl()!= null){
//				iv_share.setImageResource(info.getResId());
				ImageDownloader downloader = new ImageDownloader();
				downloader.setMode(Mode.CORRECT);
				downloader.download(info.getThumbUrl(), iv_share);
//				URL picUrl = new URL(getIntent().getExtras().getString(info.getThumbUrl()));
//				Bitmap pngBM=null;
//				try {
//					pngBM = BitmapFactory.decodeStream(picUrl.openStream());
//				} catch (IOException e) {
//					e.printStackTrace();
//				} 
//				iv_share.setImageBitmap(pngBM);

			}
		}
	    //判断分享实体是否有内容 没有则默认空白
		if(info.getText()!=null){
			et_content.setText(info.getText());
		}
		if(info.getTitle()!=null){
			tv_share_content.setText(info.getTitle());
		}
		tv_share.setText(appName);
		//返回按钮监听
		iv_back.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
			}
		});

		//文本内容更改是 记录文字字数 更新到提示下标
		et_content.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				temp = s;
			}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}
			@Override
			public void afterTextChanged(Editable s) {
				StringBuilder builder = new StringBuilder();
				builder.append(String.valueOf(temp.length()));
				builder.append("/");
				builder.append("140");
				String text = builder.toString();
				tv_watcher.setText(text);
			}
		});

		//发送按钮监听
		tv_send.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				judgeShareApp();
			}
		});
	}
	
	/**判断分享的应用名称*/
	private void judgeAppName() {
		switch (apps) {
		case 1:
			//使用飞信分享
			appName="分享到飞信同窗";
			break;
		}
	}
	/**判断分享至什么APP之后分享*/
	private void judgeShareApp() {
		switch (apps) {
		case 1:
			//分享到飞信同窗
			OauthAccessToken token=new OauthAccessToken();
			token.access_token=mtoken;
			Log.i("tian", mtoken);
			info.setText(et_content.getText().toString());
			ShareInterfaceUtils.shareToFetion(type,ShareModActivity.this,"appId",token,info,ShareFuncEntry.shareListener);
			this.finish();
			break;
		}
	}

}
