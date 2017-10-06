package org.cocos2dx.lua;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Bundle;

import com.onekes.kittycrush.R;

public class LogoActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.logo_onekes);
		new Handler().postDelayed(
			new Runnable() {
				public void run() {
					Intent mainIntent = new Intent(LogoActivity.this, AppActivity.class);
					LogoActivity.this.startActivity(mainIntent);
					LogoActivity.this.finish();
				}
			}
		, 2000);
	}
}
