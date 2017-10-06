package com.fetion.shareplatform.model;


public class SharePlatformInfo extends BaseEntity {

	private static final long serialVersionUID = -5742509343194570532L;

	/**
	 * 标题
	 */
	private String mTitle;
	
	/**
	 * 描述
	 */
	private String mDescription;
	
	/**
	 * 内容
	 */
	private String mText;
	
	/**
	 * 缩略图地址-飞信使用
	 */
	private String mThumbUrl;

	
	/**
	 * 来源-飞信使用
	 */
	private String mSource;
	
	/**
	 * 是否是游戏 true:是  false:否 -飞信使用
	 */
	private boolean mIsGame;
	
	/**
	 * 分享到飞信是否需要授权 -飞信使用
	 */
	private boolean mFetionIsNeedLogin;
	
	/**
	 * 分享到身边是否需要授权-飞信使用
	 */
	private boolean mBesideIsNeedLogin;
	
	/**
	 * 图片
	 */
	private String mImageUrl;
	
	/**
	 * 音乐地址
	 */
	private String mMusicUrl;
	
	/**
	 * 视频地址
	 */
	private String mVideoUrl;
	
	/**
	 * 网页地址
	 */
	private String mPageUrl;

	public String getText() {
		return mText;
	}

	public void setText(String text) {
		this.mText = text;
	}


	public String getMusicUrl() {
		return mMusicUrl;
	}

	public void setMusicUrl(String musicUrl) {
		this.mMusicUrl = musicUrl;
	}

	public String getVideoUrl() {
		return mVideoUrl;
	}

	public void setVideoUrl(String videoUrl) {
		this.mVideoUrl = videoUrl;
	}

	public String getPageUrl() {
		return mPageUrl;
	}

	public void setPageUrl(String pageUrl) {
		this.mPageUrl = pageUrl;
	}

	public String getTitle() {
		return mTitle;
	}

	public void setTitle(String title) {
		this.mTitle = title;
	}

	public String getDescription() {
		return mDescription;
	}

	public void setDescription(String description) {
		this.mDescription = description;
	}

	public String getThumbUrl() {
		return mThumbUrl;
	}

	public void setThumbUrl(String mThumbUrl) {
		this.mThumbUrl = mThumbUrl;
	}

	public boolean getIsGame() {
		return mIsGame;
	}

	public void setIsGame(boolean mIsGame) {
		this.mIsGame = mIsGame;
	}

	public String getSource() {
		return mSource;
	}

	public void setSource(String mSource) {
		this.mSource = mSource;
	}

	public boolean getFetionIsNeedLogin() {
		return mFetionIsNeedLogin;
	}

	public void setFetionIsNeedLogin(boolean mIsNeedLogin) {
		this.mFetionIsNeedLogin = mIsNeedLogin;
	}

	public boolean getBesideIsNeedLogin() {
		return mBesideIsNeedLogin;
	}

	public void setBesideIsNeedLogin(boolean mBesideIsNeedLogin) {
		this.mBesideIsNeedLogin = mBesideIsNeedLogin;
	}

	public String getmImageUrl() {
		return mImageUrl;
	}

	public void setmImageUrl(String mImageUrl) {
		this.mImageUrl = mImageUrl;
	}
	
	
	
}
