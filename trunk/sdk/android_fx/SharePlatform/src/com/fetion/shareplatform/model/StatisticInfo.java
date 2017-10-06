package com.fetion.shareplatform.model;

public class StatisticInfo {
	/** 用户ip */
	private String mShareUrl;
	/** 使用时长 */
	private String mResult;
	/** 应用名称 */
	private String mAppName;
	/** 终端型号 */
	private String mPhoenModel;
	/** 网络情况 */
	private String mNetworkType;
	/** 目标平台 */
	private String mTargetPlatform;
	
	public String getShareUrl() {
		return mShareUrl;
	}
	public void setShareUrl(String userIp) {
		this.mShareUrl = userIp;
	}
	public String getResult() {
		return mResult;
	}
	public void setResult(String useTime) {
		this.mResult = useTime;
	}
	public String getAppName() {
		return mAppName;
	}
	public void setAppName(String appName) {
		this.mAppName = appName;
	}
	public String getPhoenModel() {
		return mPhoenModel;
	}
	public void setPhoenModel(String phoenModel) {
		this.mPhoenModel = phoenModel;
	}
	public String getNetworkType() {
		return mNetworkType;
	}
	public void setNetworkType(String networkType) {
		this.mNetworkType = networkType;
	}
	public String getTargetPlatform() {
		return mTargetPlatform;
	}
	public void setTargetPlatform(String targetPlatform) {
		this.mTargetPlatform = targetPlatform;
	}
}
