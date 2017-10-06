package com.fetion.shareplatform.model;

import java.io.Serializable;

public class PhoneContactEntity implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 3348744259169763305L;

	private String id = "";       //id
	private String mobile="";     // 手机
	private String version="";    
	public String getVersion() {
		return version;
	}
	public void setVersion(String version) {
		this.version = version;
	}
	private String homeNum="";    // 住宅电话
	private String jobNum="";     // 单位电话
	private String workFax="";    // 单位传真
	private String homeFax="";    // 住宅传真
	private String pager="";      // 寻呼机
	private String quickNum="";   // 回拨号码
	private String jobTel="";      // 公司总机
	private String carNum="";     // 车载电话
	private String isdn="";      // ISDN
	private String tel="";       // 总机
	private String wirelessDev="";   // 无线装置
	private String telegram="";       // 电报
	private String tty_tdd="";       // TTY_TDD
	private String jobMobile="";      // 单位手机
	private String jobPager="";      // 单位寻呼机
	private String assistantNum="";   // 助理
	private String mms="";          // 彩信
	
	private String prefix="";       
	private String firstName="";
	private String middleName="";
	private String lastname="";
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	private String suffix="";
	private String phoneticFirstName="";
	private String phoneticMiddleName="";
	private String phoneticLastName="";
	
	private String homeEmail="";      // 住宅邮件地址
	private String jobEmail="";        // 单位邮件地址
	private String mobileEmail="";     // 手机邮件地址
	private String birthday="";         // 生日
	private String anniversary="";       // 周年纪念日
	private String workMsg="";         // 即时消息
	private String instantsMsg="";
	
	private String remark="";          // 获取备注信息
	private String nickName="";       // 获取昵称信息
	
	private String company="";          // 单位
	private String jobTitle=""; 
	private String department="";
	
	private String home="";            // 主页
	private String homePage="";        // 个人主页
	private String workPage="";          // 工作主页
	
	private String street="";         // 单位通讯地址
	private String ciry="";
	private String box="";
	private String area="";
	private String state="";
	private String zip="";
	private String country="";
	private String homeStreet="";        // 住宅通讯地址
	private String homeCity="";
	private String homeBox="";
	private String homeArea="";
	private String homeState="";
	private String homeZip="";
	private String homeCountry="";
	
	private String otherStreet="";       // 其他通讯地址
	private String otherCity="";
	private String otherBox="";
	private String otherArea="";
	private String otherState="";
	private String otherZip="";
	private String otherCountry="";
	public String getMobile() {
		return mobile;
	}
	public void setMobile(String mobile) {
		this.mobile = mobile;
	}
	public String getHomeNum() {
		return homeNum;
	}
	public void setHomeNum(String homeNum) {
		this.homeNum = homeNum;
	}
	public String getJobNum() {
		return jobNum;
	}
	public void setJobNum(String jobNum) {
		this.jobNum = jobNum;
	}
	public String getWorkFax() {
		return workFax;
	}
	public void setWorkFax(String workFax) {
		this.workFax = workFax;
	}
	public String getHomeFax() {
		return homeFax;
	}
	public void setHomeFax(String homeFax) {
		this.homeFax = homeFax;
	}
	public String getPager() {
		return pager;
	}
	public void setPager(String pager) {
		this.pager = pager;
	}
	public String getQuickNum() {
		return quickNum;
	}
	public void setQuickNum(String quickNum) {
		this.quickNum = quickNum;
	}
	public String getJobTel() {
		return jobTel;
	}
	public void setJobTel(String jobTel) {
		this.jobTel = jobTel;
	}
	public String getCarNum() {
		return carNum;
	}
	public void setCarNum(String carNum) {
		this.carNum = carNum;
	}
	public String getIsdn() {
		return isdn;
	}
	public void setIsdn(String isdn) {
		this.isdn = isdn;
	}
	public String getTel() {
		return tel;
	}
	public void setTel(String tel) {
		this.tel = tel;
	}
	public String getWirelessDev() {
		return wirelessDev;
	}
	public void setWirelessDev(String wirelessDev) {
		this.wirelessDev = wirelessDev;
	}
	public String getTelegram() {
		return telegram;
	}
	public void setTelegram(String telegram) {
		this.telegram = telegram;
	}
	public String getTty_tdd() {
		return tty_tdd;
	}
	public void setTty_tdd(String tty_tdd) {
		this.tty_tdd = tty_tdd;
	}
	public String getJobMobile() {
		return jobMobile;
	}
	public void setJobMobile(String jobMobile) {
		this.jobMobile = jobMobile;
	}
	public String getJobPager() {
		return jobPager;
	}
	public void setJobPager(String jobPager) {
		this.jobPager = jobPager;
	}
	public String getAssistantNum() {
		return assistantNum;
	}
	public void setAssistantNum(String assistantNum) {
		this.assistantNum = assistantNum;
	}
	public String getMms() {
		return mms;
	}
	public void setMms(String mms) {
		this.mms = mms;
	}
	public String getPrefix() {
		return prefix;
	}
	public void setPrefix(String prefix) {
		this.prefix = prefix;
	}
	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getMiddleName() {
		return middleName;
	}
	public void setMiddleName(String middleName) {
		this.middleName = middleName;
	}
	public String getLastname() {
		return lastname;
	}
	public void setLastname(String lastname) {
		this.lastname = lastname;
	}
	public String getSuffix() {
		return suffix;
	}
	public void setSuffix(String suffix) {
		this.suffix = suffix;
	}
	public String getPhoneticFirstName() {
		return phoneticFirstName;
	}
	public void setPhoneticFirstName(String phoneticFirstName) {
		this.phoneticFirstName = phoneticFirstName;
	}
	public String getPhoneticMiddleName() {
		return phoneticMiddleName;
	}
	public void setPhoneticMiddleName(String phoneticMiddleName) {
		this.phoneticMiddleName = phoneticMiddleName;
	}
	public String getPhoneticLastName() {
		return phoneticLastName;
	}
	public void setPhoneticLastName(String phoneticLastName) {
		this.phoneticLastName = phoneticLastName;
	}
	public String getHomeEmail() {
		return homeEmail;
	}
	public void setHomeEmail(String homeEmail) {
		this.homeEmail = homeEmail;
	}
	public String getJobEmail() {
		return jobEmail;
	}
	public void setJobEmail(String jobEmail) {
		this.jobEmail = jobEmail;
	}
	public String getMobileEmail() {
		return mobileEmail;
	}
	public void setMobileEmail(String mobileEmail) {
		this.mobileEmail = mobileEmail;
	}
	public String getBirthday() {
		return birthday;
	}
	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}
	public String getAnniversary() {
		return anniversary;
	}
	public void setAnniversary(String anniversary) {
		this.anniversary = anniversary;
	}
	public String getWorkMsg() {
		return workMsg;
	}
	public void setWorkMsg(String workMsg) {
		this.workMsg = workMsg;
	}
	public String getInstantsMsg() {
		return instantsMsg;
	}
	public void setInstantsMsg(String instantsMsg) {
		this.instantsMsg = instantsMsg;
	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	public String getNickName() {
		return nickName;
	}
	public void setNickName(String nickName) {
		this.nickName = nickName;
	}
	public String getCompany() {
		return company;
	}
	public void setCompany(String company) {
		this.company = company;
	}
	public String getJobTitle() {
		return jobTitle;
	}
	public void setJobTitle(String jobTitle) {
		this.jobTitle = jobTitle;
	}
	public String getDepartment() {
		return department;
	}
	public void setDepartment(String department) {
		this.department = department;
	}
	public String getHome() {
		return home;
	}
	public void setHome(String home) {
		this.home = home;
	}
	public String getHomePage() {
		return homePage;
	}
	public void setHomePage(String homePage) {
		this.homePage = homePage;
	}
	public String getWorkPage() {
		return workPage;
	}
	public void setWorkPage(String workPage) {
		this.workPage = workPage;
	}
	public String getStreet() {
		return street;
	}
	public void setStreet(String street) {
		this.street = street;
	}
	public String getCiry() {
		return ciry;
	}
	public void setCiry(String ciry) {
		this.ciry = ciry;
	}
	public String getBox() {
		return box;
	}
	public void setBox(String box) {
		this.box = box;
	}
	public String getArea() {
		return area;
	}
	public void setArea(String area) {
		this.area = area;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getZip() {
		return zip;
	}
	public void setZip(String zip) {
		this.zip = zip;
	}
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}
	public String getHomeStreet() {
		return homeStreet;
	}
	public void setHomeStreet(String homeStreet) {
		this.homeStreet = homeStreet;
	}
	public String getHomeCity() {
		return homeCity;
	}
	public void setHomeCity(String homeCity) {
		this.homeCity = homeCity;
	}
	public String getHomeBox() {
		return homeBox;
	}
	public void setHomeBox(String homeBox) {
		this.homeBox = homeBox;
	}
	public String getHomeArea() {
		return homeArea;
	}
	public void setHomeArea(String homeArea) {
		this.homeArea = homeArea;
	}
	public String getHomeState() {
		return homeState;
	}
	public void setHomeState(String homeState) {
		this.homeState = homeState;
	}
	public String getHomeZip() {
		return homeZip;
	}
	public void setHomeZip(String homeZip) {
		this.homeZip = homeZip;
	}
	public String getHomeCountry() {
		return homeCountry;
	}
	public void setHomeCountry(String homeCountry) {
		this.homeCountry = homeCountry;
	}
	public String getOtherStreet() {
		return otherStreet;
	}
	public void setOtherStreet(String otherStreet) {
		this.otherStreet = otherStreet;
	}
	public String getOtherCity() {
		return otherCity;
	}
	public void setOtherCity(String otherCity) {
		this.otherCity = otherCity;
	}
	public String getOtherBox() {
		return otherBox;
	}
	public void setOtherBox(String otherBox) {
		this.otherBox = otherBox;
	}
	public String getOtherArea() {
		return otherArea;
	}
	public void setOtherArea(String otherArea) {
		this.otherArea = otherArea;
	}
	public String getOtherState() {
		return otherState;
	}
	public void setOtherState(String otherState) {
		this.otherState = otherState;
	}
	public String getOtherZip() {
		return otherZip;
	}
	public void setOtherZip(String otherZip) {
		this.otherZip = otherZip;
	}
	public String getOtherCountry() {
		return otherCountry;
	}
	public void setOtherCountry(String otherCountry) {
		this.otherCountry = otherCountry;
	}
	@Override
	public String toString() {
		return "PhoneContactEntity [id=" + id + ", mobile=" + mobile
				+ ", version=" + version + ", homeNum=" + homeNum + ", jobNum="
				+ jobNum + ", workFax=" + workFax + ", homeFax=" + homeFax
				+ ", pager=" + pager + ", quickNum=" + quickNum + ", jobTel="
				+ jobTel + ", carNum=" + carNum + ", isdn=" + isdn + ", tel="
				+ tel + ", wirelessDev=" + wirelessDev + ", telegram="
				+ telegram + ", tty_tdd=" + tty_tdd + ", jobMobile="
				+ jobMobile + ", jobPager=" + jobPager + ", assistantNum="
				+ assistantNum + ", mms=" + mms + ", prefix=" + prefix
				+ ", firstName=" + firstName + ", middleName=" + middleName
				+ ", lastname=" + lastname + ", suffix=" + suffix
				+ ", phoneticFirstName=" + phoneticFirstName
				+ ", phoneticMiddleName=" + phoneticMiddleName
				+ ", phoneticLastName=" + phoneticLastName + ", homeEmail="
				+ homeEmail + ", jobEmail=" + jobEmail + ", mobileEmail="
				+ mobileEmail + ", birthday=" + birthday + ", anniversary="
				+ anniversary + ", workMsg=" + workMsg + ", instantsMsg="
				+ instantsMsg + ", remark=" + remark + ", nickName=" + nickName
				+ ", company=" + company + ", jobTitle=" + jobTitle
				+ ", department=" + department + ", home=" + home
				+ ", homePage=" + homePage + ", workPage=" + workPage
				+ ", street=" + street + ", ciry=" + ciry + ", box=" + box
				+ ", area=" + area + ", state=" + state + ", zip=" + zip
				+ ", country=" + country + ", homeStreet=" + homeStreet
				+ ", homeCity=" + homeCity + ", homeBox=" + homeBox
				+ ", homeArea=" + homeArea + ", homeState=" + homeState
				+ ", homeZip=" + homeZip + ", homeCountry=" + homeCountry
				+ ", otherStreet=" + otherStreet + ", otherCity=" + otherCity
				+ ", otherBox=" + otherBox + ", otherArea=" + otherArea
				+ ", otherState=" + otherState + ", otherZip=" + otherZip
				+ ", otherCountry=" + otherCountry + "]";
	}
	
}
