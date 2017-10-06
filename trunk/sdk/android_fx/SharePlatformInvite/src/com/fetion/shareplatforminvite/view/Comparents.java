package com.fetion.shareplatforminvite.view;

import java.text.CollationKey;
import java.text.Collator;
import java.util.Comparator;

import net.sourceforge.pinyin4j.lite.PinyinHelper;

import com.fetion.shareplatform.model.FetionAddressContactEntity;

public class Comparents implements Comparator<Object>{  
    Collator collator = Collator.getInstance();  
    private PinyinHelper pinyinHelper = PinyinHelper.getInstance();

    public int compare(Object element1, Object element2) {  

        CollationKey key1 = collator  
                .getCollationKey(pinyinHelper.getPinyins(((FetionAddressContactEntity) element1).getAddressname(), "#"));  
        CollationKey key2 = collator  
                .getCollationKey(pinyinHelper.getPinyins(((FetionAddressContactEntity) element2).getAddressname(), "#"));  
        return key1.compareTo(key2);  
    }  
}

