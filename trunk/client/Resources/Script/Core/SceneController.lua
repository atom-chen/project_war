----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-1-21
-- Brief: 场景控制器
----------------------------------------------------------------------
SceneController = class("SceneController", Component)

-- 构造函数
function SceneController:ctor()
	self.super:ctor(self.__cname)
	self.mSceneDatas = {}				-- 场景数据表
	self.mBackgroundSprite = nil		-- 背景精灵
	self.mBoothSprite = nil				-- 展台精灵
	self.mEffectScene = nil				-- 场景特效
end

-- 销毁函数
function SceneController:destroy()
	self:destroyScene()
end

-- 初始化
function SceneController:init(sceneIds)
	for i, sceneId in pairs(sceneIds) do
		table.insert(self.mSceneDatas, LogicTable:get("copy_scene_tplt", sceneId, true))
	end
end

-- 创建场景
function SceneController:createScene(index)
	local sceneData = self.mSceneDatas[index]
	if nil == sceneData then
		return
	end
	-- 背景
	local sceneSprite = cc.Sprite:create(sceneData.scene_image)
	sceneSprite:setAnchorPoint(cc.p(0.5, 1))
	sceneSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, G.VISIBLE_SIZE.height))
	self:getMaster():getSceneLayer():addChild(sceneSprite, G.SCENE_ZORDER_BG)
	self.mBackgroundSprite = sceneSprite
	-- 展台
	local boothSprite = cc.Sprite:create(sceneData.booth_image)
	boothSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 600))
	self:getMaster():getSceneLayer():addChild(boothSprite, G.SCENE_ZORDER_BOOTH)
	self.mBoothSprite = boothSprite
	-- 场景特效
	if "nil" ~= sceneData.effect then
		self.mEffectScene = require(sceneData.effect)
		self.mEffectScene:onInit(self:getMaster():getSceneLayer())
	end
end

-- 销毁场景
function SceneController:destroyScene()
	if self.mBackgroundSprite then
		self.mBackgroundSprite:removeFromParent()
		self.mBackgroundSprite = nil
	end
	if self.mBoothSprite then
		self.mBoothSprite:removeFromParent()
		self.mBoothSprite = nil
	end
	if self.mEffectScene then
		self.mEffectScene:onDestroy()
		self.mEffectScene = nil
	end
end

-- 获取展台精灵
function SceneController:getBoothSprite()
	return self.mBoothSprite
end

