package com.fetion.shareplatform.model;

public class UserInfo extends BaseEntity {

	private static final long serialVersionUID = 7036956854321780714L;

	public long userId;
	public String nickname;
	public String portraitTiny;
	public String portraitMiddle;
	public String portraitLarge;
	public String mobile;
	public String fetionId;
	public String email;
	public String createDatetime;
	public int status;
	public int gender;
	public String birthday;
	public int birthType;
	public int bloodType;
	public int material;
	public int trialGuide;
	public int materialWorks;
	public int materialEducation;
	public int bindStatus;
	public int topicStatus;
	public int matBasic;
	public String nowNation;
	public String nowPro;
	public String nowCity;
	
	public String introducation;
	public int buddyCount;
	public int achivementCount;
	public int isFreshman;

	public int matWorks;

	public int matEducation;

	public int isChinaNo;

	@Override
	public String toString() {
		return "UserInfo [userId=" + userId + ", nickname=" + nickname
				+ ", portraitTiny=" + portraitTiny + ", portraitMiddle="
				+ portraitMiddle + ", portraitLarge=" + portraitLarge
				+ ", mobile=" + mobile + ", fetionId=" + fetionId + ", email="
				+ email + ", createDatetime=" + createDatetime + ", status="
				+ status + ", gender=" + gender + ", birthday=" + birthday
				+ ", birthType=" + birthType + ", bloodType=" + bloodType
				+ ", material=" + material + ", trialGuide=" + trialGuide
				+ ", materialWorks=" + materialWorks + ", materialEducation="
				+ materialEducation + ", bindStatus=" + bindStatus
				+ ", topicStatus=" + topicStatus + ", matBasic=" + matBasic
				+ ", nowNation=" + nowNation + ", nowPro=" + nowPro
				+ ", nowCity=" + nowCity + ", introducation=" + introducation
				+ ", buddyCount=" + buddyCount + ", achivementCount="
				+ achivementCount + ", isFreshman=" + isFreshman
				+ ", matWorks=" + matWorks + ", matEducation=" + matEducation
				+ ", isChinaNo=" + isChinaNo + "]";
	}



}
