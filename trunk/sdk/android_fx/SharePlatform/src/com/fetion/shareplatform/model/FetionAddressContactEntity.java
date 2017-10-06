package com.fetion.shareplatform.model;

public class FetionAddressContactEntity extends BaseEntity {
	/**
	 * 
	 */
	private static final long serialVersionUID = -65398350729198116L;
	private String userid;
	private String usermobile;
	private String addressid;
	private String addressname;
	private String addressmobile;
	private String addressversion;
	private String firstchar;
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public String getUsermobile() {
		return usermobile;
	}
	public void setUsermobile(String usermobile) {
		this.usermobile = usermobile;
	}
	public String getAddressid() {
		return addressid;
	}
	public void setAddressid(String addressid) {
		this.addressid = addressid;
	}
	public String getAddressname() {
		return addressname;
	}
	public void setAddressname(String addressname) {
		this.addressname = addressname;
	}
	public String getAddressmobile() {
		return addressmobile;
	}
	public void setAddressmobile(String addressmobile) {
		this.addressmobile = addressmobile;
	}
	public String getAddressversion() {
		return addressversion;
	}
	public void setAddressversion(String addressversion) {
		this.addressversion = addressversion;
	}
	public String getFirstchar() {
		return firstchar;
	}
	public void setFirstchar(String firstchar) {
		this.firstchar = firstchar;
	}
	@Override
	public String toString() {
		return "FetionAddressContactEntity [userid=" + userid + ", usermobile="
				+ usermobile + ", addressid=" + addressid + ", addressname="
				+ addressname + ", addressmobile=" + addressmobile
				+ ", addressversion=" + addressversion + ", firstchar="
				+ firstchar + "]";
	}

}
