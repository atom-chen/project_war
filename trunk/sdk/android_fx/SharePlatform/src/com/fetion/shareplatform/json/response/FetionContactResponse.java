package com.fetion.shareplatform.json.response;

import java.util.List;

import com.fetion.shareplatform.model.FetionContactEntity;

public class FetionContactResponse extends FetionGenericResponse{
	public List<FetionContactEntity> friends;
	
	public long id;
	public String name;
}
