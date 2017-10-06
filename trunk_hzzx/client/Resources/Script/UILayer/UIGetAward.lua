----------------------------------------------------------------------
-- Author: lhq
-- Date: 2015-2-2
-- Brief: 抽取奖励界面
----------------------------------------------------------------------
UIGetAward = {
	csbFile = "GetAward.csb"
}

local mThreeDia = 15
--获取当前抽到的物品的信息
function UIGetAward:setClearFlag(flag)
	self.clearFlag = flag
end

--获取当前抽到的物品的信息
function UIGetAward:getClearFlag()
	return self.clearFlag
end

--清楚动画信息
function UIGetAward:ClearAction()
	UIGetAward:setClearFlag(true)
	for i = 1,3,1 do
		for j=1,3,1 do
			local closeBox = UIManager:seekNodeByName(self.root, "box_"..i.."_"..j)
			local iconBg = UIManager:seekNodeByName(self.root, "balloon_"..i.."_"..j)
			local amountText =  UIManager:seekNodeByName(self.root, "amountText_"..i.."_"..j)
			if closeBox ~= nil then 	closeBox:stopAllActions() end	
			if iconBg ~= nil then 	iconBg:stopAllActions()  end	
			if amountText ~= nil then	amountText:stopAllActions() end	
		end
	end
	self.Panel_root:removeAllChildren()
end

--从九个箱子中获取随机的一到三个数
function UIGetAward:getRandomArr()
	local number = math.random(3)
	local temp = CommonFunc:clone(self.arr)
	local temp1 = CommonFunc:clone(temp)
	local tb = {}
	for i = 1,number,1 do
		local new = CommonFunc:getRandom(temp)
		table.insert(tb,new)
		for key,val in pairs(temp) do
			if tostring(new) == tostring(val) then
				table.remove(temp1,key)				--temp1[key] = nil
			end
		end
	end
	return tb
end

--每隔几秒掉一次晃动动画
function UIGetAward:foreverShakeAction()	--
	self.root:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2), 
		cc.CallFunc:create(function()
			self:action_box()
		end))))
end

