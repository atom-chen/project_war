----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-5
-- Brief: 副本需要解锁条件界面
----------------------------------------------------------------------
UICopyUnlock = {
	csbFile = "CopyUnlock.csb"
}

function UICopyUnlock:onStart(ui, param)
	
	local Text_or = UIManager:seekNodeByName(ui.root, "Text_or")
	Text_or:setString(LanguageStr("COPY_UNLOCK_OR"))
	
	AudioMgr:playEffect(2007)
	self.unLockCopyId = param.unLockCopyId
	local unlockInfo = DataLevelInfo:getUnlockCopyInfo()
	--需要的英雄个数
	self.Text_need_1 = UIManager:seekNodeByName(ui.root, "Text_need_1")
	self.Text_need_1:setString(LanguageStr("COPY_UNLOCK_1",unlockInfo[2]))
	--需要的英雄等级
	self.Text_need_2 = UIManager:seekNodeByName(ui.root, "Text_need_2")
	self.Text_need_2:setString(LanguageStr("COPY_UNLOCK_2",unlockInfo[2],unlockInfo[1]))
	--解锁关卡需要消耗的钻石
	self.Text_need_dia = UIManager:seekNodeByName(ui.root, "Text_dia")
	self.Text_need_dia:enableOutline(cc.c4b(97,49,13,255),3)
	self.Text_need_dia:setString(G.COPY_UNLICK_DIA)
	-- 前往抽奖界面按钮
	local btnGo_1 = UIManager:seekNodeByName(ui.root, "go_1")
	Utils:addTouchEvent(btnGo_1, function(sender)
		UIManager:close(self)
		UIMiddlePub:handleEnterAwardUI()
	end, true, true, 0)
	-- 前往英雄升级界面按钮
	local btnGo_2 = UIManager:seekNodeByName(ui.root, "go_2")
	Utils:addTouchEvent(btnGo_2, function(sender)
		UIManager:close(self)
		UIMiddlePub:handleEnterHeroUI()
	end, true, true, 0)
	-- 英雄个数足够图片
	local fullImg_1 = UIManager:seekNodeByName(ui.root, "full_1")
	-- 英雄的等级足够图片
	local fullImg_2 = UIManager:seekNodeByName(ui.root, "full_2")
	-- 或者文字
	local Text_or = UIManager:seekNodeByName(ui.root, "Text_or")
	-- 需要砖石的panel
	local Image_buy = UIManager:seekNodeByName(ui.root, "Image_buy")
	-- 解锁按钮
	local btnUnlock = UIManager:seekNodeByName(ui.root, "Button_unlock")
	Utils:addTouchEvent(btnUnlock, function(sender)
		if DataLevelInfo:canUnlock(DataLevelInfo:getUnlockCopyInfo()) then		--可以解锁
			self:setUnlockCopyData()
			return
		end
		--花砖石解锁
		local curDiamond = ItemModel:getTotalDiamond()
		if curDiamond > G.COPY_UNLICK_DIA then
			nowNumber = curDiamond -  G.COPY_UNLICK_DIA
			
			local tb = {}
			tb.itemType = ItemType["dia"] 
			tb.oldAmount = curDiamond
			tb.newAmount = nowNumber
			tb.flag = SignType["reduce"]
			EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
			
			ItemModel:appendTotalDiamond(-G.COPY_UNLICK_DIA)
			self:setUnlockCopyData()
		else
			ChannelProxy:getStrInfo("shop", function(productTb)
				if 0 == #productTb then
					UIPrompt:show(LanguageStr("QURERY_FAIL"))
				else
					UIManager:openFront(UIBuyDiamond,true,{["enter_mode"] ="buy",["diamondNumber"] = G.COPY_UNLICK_DIA - curDiamond, ["product_tb"]=productTb})
				end
			end)
		end
	end, true, true, 0)
	
	if #DataMap:getHeroIds() >= unlockInfo[2] then	--解锁的英雄够了
		fullImg_1:setVisible(true)
		btnGo_1:setVisible(false)
		btnGo_1:setTouchEnabled(false)
		Text_or:setVisible(false)
		Image_buy:setVisible(false)
		self.Text_need_1:enableOutline(cc.c4b(119,62,7,255),3)
		self.Text_need_1:setColor(cc.c3b(255,255,255))
		self.Text_need_1:enableOutline(cc.c4b(119,62,7,255),3)
		if DataLevelInfo:canUnlock(DataLevelInfo:getUnlockCopyInfo()) then	--解锁的英雄等级够了
			fullImg_2:setVisible(true)
			btnGo_2:setVisible(false)
			btnGo_2:setTouchEnabled(false)
			Text_or:setVisible(false)
			Image_buy:setVisible(false)
			self.Text_need_2:setColor(cc.c3b(255,255,255))
			self.Text_need_2:enableOutline(cc.c4b(119,62,7,255),3)
		else
			fullImg_2:setVisible(false)
			btnGo_2:setVisible(true)
			btnGo_2:setTouchEnabled(true)
			Text_or:setVisible(true)
			Image_buy:setVisible(true)
			self.Text_need_2:setColor(cc.c3b(254,36,27))
		end
	else	--解锁的英雄不够
		fullImg_1:setVisible(false)
		fullImg_2:setVisible(false)
		btnGo_1:setVisible(true)
		btnGo_1:setTouchEnabled(true)
		btnGo_2:setVisible(true)
		btnGo_2:setTouchEnabled(true)	
		Text_or:setVisible(true)
		Image_buy:setVisible(true)
		self.Text_need_1:setColor(cc.c3b(254,36,27))
		self.Text_need_2:setColor(cc.c3b(254,36,27))
	end
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
end

--把解锁的数据写到数据库
function UICopyUnlock:setUnlockCopyData()
	local tb = DataMap:getUnlockIdTb()
	table.insert(tb,DataMap:getPass())
	DataMap:setUnlockIdTb(tb)
	UIManager:close(self)
	EventDispatcher:post(EventDef["ED_UPDATA_COPY_BTN"], self.unLockCopyId)
	UIManager:openFront(UICopyInfo, true)
end

function UICopyUnlock:onTouch(touch, event, eventCode)
end

function UICopyUnlock:onUpdate(dt)
end

function UICopyUnlock:onDestroy()
	
end

