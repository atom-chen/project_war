----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 地图管理器
----------------------------------------------------------------------
MapManager = {
	mMap = nil
}

-- 创建地图
function MapManager:create(copyId, heroIds)
	cclog("================================================ create map, copy id: "..copyId)
	self:destroy()
	local copyInfo = LogicTable:get("copy_tplt", copyId, true)
	-- 创建地图
	local mapView = MapView.new()
	self.mMap = mapView
	mapView:init(G.GRID_ROW, G.GRID_COL, G.GRID_WIDTH, G.GRID_HEIGHT, G.GRID_GAP, G.GRID_TOUCH_GAP, G.VISIBLE_SIZE.width, G.VISIBLE_SIZE.height, -G.GRID_GAP)
	Game.NODE_SCENE:addChild(mapView:getLayer())
	-- 副本资源
	if copyInfo.resource_id > 0 then
		local copyResourceInfo = LogicTable:get("copy_resource_tplt", copyInfo.resource_id, true)
		local touchArea = mapView:getTouchArea()
		-- 地图背景
		local bgSprite = cc.Sprite:create(copyResourceInfo.map_bg)
		bgSprite:setAnchorPoint(cc.p(0.5, 0))
		bgSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 0))
		mapView:getMapLayer():addChild(bgSprite, G.MAP_ZORDER_BG)
		-- 海底背景
		local boothBgSprite = cc.Sprite:create(copyResourceInfo.seabed_bg)
		boothBgSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, touchArea.height - 32))
		mapView:getTopLayer():addChild(boothBgSprite, G.TOP_ZORDER_SEABED)
		-- 海底特效
		if copyResourceInfo.seabed_effect[1] then
			local seabedEffect = cc.Sprite:create(copyResourceInfo.seabed_effect[1])
			seabedEffect:setPosition(cc.p(G.VISIBLE_SIZE.width/2, touchArea.height - 36))
			mapView:getTopLayer():addChild(seabedEffect, G.TOP_ZORDER_SEABED)
		end
		-- 展台图片
		local boothSprite = cc.Sprite:create(copyResourceInfo.booth)
		boothSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, touchArea.height - 20))
		mapView:getTopLayer():addChild(boothSprite, G.TOP_ZORDER_BOOTH)
	end
	-- 设置场景控制器
	local sceneController = SceneController.new()
	mapView:addComponent(sceneController)
	sceneController:init(copyInfo.scene_ids)
	-- 设置格子控制器
	local gridController = GridController.new()
	mapView:addComponent(gridController, 3)
	gridController:init(copyInfo.grid_data, copyInfo.board_data, copyInfo.born_pos)
	gridController:setMinCollect(ElementNormalType["red"], G.MIN_COLLECT)
	gridController:setMinCollect(ElementNormalType["yellow"], G.MIN_COLLECT)
	gridController:setMinCollect(ElementNormalType["green"], G.MIN_COLLECT)
	gridController:setMinCollect(ElementNormalType["blue"], G.MIN_COLLECT)
	gridController:setMinCollect(ElementNormalType["purple"], G.MIN_COLLECT)
	-- 设置出生控制器
	local bornController = BornController.new()
	mapView:addComponent(bornController)
	bornController:init(copyInfo.init_skills, copyInfo.probability, copyInfo.special_element_drop)
	-- 设置技能控制器
	local skillController = SkillController.new()
	mapView:addComponent(skillController)
	-- 设置英雄控制器
	local heroController = HeroController.new()
	mapView:addComponent(heroController, 2)
	for i, heroId in pairs(heroIds) do
		heroController:addHero(heroId)
	end
	heroController:createHeroInfoPanel()
	-- 设置怪物控制器
	local monsterController = MonsterController.new()
	mapView:addComponent(monsterController)
	monsterController:init(copyInfo.kill_goals)
	-- 设置连线器
	local lineController = LineController.new()
	mapView:addComponent(lineController)
	-- 设置提示器
	local tipController = TipController.new()
	mapView:addComponent(tipController, 1)
	-- 设置投放器
	local throwController = ThrowController.new()
	mapView:addComponent(throwController)
	-- 初始操作
	sceneController:createScene(1)
	bornController:generateInitGrid()
	bornController:generateInitBoard()
	monsterController:generateMonster(1)
	GuideMgr:startCopy(copyId)
end

-- 销毁地图
function MapManager:destroy()
	if self.mMap then
		self.mMap:destroy()
		self.mMap:getLayer():removeFromParent()
		self.mMap = nil
		collectgarbage("collect")
		cclog("================================================ destroy map")
	end
end

-- 获取地图
function MapManager:getMap()
	return self.mMap
end

-- 获取地图组件
function MapManager:getComponent(name)
	if self.mMap then
		return self.mMap:getComponent(name)
	end
	return nil
end

-- 获取当前怪物表现
function MapManager:getMonsterDisplay()
	if nil == self.mMap then
		return nil
	end
	local monster = self.mMap:getComponent("MonsterController"):getMonster()
	if nil == monster then
		return nil
	end
	return monster:getDisplay()
end

-- 设置地图触摸
function MapManager:setTouch(enabled)
	if self.mMap then
		self.mMap:setTouchEnabled(enabled)
	end
end

-- 获取触摸标识
function MapManager:getTouchFlag()
	if nil == self.mMap then
		return 0
	end
	return self.mMap:getTouchFlag()
end

-- 剩余步数奖励
function MapManager:remainRoundAward(remainRound, callback)
	if nil == self.mMap or nil == remainRound or remainRound <= 0 then
		return
	end
	local function innerRemainRoundAward()
		if remainRound <= 0 then
			Utils:doCallback(callback, {})
			return
		end
		local grid = self.mMap:getComponent("GridController"):getRemainRoundGrid()
		if nil == grid then
			local elementDatas = {}
			for i=1, remainRound do
				table.insert(elementDatas, {award_id = 1000})
			end
			Utils:doCallback(callback, elementDatas)
			return
		end
		remainRound = remainRound - 1
		local gridCoord = grid:getCoord()
		local gridPos = self.mMap:getGridPos(gridCoord.row, gridCoord.col)
		local startX, startY = G.VISIBLE_SIZE.width - 45, 840
		local stepParticle = Utils:createParticle("stepreward.plist", true)
		stepParticle:setPosition(cc.p(startX, startY))
		self.mMap:getTopLayer():addChild(stepParticle, G.TOP_ZORDER_EFFECT)
		local bezierCfg = {
			cc.p(startX, startY),
			cc.p(startX - (startX - gridPos.x)/2 - 45, startY - (startY - gridPos.y)/2),
			cc.p(gridPos.x, gridPos.y),
		}
		Actions:bezierTo(stepParticle, bezierCfg, 0.15, function()
			self.mMap:getComponent("GridController"):clearGrid(gridCoord)
			Actions:delayWith(self.mMap:getTopLayer(), 0.4, innerRemainRoundAward)
		end)
	end
	innerRemainRoundAward()
end