--创建抽奖的背景
function UIGetAward:createRewardBg()
	UIGetAward:ClearAction()
	self.arr = {"1_1","1_2","1_3","2_1","2_2","2_3","3_1","3_2","3_3"}
	--动画效果是，九个箱子渐现出来，随机一到三个动起来，点击后箱子变成打开的，东西渐现飞上去
	for i = 1,3,1 do
		for j=1,3,1 do
			--关闭的箱子
			local iconBg = ccui.ImageView:create()	
			iconBg:loadTexture("close_box.png")
			iconBg:setTouchEnabled(false)
			iconBg:setName("box_"..i.."_"..j)
			local x = 83 +170*(j-1)
			local y = 417-170*(i-1)
			iconBg:setPosition(cc.p( x,y))
			iconBg:setAnchorPoint(cc.p(0.5,0.5))
			--self.Panel_root:addChild(iconBg)
			iconBg:setOpacity(0)
			if i == 2 and j == 2 then
				self.Panel_root:addChild(iconBg,0)
			else
				self.Panel_root:addChild(iconBg,(3*(i-1)+j)*100)
			end		
			--气泡
			local bubbleBg = ccui.ImageView:create()	
			bubbleBg:loadTexture("reward_bubble.png")
			bubbleBg:setTouchEnabled(false)
			bubbleBg:setName("balloon_"..i.."_"..j)
			bubbleBg:setPosition(cc.p( 62.71,50.71))
			bubbleBg:setAnchorPoint(cc.p(0.5,0.5))
			iconBg:addChild(bubbleBg)

			if i==3 and j == 3 then
				iconBg:runAction(cc.Sequence:create(cc.FadeIn:create(1.5),cc.CallFunc:create(function()
					bubbleBg:setTouchEnabled(true)	--渐入动画完后，才能点击
					self:foreverShakeAction()
				end)))
			else
				iconBg:runAction(cc.Sequence:create(cc.FadeIn:create(1.5),cc.CallFunc:create(function()
					bubbleBg:setTouchEnabled(true)
				end)))
			end
			bubbleBg:addTouchEventListener( function( _sender, _type ) 
				if _type == 2 then  
					local curKey = ItemModel:getTotalKey()
					if curKey <= 0 then
						self:shakeAction02(iconBg)
						self.Panel_diamond:stopAllActions()
						self.Panel_diamond:setScale(1.0)
						self.Panel_diamond:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,1.0)))
						
						if (GuideMgr:isLotteryOpen() == true) then
							UIManager:openFront(UIBuyKeys,true)
						end
						return
					end
					DataLevelInfo:setRewardClickTimes(DataLevelInfo:getRewardClickTimes() + 1)
					_sender:setTouchEnabled(false)
					ItemModel:appendTotalKey(-1)
					--为随机动的tb重新赋值
					local name = _sender:getName()
					local strIndex = string.sub(name,string.len(name) - 2,string.len(name))
					local temp =  CommonFunc:clone(self.arr)
					for key,val in pairs(self.arr) do
						if val == strIndex then
							table.remove(temp,key)
						end
					end
					self.arr = temp
					
					--创建一个钥匙，钥匙飞到对应的位置
					local rewardKey = UIManager:seekNodeByName(self.root, "Image_reward_key")
					local startPos = rewardKey:getWorldPosition()
					local newKeyIcon = ccui.ImageView:create("key_01.png")
					newKeyIcon:setAnchorPoint(cc.p(0, 0))
					newKeyIcon:setPosition(cc.p(0,0))
					rewardKey:addChild(newKeyIcon)
					local endPos = iconBg:getWorldPosition()
					local action1 = cc.MoveBy:create(0.2, cc.pSub(endPos, startPos))
					newKeyIcon:runAction(cc.Sequence:create(action1, cc.CallFunc:create(function()
						newKeyIcon:setVisible(false)
						newKeyIcon:removeFromParent()
						--气泡的粒子效果
						bubbleBg:setVisible(false)
						local particleNode = cc.ParticleSystemQuad:create("bubbleexplode.plist")
						particleNode:setPosition(cc.p(63,51))
						particleNode:setAnchorPoint(cc.p(0.5,0.5))
						iconBg:addChild(particleNode)
						iconBg:loadTexture("open_box.png")
						iconBg:stopAllActions()
						AudioMgr:playEffect(2009)
						--产出的礼物
						local rewardIcon = ccui.ImageView:create()	
						rewardIcon:setTouchEnabled(false)
						rewardIcon:setName("reward_"..i.."_"..j)
						rewardIcon:setPosition(cc.p( 57.99,81))
						rewardIcon:setAnchorPoint(cc.p(0.5,0.5))
						iconBg:addChild(rewardIcon,0)
						AudioMgr:playEffect(2013)
						local amountText = ccui.TextBMFont:create()
						amountText:setFntFile("font_05.fnt")
						amountText:setString("")
						amountText:setAnchorPoint(cc.p(0,0.5))
						amountText:setName("amountText_"..i.."_"..j)
						amountText:setPosition(cc.p(57, 61.5))
						iconBg:addChild(amountText,0)
						amountText:setScale(0.5)
						--amountText:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.0)))
						
						--把抽取到的物品写入数据库
						local tempTb = DataLevelInfo:getOnlyOneReward()
						local finalId ,awardPondId,awardPondInfo,itemInfo = tempTb[1],tempTb[2],tempTb[3],tempTb[4]
						if awardPondInfo == nil then
							UIPrompt:show(LanguageStr("GOAL_TIP_2",finalId,awardPondId)) 
							return
						end
						DataLevelInfo:setOneTime(finalId,awardPondId,awardPondInfo,itemInfo)
						--需要传给英雄或礼包界面的信息
						--local itemInfo = DataLevelInfo:getRewardIconInfo(finalId)
						local tb = {rewardIcon,amountText,itemInfo,finalId,
							awardPondId,awardPondInfo,3*(i-1)+j,DataLevelInfo:getGetAwardTimes() + 1}
							
						local rewardModelData = GetRewardModel:getRewardNeedData()
						table.insert(rewardModelData,(3*(i-1)+j),tb)
						local curData = rewardModelData[3*(i-1)+j]
						local temp_1,temp_2,temp_3,temp_4,temp_5,temp_6,temp_7,temp_8 = 
						curData[1],curData[2],curData[3],curData[4],curData[5],curData[6],curData[7],curData[8]
						
						if itemInfo.award_type == 1 then			--物品
							rewardIcon:loadTexture(itemInfo.image)
							--UIPrompt:show("你获得11111******"..itemInfo.name..itemInfo.count)
							amountText:setString("x"..itemInfo.count)
							rewardIcon:setVisible(false)
							amountText:setVisible(false)
							UIMiddlePub:getAwardFlyAction(temp_1,temp_2,temp_3,temp_4,temp_5,temp_6,temp_8)
							--self:reward_number_action(amountText)
							return
						end
						
						if itemInfo.award_type == 3 then			--礼包
							rewardIcon:loadTexture(itemInfo.image)
							GetRewardModel:setOpenBag(true)
						elseif itemInfo.award_type == 2 then		--英雄
							GetRewardModel:setOpenHero(true)
							local node = Utils:createArmatureNode(itemInfo.display)
							node:setPosition(cc.p(34,11))
							node:setAnchorPoint(cc.p(0.5,0.5))
							rewardIcon:loadTexture("touming.png")
							rewardIcon:addChild(node)
						end
						amountText:setString(itemInfo.count)
						amountText:setVisible(false)
						UIGetAward:iconFlyAction(temp_1,temp_2,temp_3,temp_4,temp_5,temp_6,rewardModelData[3*(i-1)+j])
						--self:reward_number_action(amountText)
					end)))
					AudioMgr:playEffect(2008)
				end
			end)
		end
	end
	UIGetAward:setClearFlag(false)
