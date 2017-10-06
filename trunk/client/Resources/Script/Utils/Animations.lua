----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2015-02-10
-- Brief:	动画集
----------------------------------------------------------------------
Animations = {}
----------------------------------------------------------------------
-- 获取精灵帧
function Animations:getFrame(name)
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
	if nil == spriteFrame then
		cclog("can not get sprite frame with name: "..name)
	end
	return spriteFrame
end
----------------------------------------------------------------------
-- 创建帧动画
function Animations:create(plistName, frameNameList, duration, callback)
	assert(#frameNameList > 0, "frame name list must exist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName)
	local animationFrames = {}
	for key, frameName in pairs(frameNameList) do
		local frame = self:getFrame(frameName)
		if frame then
			table.insert(animationFrames, frame)
		end
	end
	if 0 == #animationFrames then
		return nil
	end
	local animation = cc.Animation:createWithSpriteFrames(animationFrames, duration)
	local sprite = cc.Sprite:createWithSpriteFrame(animationFrames[1])
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

