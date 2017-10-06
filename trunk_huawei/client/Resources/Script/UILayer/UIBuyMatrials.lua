----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-29
-- Brief: 材料购买界面
----------------------------------------------------------------------
UIBuyMatrials = {
	csbFile = "BuyMaterial.csb"
}

function UIBuyMatrials:onStart(ui, param)
	AudioMgr:playEffect(2007)
	local tempBall,tempCookie =UIHeroInfo:getNeedMaterials()
	if tempBall <= 0 then
		tempBall = 0
	elseif tempCookie <0 then
		tempCookie = 0
	end
	--需要的毛球数
	self.Text_ball = UIManager:seekNodeByName(ui.root, "Text_ball")
	self.Text_ball:setString(tempBall)
	--需要的饼干数
	self.Text_cookie = UIManager:seekNodeByName(ui.root, "Text_cookie")
	self.Text_cookie:setString(tempCookie)
	
	--需要的砖石数
	self.Text_diamond = UIManager:seekNodeByName(ui.root, "Text_diamond")
	local diamondNumber = tempBall* G.BALL_PRICE + tempCookie*G.KEY_PRICE
	if diamondNumber < 1 then
		diamondNumber = 1
	else
		diamondNumber = math.floor(diamondNumber)
	end
	self.Text_diamond:setString(diamondNumber)
	--购买材料
	local buyMaterial = UIManager:seekNodeByName(ui.root, "Button_yes")
	Utils:addTouchEvent(buyMaterial, function(sender)
		if ItemModel:getTotalDiamond() < diamondNumber then
		
			ChannelProxy:getStrInfo("shop", function(productTb)
				if 0 == #productTb then
					UIPrompt:show(LanguageStr("QURERY_FAIL"))
				else
					UIManager:openFront(UIBuyDiamond,true,{["enter_mode"] ="buy",["diamondNumber"] = diamondNumber, ["product_tb"]=productTb})
				end
			end)
			
			return
		end
		local oldBall = ItemModel:getTotalBall()
		local newBall = oldBall + tempBall
		local oldCookie = ItemModel:getTotalCookie()
		local newCookie = oldCookie + tempCookie
		if oldBall ~= newBall then
			ItemModel:appendTotalBall(newBall - oldBall)
			local tb = {}
			tb.itemType = ItemType["ball"] 
			tb.oldAmount = oldBall
			tb.newAmount = newBall
			tb.flag = SignType["reduce"]
			EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
		end
		if oldCookie ~= newCookie then
			ItemModel:appendTotalCookie(newCookie - oldCookie)
			local tb = {}
			tb.itemType = ItemType["cookie"] 
			tb.oldAmount = oldCookie
			tb.newAmount = newCookie
			tb.flag = SignType["reduce"]
			EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 	
		end

		local oldDiamond = ItemModel:getTotalDiamond()
		local newDiamond = oldDiamond - diamondNumber
		ItemModel:appendTotalDiamond(-diamondNumber)
		local tb = {}
		tb.itemType = ItemType["dia"] 
		tb.oldAmount = oldDiamond
		tb.newAmount = newDiamond
		tb.flag = SignType["reduce"]
		EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
		
		UIHeroInfo:clickGrowBtn()
		if GuideMgr:isUIGuideOpen() then
			GuideUI:parseUIStep()
			DataMap:setUIGuideInfo({6})
			UIHero:setPageViewScroll(true)
		end
		UIManager:close(self)
	end, true, true, 0)
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	if GuideMgr:isUIGuideOpen() then
		GuideUI:parseUIStep()
		local xPos, yPos = ui.node:getPosition()
		ui.node:setPosition(cc.p(xPos, yPos + 80))
	end
end

function UIBuyMatrials:onTouch(touch, event, eventCode)
end

function UIBuyMatrials:onUpdate(dt)
end

function UIBuyMatrials:onDestroy()
	
end

