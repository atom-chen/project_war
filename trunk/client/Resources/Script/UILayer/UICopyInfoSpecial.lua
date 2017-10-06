----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-6-30
-- Brief: 特殊关卡信息界面
----------------------------------------------------------------------
UIDEFINE("UICopyInfoSpecial", "CopyInfoSpecial.csb")
--加载顶部目标的的图片和剩余个数
function UICopyInfoSpecial:loadGoals()
	for i=1,3,1 do
		local icon = self:getChild("Icon_"..i)
		local amount = self:getChild("Text_goal_"..i)
		local iconBg = self:getChild("ImageBg_"..i)
		local goals = ModelCopy:getGoals()
		if #goals >= i then
			local iconStr = ModelPub:getIconStrById(goals[i].id)
			icon:loadTexture(iconStr)
			amount:setString(tostring(goals[i].count))
		else
			icon:setVisible(false)
			amount:setVisible(false)
			iconBg:setVisible(false)
		end
	end
end

function UICopyInfoSpecial:onStart(ui, param)
	AudioMgr:playEffect(2007)
	--self:bind(EventDef["ED_GAME_INIT"], self.onGameInit)
	local temp = self:getChild("Image_26")
	--挑战奖励
	self.Text_select = self:getChild("Text_cellect_l")
	self.Text_select:enableOutline(cc.c4b(62,11,10,255),3)
	self.Text_select:setString(LanguageStr("SPECIAL_COPY_TITLE"))
	--最大步数
	self.mLeftMoves = self:getChild("Text_move")
	self.mLeftMoves:setString(ModelCopy:getOriMoves())
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		DataHeroInfo:getSelectHeroId()
		self:close()
	end, true, true, 0)
	-- 开始按钮
	local btnRestart = self:getChild("Button_start")
	self:addTouchEvent(btnRestart, function(sender)
		ModelPub:restartGame(self)
	end, true, true, 0)
	--设置消耗体力
	local power = self:getChild("Text_power")
	power:setString(ModelCopy:getHp())
	self:loadGoals()

	--游戏目标
	local Text_game_goal_l = self:getChild("Text_game_goal_l")
	Text_game_goal_l:setString(LanguageStr("COPYINFO_GAME_GOALS"))
	--步数
	local Text_moves_l = self:getChild("Text_moves_l")
	Text_moves_l:setString(LanguageStr("COPYINFO_GAME_MOVES"))
	--设置奖励
	--收集到的元素个数
	self.ball = self:getChild("Text_ball")
	self.diamond = self:getChild("Text_diamond")
	self.key = self:getChild("Text_key")
	self.cookie = self:getChild("Text_cookie")
	self.ball:setString("0")
	self.cookie:setString("0")
	self.key:setString("0")
	self.diamond:setString("0")
	
	local tb = DataMap:getCopyAwardTimesInfo()
	local copyId = ModelCopy:getId()
	local speCopyInfo = LogicTable:get("copy_special_tplt",copyId,true)
	local key = copyId.."_"..speCopyInfo.copy_id
	if nil == tb[key] then tb[key] = 0 end
	if nil ~= tb[key] and speCopyInfo.reward_times > tb[key] then
		self:setPassAward(ModelCopy:getAwards())
	end
end

-- 设置奖励
function UICopyInfoSpecial:setPassAward(awardIdList)
	for i, awardId in pairs(awardIdList) do
		local awardData = LogicTable:getAwardData(awardId)
		if AwardType["item"] == awardData.type then
			local types = UIMiddlePub:getItemTypeById(awardData.sub_id)
			if types == ItemType["ball"] then			-- 毛球
				self.ball:setString(awardData.count)
			elseif types == ItemType["cookie"] then		-- 饼干
				self.cookie:setString(awardData.count)
			elseif types == ItemType["key"] then		-- 钥匙
				self.key:setString(awardData.count)
			elseif types == ItemType["dia"] then		-- 钻石
				self.diamond:setString(awardData.count)
			end
		end
	end
end

function UICopyInfoSpecial:onTouch(touch, event, eventCode)
end

function UICopyInfoSpecial:onUpdate(dt)
end

function UICopyInfoSpecial:onDestroy()
	
end
