package com.fetion.shareplatform.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.Gravity;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * 自定义图片按钮控件
 * */
public class ImageTextButton extends LinearLayout {
	private ImageView mImageView = null;
	private TextView mTextView = null;

	public ImageTextButton(Context context, Bitmap bitmap, String text,
			int backgroundColor, int textColor, int textSize,boolean isButton,int imageWidth,int imageHeith) {
		super(context);
		setOrientation(LinearLayout.VERTICAL);
		// setGravity(Gravity.CENTER);
		setBackgroundColor(backgroundColor);
		setClickable(true);
		setFocusable(true);

		// next layout
		LinearLayout layout = new LinearLayout(context);
		layout.setGravity(Gravity.CENTER);
		layout.setLayoutParams(new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.MATCH_PARENT,
				LinearLayout.LayoutParams.WRAP_CONTENT));
		layout.setGravity(Gravity.CENTER);

		mImageView = new ImageView(context);
		mImageView.setImageBitmap(bitmap);
		LayoutParams params = new LayoutParams(imageWidth,imageHeith);
		mImageView.setLayoutParams(params);
		mImageView.setPadding(0, 5, 0, 5);
		mTextView = new TextView(context);
		mTextView.setText(text);
		mTextView.setTextColor(textColor);
		mTextView.setTextSize(textSize);
		// image and text
		layout.addView(mImageView);
		layout.addView(mTextView);
		// line and next
		addView(layout);
		
		
		if(isButton){
		setTextColor(textColor);
		}
	}

	
	public void setImageBitmap(Bitmap bitmap) {
		mImageView.setImageBitmap(bitmap);
	}

	public void setTextColor(int textColor) {
		
		mTextView.setTextColor(textColor);
	}

	public void setImagePadding(int left, int top, int right, int bottom) {
		mImageView.setPadding(left, top, right, bottom);
	}

	public void setTextsPadding(int left, int top, int right, int bottom) {
		mTextView.setPadding(left, top, right, bottom);
	}
}
