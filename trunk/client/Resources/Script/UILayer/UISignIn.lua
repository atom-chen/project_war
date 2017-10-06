----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-7-28
-- Brief: 每日签到界面
----------------------------------------------------------------------
UIDEFINE("UISignIn", "SignIn.csb")
function UISignIn:onStart(ui, param)
	--Log(STime:getClientDate())
	--Log(self.signTb)
	self.rootNode = ui.root
	-- 从签到表获取的数据
	self.signTbData = LogicTable:getAll("signin_tplt")			
	--关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
	--连续登录天数
	self.text_conDays = self:getChild("Text_ContinueDays")
	self.text_conDays:setString(LanguageStr("SIGNIN_DES"))
	self.textDays = self:getChild("bit_day")
	--底板
	self.Image_gray = self:getChild("Image_gray")
	self.Image_gray:setVisible(true)
	self.Image_gray:setOpacity(0)
	--领取按钮
	self.btnSignIn = self:getChild("Button_signIn")
	--初始化界面
	self:initSignUI()
	--背景猫转的动画
	local Image_light = self:getChild("Image_light")
	local Image_cat = self:getChild("Image_cat")
	Image_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.6,30)))
	Image_light:setOpacity(0)
	Image_light:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
	Image_cat:setScale(0.2)
	Image_cat:setOpacity(0)
	Image_cat:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.ScaleTo:create(0.1, 1.2),
						cc.ScaleTo:create(0.2, 1.0)))
end
------------------------------------领取动画-----------------------------------------------------
--领取奖励动画
function UISignIn:receiveAwardAnimation(length)
	--设置奖励物品的信息
	local itemInfo = ModelLevelLottery:getRewardIconInfo(self.signTbData[length].reward_id)	
	self:setDataByAward(itemInfo)
	--奖励物品动画
	local iconWidget = self:getChild("icon_"..length)		-- 赠送礼品图标
	iconWidget:setVisible(false)
	--if itemInfo.award_type == 2 then
		--local heroNode = self:getChild("node_"..length)		-- 赠送礼品图标
		--heroNode:setVisible(false)
	--end	
	self:awardFlyAction(iconWidget ,itemInfo , length)		-- 这里没有添加个数?????
end

--根据礼物信息，获得要飞到的位置
function UISignIn:getNewPosByItemInfo(itemInfo)
	local x1,y1,x2,y2,x3,y3,x4,y4,x5,y5 = UIMiddlePub:getCollectPos()
	print("UISignIn:getNewPosByItemInfo************",x1,y1,x2,y2,x3,y3,x4,y4,x5,y5)
	local new_X,new_y = 0,0
	local iconStr = "touming.png"
	local types = UIMiddlePub:getItemTypeById(itemInfo.id)
	if types == ItemType["ball"] then	    -- 毛球	-- 毛球包
		new_X,new_y = x1,y1
	elseif types == ItemType["cookie"] then	-- 饼干	-- 饼干包
		new_X,new_y = x2,y2
	elseif types == ItemType["dia"] then	-- 钻石 -- 钻石包
		new_X,new_y = x3,y3
	elseif types == ItemType["power"] or types == ItemType["maxpower"] then	-- 体力 -- 体力上限	
		new_X,new_y = x4,y4
	end
	if itemInfo.award_type == 2 then					--英雄
		new_X,new_y = x5,y5
	end
	return new_X,new_y
end

