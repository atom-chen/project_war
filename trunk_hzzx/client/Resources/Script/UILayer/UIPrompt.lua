----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: 提示
----------------------------------------------------------------------
UIPrompt = {
	mPromptTable = {}		-- 提示列表
}
----------------------------------------------------------------------
-- 显示提示
function UIPrompt:show(text)
	if nil == text or "" == text then return end
	-- 文本
	local promptLabel = ccui.Text:create()
	promptLabel:setFontSize(26)
	promptLabel:setString(text)
	local contentSize = cc.size(promptLabel:getContentSize().width + 5, promptLabel:getContentSize().height + 5)
	promptLabel:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
	-- 背景
	local promptBg = ccui.Scale9Sprite:create("frame_04.png")
	promptBg:setPosition(cc.p(G.VISIBLE_SIZE.width/2, G.VISIBLE_SIZE.height/2))
	promptBg:setContentSize(cc.size(contentSize.width, contentSize.height))
	promptBg:addChild(promptLabel)
	Game.NODE_TOP:addChild(promptBg)
	-- 动作
	local labelAction = cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeOut:create(1.0))
	promptLabel:runAction(labelAction)
	local bgAction = cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeOut:create(1.0), cc.CallFunc:create(function(sender)
		table.remove(self.mPromptTable, 1)
		sender:removeFromParent()
	end))
	promptBg:runAction(bgAction)
	-- 插入队列
	if #self.mPromptTable > 8 then
		local tmpPromptBg = self.mPromptTable[1]
		table.remove(self.mPromptTable, 1)
		tmpPromptBg:removeFromParent()
	end
	for key, val in pairs(self.mPromptTable) do
		local x, y = val:getPosition()
		val:setPosition(cc.p(x, y + 50))
	end
	table.insert(self.mPromptTable, promptBg)
end
----------------------------------------------------------------------
-- 清除提示列表
function UIPrompt:clear()
	for key, val in pairs(self.mPromptTable) do
		val:stopAllActions()
		val:removeFromParent()
	end
	self.mPromptTable = {}
end
----------------------------------------------------------------------