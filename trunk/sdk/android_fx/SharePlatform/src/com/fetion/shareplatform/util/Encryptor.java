/*
 * Fetion Open Platform
 *  
 * Create by GavinHwa 2011-12-20
 * 
 * Copyright (c) 2011 北京新媒传信科技有限公司
 */
package com.fetion.shareplatform.util;

import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * Encryptor
 * 
 * @author larry
 */
public class Encryptor {

	/**
	 * 生成HMAC_SHA1签名
	 * 
	 * @param data
	 *            待加密的数据
	 * @param key
	 *            加密使用的key
	 * @return 生成Base64编码的字符串
	 * @throws InvalidKeyException
	 * @throws NoSuchAlgorithmException
	 */
	public static String getSignature(byte[] data, byte[] key) throws NoSuchAlgorithmException, InvalidKeyException{
		String HMAC_SHA1 = "HmacSHA1";
		SecretKeySpec signingKey = new SecretKeySpec(key, HMAC_SHA1);
		Mac mac = Mac.getInstance(HMAC_SHA1);
		mac.init(signingKey);
		byte[] rawHmac = mac.doFinal(data);
		return encodeBase64(rawHmac);
	}

	public static byte[] encodeMD5(byte[] raw) {
		MessageDigest messageDigest = null;
		try {
			messageDigest = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException neverhappen) {
		}
		messageDigest.reset();
		messageDigest.update(raw);
		return messageDigest.digest();
	}

	public static String byte2hex(byte[] bytes) {
		StringBuffer md5StrBuff = new StringBuffer();
		for (int i = 0; i < bytes.length; i++) {
			if ((0xFF & bytes[i]) < 0x10)
				md5StrBuff.append("0").append(
						Integer.toHexString(0xFF & bytes[i]));
			else
				md5StrBuff.append(Integer.toHexString(0xFF & bytes[i]));
		}
		return md5StrBuff.toString();
	}

	public static String encodeBase64(byte[] raw) {
		return Base64.encode(raw);
	}

	public static byte[] decodeBase64(String base64) {
		return Base64.decode(base64);
	}
}