--签到奖励图片飞的函数
function UISignIn:awardFlyAction(iconWidget,itemInfo,length)
	--Log("UISignIn:awardFlyAction***********",itemInfo)
	local new_X,new_y = self:getNewPosByItemInfo(itemInfo)
	local old_x = iconWidget:getWorldPosition().x
	local old_y = iconWidget:getWorldPosition().y
	local baseTime = 0.8
	local baseScale = self.signTbData[length].scale*2
	local delayTime = baseTime
	--灰色遮罩(画面变暗动画)
	self.Image_gray:setTouchEnabled(true)
	--旋转的光线
	local Image_radiao = self:getChild("Image_radio")
	Image_radiao:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.0,60)))
	Image_radiao:setScale(0.1*baseScale)
	Image_radiao:setOpacity(0)
	
	if itemInfo.award_type == 2 then
		delayTime = baseTime + 1.4
	end
	local function CallFucnCallback5()
		Image_radiao:setVisible(true)
		local function CallFucnCallback1()
			self.Image_gray:runAction(cc.Sequence:create(cc.FadeOut:create(0.1),cc.CallFunc:create(function()
						self.Image_gray:setTouchEnabled(false)
					end)))
		end
		Image_radiao:runAction(cc.Sequence:create(
								cc.FadeIn:create(0.1),
								--cc.ScaleTo:create(0.1,0.45*baseScale),
								cc.ScaleTo:create(0.1, 0.5*baseScale),
								cc.DelayTime:create(delayTime),
								cc.CallFunc:create(CallFucnCallback1) 
								))										
	end
	
	self.Image_gray:runAction(cc.Sequence:create(cc.FadeIn:create(baseTime),
												--cc.DelayTime:create((baseTime )),
												cc.CallFunc:create(CallFucnCallback5)))
	
	--创建Icon
	local panel = self:getChild("Panel_1")
	local newFlyIcon
	if itemInfo.award_type == 2 then	--英雄
		newFlyIcon = Utils:createArmatureNode(itemInfo.display,"idle",false)
		newFlyIcon:setAnchorPoint(cc.p(0.5,0.5))
		newFlyIcon:setPosition(cc.p(old_x + (G.DESIGN_WIDTH - G.VISIBLE_SIZE.width)/2 ,old_y))
		panel:addChild(newFlyIcon,100)
	else								--抽奖物品
		newFlyIcon = ccui.ImageView:create()	
		newFlyIcon:loadTexture(itemInfo.image)
		newFlyIcon:setPosition(cc.p(old_x + (G.DESIGN_WIDTH - G.VISIBLE_SIZE.width)/2 ,old_y))
		newFlyIcon:setAnchorPoint(cc.p(0.5,0.5))
		panel:addChild(newFlyIcon,100000)
	end
	newFlyIcon:setScale((self.signTbData[length].scale))
	--创建个数名字
	local amountBg,amountText
	amountBg = ccui.Scale9Sprite:create("frame_04.png")
	amountBg:setContentSize(cc.size(90,23))
	amountBg:setPosition(cc.p(360,380))
	if itemInfo.award_type == 2 then	--英雄
		amountBg:setPosition(cc.p(360,350))
	end
	amountBg:setAnchorPoint(cc.p(0.5,0.5))
	local numberText = ccui.Text:create(itemInfo.name.."*"..itemInfo.count, "", 15)
	numberText:setPosition(cc.p(45, 12))
	numberText:setColor(cc.c3b(255,255,255))
	numberText:setAnchorPoint(cc.p(0.5,0.5))
	amountBg:addChild(numberText)
	panel:addChild(amountBg)
	amountBg:setVisible(false)
	local temp =  (G.DESIGN_WIDTH - G.VISIBLE_SIZE.width)/2
	local cfg = {
		cc.p(old_x + temp, old_y ),
		cc.p(old_x + (new_X - old_x)*2/3,old_y + (new_y - old_y)*1/3),
		cc.p(G.DESIGN_WIDTH/2, G.DESIGN_HEIGHT/2)
	}
	
	newFlyIcon:runAction(cc.Spawn:create(cc.ScaleTo:create(baseTime, baseScale),
			Actions:bezierTo(newFlyIcon, cfg, baseTime, function()
				amountBg:setVisible(true)
				local function CallFucnCallback2()
					if itemInfo.award_type == 2 then
						DataHeroInfo:setUnlockHeroTb(itemInfo.id)
						DataHeroInfo:setSelectHeroId(itemInfo.id,false)
						DataHeroInfo:getSelectHeroId()	
						DataHeroInfo:init()		--再一次初始化英雄数据
					else
						UIMiddlePub:loadChangeAction(0,0,{},itemInfo,false)
					end
					newFlyIcon:removeFromParent()
				end
				
				local function CallFucnCallback4()
					self:close()
				end
				
				local function CallFucnCallback3()
					--戳章动画
					local cover = self:getChild("cover_"..length)		
					cover:setVisible(true)
					self.rootNode:reorderChild(cover,1000000)
					cover:setOpacity(0)
					cover:loadTexture("text_receive.png")	--cc.DelayTime:create(0.5),
					cover:setScale(5.0)
					cover:runAction(cc.Sequence:create( 
						cc.FadeIn:create(0.01),				
						cc.ScaleTo:create(0.1, 1.0),
						cc.DelayTime:create(1.0),	
						cc.CallFunc:create(CallFucnCallback4)
					))	
				end
				
				local function CallFucnCallback1()
					amountBg:setVisible(false)
				end
				
				local action1 = cc.Spawn:create(cc.MoveTo:create(0.5,cc.p(new_X + temp,new_y  )),
												cc.ScaleTo:create(0.5, baseScale*0.5))
				if itemInfo.award_type == 2 then
					Utils:playArmatureAnimation(newFlyIcon, "win", false,function(armatureBack, movementType, movementId)
						if ccs.MovementEventType.complete == movementType and "win" == movementId then
							amountBg:setVisible(false)
							newFlyIcon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),
															cc.FadeOut:create(0.2)))
							newFlyIcon:runAction(cc.ScaleTo:create(0.5, baseScale*0.5))
							newFlyIcon:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(new_X + temp ,new_y )),
															cc.CallFunc:create(CallFucnCallback2),
															cc.CallFunc:create(CallFucnCallback3)))
						end
					end)
				else
					newFlyIcon:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),
															cc.FadeOut:create(0.2)))
					newFlyIcon:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
															cc.CallFunc:create(CallFucnCallback1),action1,
															cc.CallFunc:create(CallFucnCallback2),
															cc.CallFunc:create(CallFucnCallback3)))
				end
			end)		
		))		
