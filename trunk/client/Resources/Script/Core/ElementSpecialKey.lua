----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-01-23
-- Brief: 钥匙
----------------------------------------------------------------------
ElementSpecialKey = class("ElementSpecialKey", Element)

-- 构造函数
function ElementSpecialKey:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
	self.mIsAffected = false
end

-- 进入激活状态
function ElementSpecialKey:onActiveEnter(param)
	if 1 == param.affect_type then
		local gridController = MapManager:getComponent("GridController")
		local boardDatas = gridController:getBoardDatas()
		local touchedCoordList = gridController:getTouchedCoordList()
		local coord = param.grid:getCoord()
		if Core:isAroundCoordList(coord, touchedCoordList, boardDatas) then
			param.grid:setGray(false)
			if not self.mIsAffected then
				self.mIsAffected = true
				Actions:shakeAction01(self.mSprite)
			end
		else
			param.grid:setGray(true)
			self.mIsAffected = false
		end
	end
end

-- 退出激活状态
function ElementSpecialKey:onActiveExit(param)
	if 1 == param.affect_type then
		param.grid:setGray(false)
		self.mIsAffected = false
	end
end