end

--抽奖物品个数隐藏动画
function UIGetAward:reward_number_action(node)
	local function CallFucnCallback3()
		node:setVisible(false)
	end
	node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1.0),cc.CallFunc:create(CallFucnCallback3)))
end

--箱子摇晃动画
function UIGetAward:action_box()
	local actionTb = self:getRandomArr()
	for key,val in pairs(actionTb) do
		local box = UIManager:seekNodeByName(self.root, "box_"..val)
		box:setTouchEnabled(true)
		self:shakeAction01(box)
	end
end

--箱子摇晃动画
function UIGetAward:shakeAction02(node, shakeCF, param)
	if nil == node then return end
	local shakeActionArray = {}
	local duration = 0.25
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.1, 0.9))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.95, 1.05))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.04, 0.96))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.98, 1.02))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.02, 0.98))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.99, 1.01))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1, 1))
	return node:runAction(cc.Sequence:create(shakeActionArray))
end

--箱子摇晃动画
function UIGetAward:shakeAction01(node, shakeCF, param)
	if nil == node then return end
	--node:stopAllActions()
	local shakeActionArray = {}
	local duration = 0.25
	table.insert(shakeActionArray, cc.FadeIn:create(0.5))
	table.insert(shakeActionArray,cc.DelayTime:create(2))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.1, 0.9))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.95, 1.05))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.04, 0.96))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.98, 1.02))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.02, 0.98))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.99, 1.01))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1, 1))
	--table.insert(shakeActionArray, cc.DelayTime:create(1))
	table.insert(shakeActionArray, cc.CallFunc:create(function()
		node:setOpacity(255)
		node:stopAllActions()	
	end))
	return node:runAction(cc.Sequence:create(shakeActionArray))
end

--抽取到的礼包，英雄飞的动画
function UIGetAward:iconFlyAction(iconWidget,textWidget,itemInfo,finalId,awardPondId,awardPondInfo,tempTb)
	iconWidget:setScale(0.5)
	action2 = cc.ScaleTo:create(0.5, 1.0)
	
	local function CallFucnCallback2()
		iconWidget:setVisible(false)
		if	itemInfo.award_type == 3 then	--礼包
			UIManager:addDelay(UIItemInfo,tempTb)
			UIManager:popDelay()
			AudioMgr:playEffect(2014)
		elseif 	itemInfo.award_type == 2 then --英雄
			UIManager:addDelay(UIRewardHeroInfo,tempTb)
			UIManager:popDelay()
			AudioMgr:playEffect(2014)
		else
			cclog("我不应该进来了*************，类型不对啊",itemInfo.award_type)
		end
	end
	action4 = cc.Sequence:create(action2,cc.CallFunc:create(CallFucnCallback2))
	iconWidget:runAction( action4)
end

--获取当前抽到的物品的信息
function UIGetAward:getCurGetAwardInfo()
	return self.getAwardInfo,self.iconBg,self.amountText,self.finalId,self.awardPondId,self.awardPondInfo 
end

--购买panel放大缩小的动画
function UIGetAward:buyBtnAction()
	self.Button_buyKey:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4,0.9), 
		cc.ScaleTo:create(0.4,1.0))))