end

--根据礼物类型，设置对应的数据
function UISignIn:setDataByAward(itemInfo)
	if itemInfo.award_type == 1 or itemInfo.award_type == 3 then 
		local types = UIMiddlePub:getItemTypeById(itemInfo.id)
		if types == ItemType["ball"]  then				-- 毛球 -- 毛球包			
			ModelItem:appendTotalBall(itemInfo.count)
		elseif  types == ItemType["cookie"] then		-- 饼干
			ModelItem:appendTotalCookie(itemInfo.count)
		elseif types == ItemType["dia"] then			-- 钻石 -- 钻石包
			ModelItem:appendTotalDiamond(itemInfo.count)	
		elseif types == ItemType["power"] then			-- 体力(做动画的时候处理体力与体力上限)
		elseif types == ItemType["maxpower"] then		-- 体力上限
		elseif types == ItemType["key"] then			-- 钥匙
		end
	elseif itemInfo.award_type == 2 then			--抽取到的是英雄需要特殊判断
		DataHeroInfo:setUnlockHeroTb(itemInfo.id)
		DataHeroInfo:setSelectHeroId(itemInfo.id,false)
		DataHeroInfo:getSelectHeroId()
	end	
end
-------------------------------------------------------------------------------------------------
function UISignIn:onTouch(touch, event, eventCode)
end

function UISignIn:onUpdate(dt)
end

function UISignIn:onDestroy()
	self.rootNode = nil
