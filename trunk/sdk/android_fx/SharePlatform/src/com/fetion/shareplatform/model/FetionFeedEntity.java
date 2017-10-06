package com.fetion.shareplatform.model;

public class FetionFeedEntity{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 4867836854933239824L;
	
	public boolean  Created;
	private String status;
	private String errorcode;
//	public String feedId;
//	public int xpoint;
//	public int ypoint;
//	public int ghashvalue;
//	public String verb;
//	public Date published;
//	public String category;
//	public String CallMeKey;
//	public String CallMeUrl;
//	public int status;
//	
//	public FetionFeedEntity object;
//    
//    public long mergerCount;
//    public long commentCount;
//    public long forwardCount;
//    public long favourCount;
//    public long lastFavourUserId;
//    public String lastFavourUserName;
//    public String lastAtTime;
//    public String lastCommentTime;
//    public String comments;
//    public boolean isFavour;
//    public String FavoritesTime;
//    public String offset;
	public boolean isCreated() {
		return Created;
	}
	public void setCreated(boolean created) {
		Created = created;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getErrorcode() {
		return errorcode;
	}
	public void setErrorcode(String errorcode) {
		this.errorcode = errorcode;
	}

}