end


--购买钥匙后，刷新界面
function UIGetAward:refuseBuyKeysUI()
	ItemModel:appendTotalKey(G.ADD_KEYS)
	self.Text_keyNumber:setString(ItemModel:getTotalKey())
	
	UIGetAward:refreshDiamondUI(ItemModel:getTotalKey())
	UIGetAward:setMiddleBackBtn(ItemModel:getTotalKey())
end

function UIGetAward:onStart(ui, param)
	AudioMgr:playEffect(2007)
	GetRewardModel:updateRewardInfo()
			
	self.Panel_root = UIManager:seekNodeByName(ui.root, "Panel_balloon")
	UIGetAward:createRewardBg()
	Utils:autoChangePos(self.Panel_root)

	local needDiamond = mThreeDia	--G.ADD_KEYS*G.KEY_PRICE
	local curKey = ItemModel:getTotalKey()
	
	--钥匙的个数
	self.Text_keyNumber = UIManager:seekNodeByName(ui.root, "Text_keyNumber")
	self.Text_keyNumber:setString(curKey)
	Utils:autoChangePos(self.Text_keyNumber)
	--钥匙图片
	self.Image_reward_key = UIManager:seekNodeByName(self.root, "Image_reward_key")
	
	--购买panel
	self.Panel_diamond = UIManager:seekNodeByName(ui.root, "Panel_diamond")
	Utils:autoChangePos(self.Panel_diamond)
	--砖石的个数
	--self.Text_needDiamond = UIManager:seekNodeByName(ui.root, "Text_needDiamond")
	--self.Text_needDiamond:setString(needDiamond)
	self.Button_buyKey = UIManager:seekNodeByName(ui.root, "Button_buyKey_Copy")
	
	UIGetAward:refreshDiamondUI(curKey)
	
	Utils:addTouchEvent(self.Button_buyKey, function(sender)
		UIManager:openFront(UIBuyKeys,true)
	end, true, true, 0)
end

--刷新购买砖石的UI
function UIGetAward:refreshDiamondUI(curKey)
	if nil == self.root then
		return
	end
	if curKey > 0 or (not GuideMgr:isLotteryOpen() and curKey == 0) then		--新手的时候，购买按钮不显示
		self.Text_keyNumber:setVisible(true)
		self.Panel_diamond:setVisible(false)
		self.Image_reward_key:setVisible(true)
		self.Button_buyKey:setTouchEnabled(false)
		self.Text_keyNumber:setString(curKey)
		self.Button_buyKey:stopAllActions()
	else
		self.Text_keyNumber:setVisible(false)
		self.Panel_diamond:setVisible(true)
		self.Image_reward_key:setVisible(false)
		self.Button_buyKey:setTouchEnabled(true)
		self:buyBtnAction()
	end
end

--设置九个icon可否点击
function UIGetAward:setNineTouch(flag)
	for i = 1,3,1 do
		for j=1,3,1 do
			local icon =  UIManager:seekNodeByName(self.root, ("balloon_"..i.."_"..j))
			icon:setTouchEnabled(flag)
		end
	end
end

--根据钥匙的个数，显示和隐藏主界面返回按钮
function UIGetAward:setMiddleBackBtn(key)
	if key <= 0 and UIManager:isLayerOpen(UIGetAward)then
		UIMiddlePub:showBackBtn(true)
		UIMiddlePub:backScaleAction()
	else
		UIMiddlePub:showBackBtn(false)
	end
end

function UIGetAward:onTouch(touch, event, eventCode)
	
end

function UIGetAward:onUpdate(dt)
end

function UIGetAward:onDestroy()
	DataLevelInfo:setGetAwardTimes(0)
	--设置点击抽奖点击次数
	DataLevelInfo:setRewardClickTimes(0)
	GetRewardModel:setLevelTimesInfo(DataMap:getLevelOneInfo())
	UIMiddlePub:getCollectNumberBall():stopAllActions()
	UIMiddlePub:getCollectNumberCookie():stopAllActions()
	UIMiddlePub:getCollectNumberDiamond():stopAllActions()
	UIMiddlePub:getCollectNumberBall():setString(ItemModel:getTotalBall())
	UIMiddlePub:getCollectNumberCookie():setString(ItemModel:getTotalCookie())
	UIMiddlePub:getCollectNumberDiamond():setString(ItemModel:getTotalDiamond())
end

