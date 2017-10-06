package org.cocos2dx.lua;

import com.onekes.kittycrush.R;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class NotifyReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		try {
			int type = intent.getIntExtra("type", 0);
			int key = intent.getIntExtra("key", 0);
			String title = intent.getStringExtra("title");
			if (title.equals("")) {
				title = AppActivity.getContext().getResources().getString(R.string.app_name);
			}
			String text = intent.getStringExtra("text");
			Log.e("cocos2d", "NotifyReceiver -> onReceive -> type: " + type + ", key: " + key + ", title: " + title + ", text: " + text);
			
			Intent notifyIntent = new Intent(context, AppActivity.class);
			PendingIntent contentIntent = PendingIntent.getActivity(context, 0, notifyIntent, 0);  
			
			Notification.Builder builder = new Notification.Builder(context);
			builder.setAutoCancel(true);
			builder.setContentIntent(contentIntent);
			builder.setContentTitle(title);
			builder.setContentText(text);
			builder.setTicker(title);
			builder.setDefaults(Notification.DEFAULT_ALL);
			builder.setSmallIcon(R.drawable.icon);
			
			NotificationManager mn = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);  
			mn.notify((int)System.currentTimeMillis(), builder.build());
		} catch (Exception e) {
			Log.e("cocos2d", "NotifyReceiver -> onReceive -> exception: " + e.toString());
		}
	}
}
