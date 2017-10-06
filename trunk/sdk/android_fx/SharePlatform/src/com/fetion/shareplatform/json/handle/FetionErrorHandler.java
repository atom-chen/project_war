package com.fetion.shareplatform.json.handle;

import com.fetion.shareplatform.model.BaseErrorEntity;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

public abstract class FetionErrorHandler extends TaskHandler<BaseErrorEntity>{

	@Override
	public BaseErrorEntity parseResult(String result) {
		BaseErrorEntity errorEntity = null;
		try {
			errorEntity = new Gson().fromJson(result.trim(), new TypeToken<BaseErrorEntity>(){}.getType());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return errorEntity;
	}

}
