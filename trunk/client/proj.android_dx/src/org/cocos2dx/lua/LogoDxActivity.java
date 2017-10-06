package org.cocos2dx.lua;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
import android.os.Bundle;

import com.onekes.kxllx.R;

public class LogoDxActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.logo_dx);
		new Handler().postDelayed(
			new Runnable() {
				public void run() {
					Intent mainIntent = new Intent(LogoDxActivity.this, LogoActivity.class);
					LogoDxActivity.this.startActivity(mainIntent);
					LogoDxActivity.this.finish();
				}
			}
		, 1500);
	}
}