end
------------------------------------界面信息-----------------------------------------------------
--初始化界面信息
function UISignIn:initSignUI()
	if self.rootNode == nil then return end
	self.signTb = ModelSignIn:getSignTb()
	self.textDays:setString(#self.signTb)
	self:initSevenItem()
	self:initBtn()
end

--设置按钮灰态
function UISignIn:setGrayBtn()
	self.btnSignIn:setTouchEnabled(false)
	-- 图片有待修改
	self.btnSignIn:loadTextures("public_red_btn_gray.png", "public_red_btn_gray.png", "public_red_btn_gray.png")
	local btnSignInTip = self:getChild("text_get")
	btnSignInTip:loadTexture("text_get_gray.png")
end

--初始化领取按钮
function UISignIn:initBtn()
	if ModelSignIn:isTodaySignIn() == true  then		--按钮的状态有待处理
		self:setGrayBtn()
	else
		self.btnSignIn:setTouchEnabled(true)
		self.btnSignIn:loadTextures("public_blue_btn.png", "public_blue_btn.png", "public_blue_btn.png")
		local btnSignInTip = self:getChild("text_get")
		btnSignInTip:loadTexture("text_get.png")
		self.btnSignIn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4,0.9), 
		cc.ScaleTo:create(0.4,1.0))))
		self:addTouchEvent(self.btnSignIn, function(sender)
			self.btnSignIn:stopAllActions()
			ModelSignIn:setSignTb(STime:getClientDate())
			--设置当前界面
			local length = #self.signTb
			self:setGrayBtn()
			self.signTb = ModelSignIn:getSignTb()
			--self.text_conDays:setString(LanguageStr("SIGNIN_DES",length))	
			self.textDays:setString(length)
			--主界面签到提示
			UIMiddlePub:showSignInBtn()
			--领取奖励动画
			local coverBg = self:getChild("text_bg_"..length)
			coverBg:setVisible(false)
			self:receiveAwardAnimation(length)
		end, true, true, 0)
	end
end

--初始化7天的图标
function UISignIn:initSevenItem()
	for i = 1, 7, 1 do
		local icon = self:getChild("icon_"..i)		-- 赠送礼品图标
		local countText = self:getChild("Text_number_"..i)	-- 礼品的个数
		local coverBg = self:getChild("text_bg_"..i)	
		local cover = self:getChild("cover_"..i)		-- 灰色遮罩或已领取标记
		if i~= 7 then
			local dayText = self:getChild("Text_day_"..i)		-- 第i天
			dayText:setString(LanguageStr("SIGNIN_Days",i))
		end
		local itemInfo = ModelLevelLottery:getRewardIconInfo(self.signTbData[i].reward_id)	--奖励物品的信息
		countText:setString(itemInfo.name.."*"..itemInfo.count)
		icon:setVisible(true)
		cover:setVisible(true)
		coverBg:setVisible(true)
		--Log(itemInfo.image,itemInfo.count)
		if itemInfo.award_type == 2 then
			--英雄
			local heroInfo = ModelLevelLottery:getRewardIconInfo(self.signTbData[7].reward_id)	--奖励物品的信息
			--local panelRoot = self:getChild("hero_node")
			icon:removeAllChildren()
			local node = Utils:createArmatureNode(heroInfo.display,"idle",true)
			node:setName("node_"..i)
			node:setAnchorPoint(cc.p(0.5,0.5))
			node:setPosition(cc.p(0,0))
			icon:addChild(node,0)
			icon:loadTexture("touming.png")
			node:setScale(self.signTbData[i].scale)
		else
			icon:loadTexture(itemInfo.image)
			icon:setScale(self.signTbData[i].scale)
		end
		if i<= #self.signTb then
			cover:setVisible(true)
			cover:loadTexture("text_receive.png")
			coverBg:setVisible(false)
		elseif i == #self.signTb + 1 and (ModelSignIn:isTodaySignIn()== false) then
			cover:setVisible(false)
		else
			cover:loadTexture("core_gray.png")	--记得设置透明度啊
		end
		if i == 7 then
			cover:loadTexture("touming.png")
		end
	end		
end



