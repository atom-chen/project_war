----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-12
-- Brief: 场景特效1
----------------------------------------------------------------------
EffectScene01 = {
	mParticleInNode = nil,			-- 内层粒子节点
	mParticleOutNode = nil,			-- 外层粒子节点
	mSeaWaveSprite = nil,			-- 海面波纹精灵
	mLightSprite1 = nil,			-- 海里光效1精灵
	mLightSprite2 = nil,			-- 海里光效2精灵
	-- 配置
	mParticleInConfig = {			-- 内层粒子配置
		{"bubble.plist", cc.p(200, 550)},
		{"bubble.plist", cc.p(550, 550)},
		{"bubble1.plist", cc.p(360, 550)},
	},
	mParticleOutConfig = {			-- 外层粒子配置
		{"bubble1.plist", cc.p(360, 550)},
		--{"test.plist", cc.p(360, 700)}
	},
}

-- 初始
function EffectScene01:onInit(parentNode)
	-- 内层粒子
	self.mParticleInNode = cc.Node:create()
	parentNode:addChild(self.mParticleInNode, G.SCENE_ZORDER_PARTICLE_IN)
	for i, particleInConfig in pairs(self.mParticleInConfig) do
		local particleNode = Utils:createParticle(particleInConfig[1], false)
		particleNode:setPosition(particleInConfig[2])
		Utils:autoChangePos(particleNode)
		self.mParticleInNode:addChild(particleNode)
	end
	-- 外层粒子
	self.mParticleOutNode = cc.Node:create()
	parentNode:addChild(self.mParticleOutNode, G.SCENE_ZORDER_PARTICLE_OUT)
	for i, particleOutConfig in pairs(self.mParticleOutConfig) do
		local particleNode = Utils:createParticle(particleOutConfig[1], false)
		particleNode:setPosition(particleOutConfig[2])
		Utils:autoChangePos(particleNode)
		self.mParticleOutNode:addChild(particleNode)
	end
	-- 海面波纹
	local seaWaveSprite = cc.Sprite:create("water_up.png")
	seaWaveSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 960))
	seaWaveSprite:setAnchorPoint(cc.p(0.5, 1))
	parentNode:addChild(seaWaveSprite, G.SCENE_ZORDER_PARTICLE_IN)
	self.mSeaWaveSprite = seaWaveSprite
	-- 海里光效1
	local lightSprite1 = cc.Sprite:create("light.png")
	lightSprite1:setAnchorPoint(cc.p(0.5, 1))
	lightSprite1:setRotation(-15)
	lightSprite1:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 980))
	lightSprite1:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.Spawn:create({cc.ScaleTo:create(20, 0.5, 1), cc.RotateBy:create(20, -15), cc.MoveBy:create(20, cc.p(30, 0))}),
		cc.DelayTime:create(math.random(20)/10),
		cc.Spawn:create({cc.ScaleTo:create(20, 1, 1), cc.RotateBy:create(20, 15), cc.MoveBy:create(20, cc.p(-30, 0))}),
		cc.DelayTime:create(math.random(20)/10),
	})))
	parentNode:addChild(lightSprite1, G.SCENE_ZORDER_PARTICLE_IN)
	self.mLightSprite1 = lightSprite1
	-- 海里光效2
	local lightSprite2 = cc.Sprite:create("light.png")
	lightSprite2:setAnchorPoint(cc.p(0.5, 1))
	lightSprite2:setRotation(-5)
	lightSprite2:setPosition(cc.p(G.VISIBLE_SIZE.width/2 - 150, 980))
	lightSprite2:setScale(0.5)
	lightSprite2:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.Spawn:create({cc.ScaleTo:create(20, 1, 1), cc.RotateBy:create(20, -15), cc.MoveBy:create(20, cc.p(30, 0))}),
		cc.DelayTime:create(math.random(20)/10),
		cc.Spawn:create({cc.ScaleTo:create(20, 0.5, 1), cc.RotateBy:create(20, 15), cc.MoveBy:create(20, cc.p(-30, 0))}),
		cc.DelayTime:create(math.random(20)/10),
	})))
	parentNode:addChild(lightSprite2, G.SCENE_ZORDER_PARTICLE_IN)
	self.mLightSprite2 = lightSprite2
end

-- 销毁
function EffectScene01:onDestroy()
	if self.mParticleInNode then
		self.mParticleInNode:removeFromParent()
		self.mParticleInNode = nil
	end
	if self.mParticleOutNode then
		self.mParticleOutNode:removeFromParent()
		self.mParticleOutNode = nil
	end
	if self.mSeaWaveSprite then
		self.mSeaWaveSprite:removeFromParent()
		self.mSeaWaveSprite = nil
	end
	if self.mLightSprite1 then
		self.mLightSprite1:removeFromParent()
		self.mLightSprite1 = nil
	end
	if self.mLightSprite2 then
		self.mLightSprite2:removeFromParent()
		self.mLightSprite2 = nil
	end
end

return EffectScene01
