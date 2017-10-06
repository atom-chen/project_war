package com.fetion.shareplatforminvite.adapter;

import java.util.List;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.example.shareplatforminvite.R;
import com.fetion.shareplatform.model.FetionContactEntity;
import com.fetion.shareplatforminvite.func.FeixinContactListActivity;
import com.fetion.shareplatforminvite.view.RoundImageView;
import com.squareup.picasso.Picasso;

public class FriendsListAdapter extends BaseAdapter{
	
    private List<FetionContactEntity> friends = null;
    private Context context;
    private LinearLayout mLinearLayout_contact;
    private AlertDialog.Builder builder = null;
    /** 记录是否获取到读取本地通讯录的权限 */
	private boolean readLocalContacts = false;
	private SharedPreferences mSharedPreferences = null;
    
    public FriendsListAdapter(Context context, List<FetionContactEntity> friends){
    	this.context = context;
    	this.friends = friends;
    	mSharedPreferences = context.getSharedPreferences("shareplatform", Context.MODE_PRIVATE); 
    	readLocalContacts = mSharedPreferences.getBoolean("readLocalContacts", false);
    }
    
	@Override
	public int getCount() {
		if(friends.size() != 0){
			return friends.size();
		}
		return 0;
	}

	@Override
	public Object getItem(int arg0) {
		return friends.get(arg0);
	}

	@Override
	public long getItemId(int arg0) {
		return arg0;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup arg2) {
		ViewHolder holder = null;
		if(position < friends.size() && position >= 0){
			if (convertView == null) {
				convertView = LayoutInflater.from(context).inflate(R.layout.shareplatform_invite_friends_item, null);
				holder = new ViewHolder();
				mLinearLayout_contact = (LinearLayout) convertView.findViewById(R.id.shareplatform_invite_contact_list_id);
				holder.linearLayout_contact = mLinearLayout_contact;
				holder.linearLayout_letter = (LinearLayout) convertView.findViewById(R.id.shareplatform_invite_friend_letter_id);
				holder.letterText = (TextView) convertView.findViewById(R.id.shareplatform_invite_letter_id);
				holder.firendsImage = (RoundImageView) convertView.findViewById(R.id.shareplatform_invite_friend_image_id);
				holder.nickname = (TextView) convertView.findViewById(R.id.shareplatform_invite_friend_name_id);
				holder.line_long = convertView.findViewById(R.id.shareplatform_invite_line_long_id);
				holder.line_short = convertView.findViewById(R.id.shareplatform_invite_line_short_id);
				holder.line_above = convertView.findViewById(R.id.shareplatform_invite_line_above_id);
				convertView.setTag(holder);
			} else {
				holder = (ViewHolder) convertView.getTag();
			}
			String currentStr = friends.get(position).getFirstchar();
			if(position > 0){
				holder.linearLayout_contact.setVisibility(View.GONE);
				holder.line_above.setVisibility(View.GONE);
				String previewStr = friends.get(position-1).getFirstchar();
				if(!currentStr.equals(previewStr)){
					holder.linearLayout_letter.setVisibility(View.VISIBLE);
					holder.letterText.setVisibility(View.VISIBLE);
					holder.letterText.setText(currentStr);
					holder.line_long.setVisibility(View.VISIBLE);
					holder.line_short.setVisibility(View.GONE);
				}else{
					holder.linearLayout_letter.setVisibility(View.GONE);
					holder.letterText.setVisibility(View.GONE);
					holder.line_long.setVisibility(View.GONE);
					holder.line_short.setVisibility(View.VISIBLE);
				}
			}else{
				holder.linearLayout_contact.setVisibility(View.VISIBLE);
				holder.line_above.setVisibility(View.VISIBLE);
				holder.linearLayout_letter.setVisibility(View.VISIBLE);
				holder.letterText.setVisibility(View.VISIBLE);
				holder.letterText.setText(currentStr);
				holder.line_long.setVisibility(View.VISIBLE);
				holder.line_short.setVisibility(View.GONE);
			}
			mLinearLayout_contact.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View v) {
					readLocalContacts = mSharedPreferences.getBoolean("readLocalContacts", false);
					if(readLocalContacts){
						context.startActivity(new Intent(context, FeixinContactListActivity.class));
					}else{
//			    		TextView textView_reject = (TextView) linearLayout.findViewById(R.id.btn_reject);
//			    		TextView textView_allow = (TextView) linearLayout.findViewById(R.id.btn_allow);
//			    		TextView textView_content = (TextView) linearLayout.findViewById(R.id.textView1);
//			    		textView_content.setText("应用将访问您的通讯录");
//			    		final long friendid = friends.get(position).getUserId();
//						final String number = friends.get(position).getNumber();
//			    		
//			    		final Dialog dialog  = new Dialog(context, R.style.NobackDialog);
//			    		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
//						dialog.setContentView(linearLayout, new RelativeLayout.LayoutParams(dip2px(context, 249), dip2px(context, 90)));
//						textView_reject.setOnTouchListener(new View.OnTouchListener() {
//
//							@Override
//							public boolean onTouch(View v, MotionEvent event) {
//								// 拒绝
//								if(dialog.isShowing()){
//									dialog.dismiss();
//								}
//								readLocalContacts = false;
//								SharedPreferences.Editor editor = mSharedPreferences.edit();
//								editor.putBoolean("readLocalContacts", readLocalContacts);
//								editor.commit();
//								Toast.makeText(context, "未获得通讯录读取权限", Toast.LENGTH_SHORT).show();
//								return false;
//							}
//						});
//						textView_allow.setOnTouchListener(new View.OnTouchListener() {
//
//							@Override
//							public boolean onTouch(View v, MotionEvent event) {
//								// 允许
//								if(dialog.isShowing()){
//									dialog.dismiss();
//								}
//								readLocalContacts = true;
//								SharedPreferences.Editor editor = mSharedPreferences.edit();
//								editor.putBoolean("readLocalContacts", readLocalContacts);
//								editor.commit();
//								context.startActivity(new Intent(context, FeixinContactListActivity.class));
//								return false;
//							}
//						});
//						dialog.show();
						
						
						builder = new AlertDialog.Builder(context);
						builder.setTitle("应用将访问您的通讯录");
						builder.setNegativeButton("拒绝",
								new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										readLocalContacts = false;
										SharedPreferences.Editor editor = mSharedPreferences.edit();
										editor.putBoolean("readLocalContacts", readLocalContacts);
										editor.commit();
									}
							
						});
						builder.setPositiveButton("允许", new DialogInterface.OnClickListener() {
							
							@Override
							public void onClick(DialogInterface dialog, int which) {
								readLocalContacts = true;
								SharedPreferences.Editor editor = mSharedPreferences.edit();
								editor.putBoolean("readLocalContacts", readLocalContacts);
								editor.commit();
								context.startActivity(new Intent(context, FeixinContactListActivity.class));
							}
						});
						builder.show();
					}
				}
			});
	        FetionContactEntity fetionContactEntity = friends.get(position);
			holder.nickname.setText(fetionContactEntity.getNickname());
			Picasso.with(context).load(fetionContactEntity.getPortraitMiddle()).into(holder.firendsImage);
		}
		return convertView;
	}
	
	class ViewHolder {
		public LinearLayout linearLayout_contact;
		public LinearLayout linearLayout_letter;
		public TextView letterText;
		public View line_above;
		public View line_long;
		public View line_short;
		public RoundImageView firendsImage;
		public TextView nickname;	
	} 
}
