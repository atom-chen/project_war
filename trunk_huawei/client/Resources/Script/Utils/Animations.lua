----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2015-02-10
-- Brief:	动画集
----------------------------------------------------------------------
Animations = {
	mPlistTable = {},				-- plist文件表
}
----------------------------------------------------------------------
-- 加载plist文件
function Animations:loadPlist(plistName)
	if self.mPlistTable[plistName] then
		return
	end
	self.mPlistTable[plistName] = true
	cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName)
end
----------------------------------------------------------------------
-- 获取精灵帧
function Animations:getFrame(name)
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
	assert(spriteFrame, "can not get sprite frame with name: "..name)
	return spriteFrame
end
----------------------------------------------------------------------
-- 创建帧动画
function Animations:create(plistName, frameNameList, duration, callback)
	assert(#frameNameList > 0, "frame name list must exist")
    self:loadPlist(plistName)
	local animationFrames = {}
	for key, frameName in pairs(frameNameList) do
		table.insert(animationFrames, self:getFrame(frameName))
	end
	local animation = cc.Animation:createWithSpriteFrames(animationFrames, duration)
	local sprite = cc.Sprite:createWithSpriteFrame(self:getFrame(frameNameList[1]))
	if "function" == type(callback) then
		sprite:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(callback)))
	else
		sprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
	end
	return sprite
end
----------------------------------------------------------------------
-- 元素爆炸特效01
function Animations:elementExplode01(coord, soundId)
	local pos = MapManager:getMap():getGridPos(coord.row, coord.col)
	local skillController = MapManager:getComponent("SkillController")
	local explodeEffect = nil
	if skillController:existBomb() then
		explodeEffect = Utils:createArmatureNode("baozha02", "idle", false, function(armatureBack, movementType, movementId)
			if ccs.MovementEventType.complete == movementType and "idle" == movementId then
				explodeEffect:removeFromParent()
			end
		end)
	elseif skillController:existSkill() then
		explodeEffect = Utils:createArmatureNode("baozha02", "idle", false, function(armatureBack, movementType, movementId)
			if ccs.MovementEventType.complete == movementType and "idle" == movementId then
				explodeEffect:removeFromParent()
			end
		end)
	else
		explodeEffect = Utils:createArmatureNode("element_explode01", "idle", false, function(armatureBack, movementType, movementId)
			if ccs.MovementEventType.complete == movementType and "idle" == movementId then
				explodeEffect:removeFromParent()
			end
		end)
	end
	explodeEffect:setPosition(cc.p(pos.x, pos.y))
	MapManager:getMap():getTopLayer():addChild(explodeEffect, G.TOP_ZORDER_TIP)
	local appendExplodeEffect = nil
	appendExplodeEffect = Utils:createArmatureNode("element_explode02", "idle", false, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and "idle" == movementId then
			appendExplodeEffect:removeFromParent()
		end
	end)
	appendExplodeEffect:setAnchorPoint(cc.p(0.5, 0.5))
	appendExplodeEffect:setPosition(cc.p(pos.x, pos.y))
	MapManager:getMap():getTopLayer():addChild(appendExplodeEffect, G.TOP_ZORDER_TIP)
	if soundId and soundId > 0 then
		AudioMgr:playEffect(soundId)
	end
end
----------------------------------------------------------------------

