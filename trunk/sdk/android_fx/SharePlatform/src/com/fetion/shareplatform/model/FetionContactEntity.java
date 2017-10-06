package com.fetion.shareplatform.model;

public class FetionContactEntity extends BaseEntity{

	private static final long serialVersionUID = 20937853423126541L;

	private long userId;
	
	private String portraitTiny;
	
	private String portraitMiddle;
	
	private String portraitLarge;
	
	private String nickname;

	private int isCmUser;
	
	private String groupids; 
	
	private String firstchar;
	
	private String number;

	public long getUserId() {
		return userId;
	}

	public void setUserId(long userId) {
		this.userId = userId;
	}

	public String getPortraitTiny() {
		return portraitTiny;
	}

	public void setPortraitTiny(String portraitTiny) {
		this.portraitTiny = portraitTiny;
	}

	public String getPortraitMiddle() {
		return portraitMiddle;
	}

	public void setPortraitMiddle(String portraitMiddle) {
		this.portraitMiddle = portraitMiddle;
	}

	public String getPortraitLarge() {
		return portraitLarge;
	}

	public void setPortraitLarge(String portraitLarge) {
		this.portraitLarge = portraitLarge;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public int getIsCmUser() {
		return isCmUser;
	}

	public void setIsCmUser(int isCmUser) {
		this.isCmUser = isCmUser;
	}

	public String getGroupids() {
		return groupids;
	}

	public void setGroupids(String groupids) {
		this.groupids = groupids;
	}

	public String getFirstchar() {
		return firstchar;
	}

	public void setFirstchar(String firstchar) {
		this.firstchar = firstchar;
	}

	public String getNumber() {
		return number;
	}

	public void setNumber(String number) {
		this.number = number;
	}

	@Override
	public String toString() {
		return "FetionContactEntity [userId=" + userId + ", portraitTiny="
				+ portraitTiny + ", portraitMiddle=" + portraitMiddle
				+ ", portraitLarge=" + portraitLarge + ", nickname=" + nickname
				+ ", isCmUser=" + isCmUser + ", groupids=" + groupids
				+ ", firstchar=" + firstchar + ", number=" + number + "]";
	}
	
}
