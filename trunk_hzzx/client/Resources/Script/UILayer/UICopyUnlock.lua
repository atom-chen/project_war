----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-5
-- Brief: 副本需要解锁条件界面
----------------------------------------------------------------------
UICopyUnlock = {
	csbFile = "CopyUnlock.csb"
}

function UICopyUnlock:onStart(ui, param)
	
	AudioMgr:playEffect(2007)
	self.unLockCopyId = param.unLockCopyId
	local unlockInfo = DataLevelInfo:getUnlockCopyInfo()
	--需要的英雄个数
	self.Text_need_1 = UIManager:seekNodeByName(ui.root, "Text_need_1")
	self.Text_need_1:setString(LanguageStr("COPY_UNLOCK_1",unlockInfo[2]))
	--需要的英雄等级
	self.Text_need_2 = UIManager:seekNodeByName(ui.root, "Text_need_2")
	self.Text_need_2:setString(LanguageStr("COPY_UNLOCK_2",unlockInfo[2],unlockInfo[1]))
	--解锁关卡需要消耗的人民币
	self.Text_money = UIManager:seekNodeByName(ui.root, "Text_money")
	self.Text_money:setString(LanguageStr("COPY_UNLOCK_MONEY",G.COPY_UNLOCK_MONEY))
	-- 英雄个数足够图片
	local fullImg_1 = UIManager:seekNodeByName(ui.root, "full_1")
	-- 英雄的等级足够图片
	local fullImg_2 = UIManager:seekNodeByName(ui.root, "full_2")
	
	-- 解锁按钮放大区域
	local btnUnlockBg = UIManager:seekNodeByName(ui.root, "Button_unlock_bg")
	Utils:addTouchEvent(btnUnlockBg, function(sender)
		if DataLevelInfo:canUnlock(DataLevelInfo:getUnlockCopyInfo()) then		--可以解锁
			self:setUnlockCopyData()
			return
		end
		btnUnlockBg:setTouchEnabled(false)
		local tbData = {
			["product_name"]	= LanguageStr("COPY_UCLOCK_TITLE"),			-- 产品名称
			["total_fee"]		= G.COPY_UNLOCK_MONEY,						-- 订单金额
			["product_desc"]	= LanguageStr("COPY_UCLOCK_DESC"),			-- 订单描述
			["product_id"]		= "copy_unlock_finish",						-- 订单ID
			["tycode"]			= G.COPY_UCLOCK_PAY_TY_CODE or "0",	-- 天翼支付码
			["ltcode"]			= G.COPY_UCLOCK_PAY_LT_CODE or "0",	-- 联通支付码
			["ydcode"]			= G.COPY_UCLOCK_PAY_YD_CODE or "0",	-- 移动支付码
			["ascode"]			= "0",								-- AppStore支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(btnUnlockBg) then
				btnUnlockBg:setTouchEnabled(true)
			end
			self:setUnlockCopyData()
			ChannelProxy:recordPay(G.COPY_UNLOCK_MONEY, "0",LanguageStr("COPY_UCLOCK_TITLE"))
			ChannelProxy:recordCustom("stat_buy_copy_unlock")
		end
		local function fnBuyFailHandler()
			if not isNil(btnUnlockBg) then
				btnUnlockBg:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 0)
	
	-- 解锁按钮
	local btnUnlock = UIManager:seekNodeByName(ui.root, "Button_unlock")
	Utils:addTouchEvent(btnUnlock, function(sender)
		if DataLevelInfo:canUnlock(DataLevelInfo:getUnlockCopyInfo()) then		--可以解锁
			self:setUnlockCopyData()
			return
		end
		btnUnlock:setTouchEnabled(false)
		local tbData = {
			["product_name"]	= LanguageStr("COPY_UCLOCK_TITLE"),			-- 产品名称
			["total_fee"]		= G.COPY_UNLOCK_MONEY,						-- 订单金额
			["product_desc"]	= LanguageStr("COPY_UCLOCK_DESC"),			-- 订单描述
			["product_id"]		= "copy_unlock_finish",						-- 订单ID
			["tycode"]			= G.COPY_UCLOCK_PAY_TY_CODE or "0",	-- 天翼支付码
			["ltcode"]			= G.COPY_UCLOCK_PAY_LT_CODE or "0",	-- 联通支付码
			["ydcode"]			= G.COPY_UCLOCK_PAY_YD_CODE or "0",	-- 移动支付码
			["ascode"]			= "0",								-- AppStore支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(btnUnlock) then
				btnUnlock:setTouchEnabled(true)
			end
			self:setUnlockCopyData()
			ChannelProxy:recordPay(G.COPY_UNLOCK_MONEY, "0",LanguageStr("COPY_UCLOCK_TITLE"))
			ChannelProxy:recordCustom("stat_buy_copy_unlock")
		end
		local function fnBuyFailHandler()
			if not isNil(btnUnlock) then
				btnUnlock:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 0)
	
	if #DataMap:getHeroIds() >= unlockInfo[2] then	--解锁的英雄够了
		fullImg_1:setVisible(true)
		self.Text_need_1:enableOutline(cc.c4b(119,62,7,255),3)
		self.Text_need_1:setColor(cc.c3b(255,255,255))
		self.Text_need_1:enableOutline(cc.c4b(119,62,7,255),3)
		if DataLevelInfo:canUnlock(DataLevelInfo:getUnlockCopyInfo()) then	--解锁的英雄等级够了
			fullImg_2:setVisible(true)
			self.Text_need_2:setColor(cc.c3b(255,255,255))
			self.Text_need_2:enableOutline(cc.c4b(119,62,7,255),3)
		else
			fullImg_2:setVisible(false)
			self.Text_need_2:setColor(cc.c3b(254,36,27))
		end
	else	--解锁的英雄不够
		fullImg_1:setVisible(false)
		fullImg_2:setVisible(false)
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
	cclog("self.unLockCopyId", self.unLockCopyId)
	EventDispatcher:post(EventDef["ED_UPDATA_COPY_BTN"], self.unLockCopyId)
	UIManager:openFront(UICopyInfo, true)
end

function UICopyUnlock:onTouch(touch, event, eventCode)
end

function UICopyUnlock:onUpdate(dt)
end

function UICopyUnlock:onDestroy()
	
end

