package com.fetion.shareplatforminvite.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.example.shareplatforminvite.R;
import com.fetion.shareplatform.model.FetionAddressContactEntity;
import com.fetion.shareplatforminvite.view.RoundImageView;

public class ContactListAdapter extends BaseAdapter{
	
	private static String TAG = ContactListAdapter.class.getSimpleName();
    private List<FetionAddressContactEntity> contacts = null;
    private Context context;
    
    public ContactListAdapter(Context context, List<FetionAddressContactEntity> contacts){
    	this.context = context;
    	this.contacts = contacts;
    }
    
	@Override
	public int getCount() {
		if(contacts.size() != 0){
			return contacts.size();
		}
		return 0;
	}

	@Override
	public Object getItem(int arg0) {
		return contacts.get(arg0);
	}

	@Override
	public long getItemId(int arg0) {
		return arg0;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup arg2) {
		ViewHolder holder = null;
		if(position < contacts.size() && position >= 0){
			if (convertView == null) {
				convertView = LayoutInflater.from(context).inflate(R.layout.shareplatform_invite_friends_contact_item, null);
				holder = new ViewHolder();
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
			String currentStr = contacts.get(position).getFirstchar();
			if(position > 0){
				holder.line_above.setVisibility(View.GONE);
				String previewStr = contacts.get(position-1).getFirstchar();
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
				holder.line_above.setVisibility(View.VISIBLE);
				holder.linearLayout_letter.setVisibility(View.VISIBLE);
				holder.letterText.setVisibility(View.VISIBLE);
				holder.letterText.setText(currentStr);
				holder.line_long.setVisibility(View.VISIBLE);
				holder.line_short.setVisibility(View.GONE);
			}
	        FetionAddressContactEntity FetionAddressContactEntity = contacts.get(position);
			holder.nickname.setText(FetionAddressContactEntity.getAddressname());
		}
		return convertView;
	}
	
	class ViewHolder {
		public LinearLayout linearLayout_letter;
		public TextView letterText;
		public View line_above;
		public View line_long;
		public View line_short;
		public RoundImageView firendsImage;
		public TextView nickname;	
	} 
}
