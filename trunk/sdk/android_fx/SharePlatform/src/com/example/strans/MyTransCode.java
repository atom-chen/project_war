package com.example.strans;

import android.content.Context;

public class MyTransCode {

	public native String TransSig();
	
	public native String MiMD5(Context context);
	
    static {
        System.loadLibrary("TransCode");
    }
}
