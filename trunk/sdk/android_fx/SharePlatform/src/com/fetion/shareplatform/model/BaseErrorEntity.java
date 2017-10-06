package com.fetion.shareplatform.model;

import java.io.Serializable;

public class BaseErrorEntity implements Serializable {

	private static final long serialVersionUID = -4406837871593169700L;
	private String status;
	private String errorcode;
	private long error;
	private String error_description;
	
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

	public long getError() {
		return error;
	}

	public void setError(long error) {
		this.error = error;
	}

	public String getError_description() {
		return error_description;
	}

	public void setError_description(String error_description) {
		this.error_description = error_description;
	}

	@Override
	public String toString() {
		return "BaseErrorEntity [status=" + status + ", errorcode=" + errorcode
				+ ", error=" + error + ", error_description="
				+ error_description + "]";
	}
	
}
