----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-26
-- Brief: 四格漫画界面
----------------------------------------------------------------------
UICG = {
	csbFile = "Cg.csb"
}

function UICG:onStart(ui, param)
	local cgDatas = LogicTable:getAll("cg_tplt")
	local cgIndex = 1
	-- cg面板
	self.mCgPanel = UIManager:seekNodeByName(ui.root, "Panel_root")
	self:addPanel(cgDatas[1].iconName, 200)
	Utils:addTouchEvent(self.mCgPanel, function(sender)
		cclog("enter***************",cgIndex)
		self.mCgPanel:setTouchEnabled(false)
		cgIndex = cgIndex + 1
		local panelInfo = UIManager:seekNodeByName(ui.root, "Panel_info")
		-- cg结束
		if cgIndex > #cgDatas then
			panelInfo:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.DelayTime:create(0), cc.CallFunc:create(function()
				DataMap:setCompleteCG(true)
				UIManager:close(self)
				ChannelProxy:recordCustom("stat_cg_3")
			end)))
			return
		end
		-- 显示下一张cg
		ui.root:reorderChild(panelInfo, 200)
		local action = cc.Spawn:create(cc.FadeOut:create(1), cc.CallFunc:create(function()
			self:addPanel(cgDatas[cgIndex].iconName, 100)
			if cgIndex == 3 then
				ChannelProxy:recordCustom("stat_cg_2")
			end
		end))
		panelInfo:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
			panelInfo:stopAllActions()
			panelInfo:removeFromParent()
			self.mCgPanel:setTouchEnabled(true)
		end)))
	end, false, false, 0)
	--
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self.onGameInit)
	ChannelProxy:recordCustom("stat_cg_1")
end

function UICG:onTouch(touch, event, eventCode)
end

function UICG:onUpdate(dt)
end

function UICG:onDestroy()
end

--添加界面信息
function UICG:addPanel(cgImage, zOrder)
	local page = ccui.Layout:create()
	page:setName("Panel_info")
	page:setBackGroundImage(cgImage)
	page:setContentSize(cc.size(720, 960))
	page:setPosition(cc.p(G.DESIGN_WIDTH/2, G.DESIGN_HEIGHT/2))
	page:setAnchorPoint(cc.p(0.5, 0.5))
	self.mCgPanel:addChild(page, zOrder)

	local panel_click = ccui.Layout:create()
	panel_click:setName("Panel_click")
	panel_click:setContentSize(cc.size(250, 50))
	panel_click:setPosition(cc.p(33, 2))
	panel_click:setAnchorPoint(cc.p(0, 0))
	page:addChild(panel_click)
	Utils:autoChangePos(panel_click)
	
	local nextImg = ccui.ImageView:create()	
	nextImg:loadTexture("cg_next.png")
	nextImg:setName("elementIcon")
	nextImg:setPosition(cc.p(100, 24))
	nextImg:setAnchorPoint(cc.p(0.5, 0.5))
	panel_click:addChild(nextImg)
	nextImg:setOpacity(0)
	local x = nextImg:getPosition()
	local y = nextImg:getWorldPosition().y
	-- 执行动作
	local function actionDone()
		nextImg:setPosition(cc.p(x, y - 10))
		--nextImg:runAction(cc.DelayTime:create(0.2))
		nextImg:setOpacity(0)
	end
	-- 重复
	local action1 = cc.Spawn:create(cc.FadeIn:create(0.2),cc.MoveTo:create(0.6, cc.p(x, y + 10)))
	local action2 = cc.FadeOut:create(0.2)
	local action3 = cc.RepeatForever:create(cc.Sequence:create(action1,action2, cc.CallFunc:create(actionDone)))
	nextImg:runAction(action3)
	
	local levelText = ccui.Text:create(LanguageStr("CG_1"), "", 20)
	levelText:setPosition(cc.p(0, 8))
	levelText:setName("heroInfo")
	levelText:setAnchorPoint(cc.p(0, 0))
	panel_click:addChild(levelText)
end

function UICG:onGameInit(param)
	cclog("---------------11111 login ui",param)
end

