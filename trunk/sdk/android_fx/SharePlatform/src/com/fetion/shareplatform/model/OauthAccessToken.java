package com.fetion.shareplatform.model;

public class OauthAccessToken extends BaseEntity{
	
	private static final long serialVersionUID = 1872682047982859513L;
	
	// 要获取的Access Token
	public String access_token;
	// Access Token的有效期，以秒为单位。
	public int expires_in;
	// 用于刷新Access Token 的 Refresh Token,并不是所有应用都会返回该参数。
	public String refresh_token;
	// Access Token最终的访问范围s
	public String scope;
	
	public String cookie;
	
	// 错误码
	public String error;
	// 错误描述信息，用来帮助理解和解决发生的错误
	public String error_description;
}
