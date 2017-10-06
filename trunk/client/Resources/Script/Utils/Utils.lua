----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-12-29
-- Brief:	通用函数
----------------------------------------------------------------------
Utils = {}
----------------------------------------------------------------------
-- 设置节点相对坐标:x,y取值为0-1之间 从中间计算
function Utils:setPosPercentCenter(node, xPercent, yPercent)
	local xPos = G.VISIBLE_SIZE.width * xPercent
	local yPos = G.DESIGN_HEIGHT * yPercent
	node:setPosition(cc.p(xPos, yPos))
end
----------------------------------------------------------------------
-- 设置节点相对坐标:x,y取值为0-1之间 从左下角计算
function Utils:setPosPercent(node, xPercent, yPercent)
	local xPos = (G.DESIGN_WIDTH - G.VISIBLE_SIZE.width)/2 + G.VISIBLE_SIZE.width * xPercent
	local yPos = G.DESIGN_HEIGHT * yPercent
	node:setPosition(cc.p(xPos, yPos))
end
----------------------------------------------------------------------
-- 设置"cc.Sprite"的图片
function Utils:setSpriteTexture(sprite, fileName)
	if nil == sprite or nil == fileName then return end
	sprite:setTexture(cc.Director:getInstance():getTextureCache():addImage(fileName))
end
----------------------------------------------------------------------
-- 自动转换坐标
function Utils:autoChangePos(node)
	local oriX, oriY = node:getPosition()
	self:setPosPercent(node, oriX/G.DESIGN_WIDTH, oriY/G.DESIGN_HEIGHT)
end
----------------------------------------------------------------------
-- 坐标转换
function Utils:changePosition(pos)
	if nil == pos then return nil end
	local xPos = G.VISIBLE_SIZE.width*(pos.x/G.DESIGN_WIDTH)
	return cc.p(xPos, pos.y)
end
----------------------------------------------------------------------
-- 创建着色器,返回:GLProgramState
function Utils:createShader(node, vertShaderFileName, fragShaderFileName)
	if not G.SHADER_ENABLED then return nil end
	if nil == node then return nil end
	local vertSource = cc.FileUtils:getInstance():getStringFromFile(vertShaderFileName)
	local fragSource = cc.FileUtils:getInstance():getStringFromFile(fragShaderFileName)
	local glProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
	local glProgramState = cc.GLProgramState:create(glProgram)
	node:setGLProgramState(glProgramState)
	return glProgramState
end
----------------------------------------------------------------------
-- 设置着色器参数
function Utils:setUniformFloat(node, name, value)
	if not G.SHADER_ENABLED then return end
	assert("string" == type(name) and "number" == type(value), "name = "..tostring(name)..", value = "..tostring(value).." is error")
	if nil == node then return end
	local glProgramState = node:getGLProgramState()
	if nil == glProgramState then return end
	glProgramState:setUniformFloatEx(name, value)
end
----------------------------------------------------------------------
-- 执行函数
function Utils:doCallback(callback, ...)
	if "function" == type(callback) then
		return callback(...)
	end
	return nil
end
----------------------------------------------------------------------
--将秒转化为倒计时形式
function Utils:secToString(seconds)
	local t = seconds
	local remain
	local days = math.floor(t / (60 * 60 * 24))
	remain = t % (60 * 60 * 24)
	local hours = remain / (60 * 60)
	remain = remain % (60 * 60)
	local mins = remain / 60
	remain = remain % 60
	local rt =""
	if (days >= 1) then
		rt = string.format("%d%s",days,LanguageStr("TIAN"))
	end
	hours = math.floor(hours)
	mins = math.floor(mins)
	remain = math.floor(remain)
	
	rt = rt..string.format("%02d:%02d:%02d", hours, mins, remain)
	if hours ==0 and days <= 0 then
		rt = string.format("%02d:%02d", mins, remain)
	end
	return rt
end
----------------------------------------------------------------------
-- 创建骨骼节点(fileName=.csb文件)
function Utils:createSkeletonNode(fileName, startIndex, endIndex, loop, frameEventCF)
	local skeletonNode = cc.CSLoader:createNode(fileName..".csb")
	local skeletonAction = cc.CSLoader:createTimeline(fileName..".csb")
	skeletonAction:setTag(1010)
	-- 要在指定的帧给指定的骨骼添加"帧事件",属性内添加一个字符串即可,该字符传将在帧事件回调函数内当做参数传入
	skeletonAction:setFrameEventCallFunc(function(frame)
		if frame and "function" == type(frameEventCF) then
			frameEventCF(frame)
		end
	end)
	skeletonAction:gotoFrameAndPlay(startIndex, endIndex, loop)
	skeletonNode:runAction(skeletonAction)
	return skeletonNode
end
----------------------------------------------------------------------
-- 播放骨骼动画
function Utils:playSkeletonAnimation(skeletonNode, startIndex, endIndex, loop, frameEventCF)
	if nil == skeletonNode then return end
	local skeletonAction = skeletonNode:getActionByTag(1010)
	if nil == skeletonAction then return end
	skeletonAction:stop()
	skeletonAction:setFrameEventCallFunc(function(frame)
		if frame and "function" == type(frameEventCF) then
			frameEventCF(frame)
		end
	end)
	skeletonAction:gotoFrameAndPlay(startIndex, endIndex, loop)
	skeletonAction:startWithTarget(skeletonNode)
end
----------------------------------------------------------------------
-- 创建骨骼节点(fileName=.ExportJson文件)
function Utils:createArmatureNode(fileName, animationName, loop, animationEventCF)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName..".ExportJson")
	local armatureNode = ccs.Armature:create(fileName)
	if armatureNode then
		armatureNode:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementId)
			if "function" == type(animationEventCF) then
				animationEventCF(armatureBack, movementType, movementId)
			end
		end)
		if animationName and loop then
			armatureNode:getAnimation():play(animationName, -1, 1)
		elseif animationName and not loop then
			armatureNode:getAnimation():play(animationName, -1, 0)
		end
	end
	return armatureNode
end
----------------------------------------------------------------------
-- 播放骨骼动画
function Utils:playArmatureAnimation(armatureNode, animationName, loop, animationEventCF)
	if nil == armatureNode then return end
	armatureNode:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementId)
		if "function" == type(animationEventCF) then
			animationEventCF(armatureBack, movementType, movementId)
		end
	end)
	if animationName and loop then
		armatureNode:getAnimation():play(animationName, -1, 1)
	elseif animationName and not loop then
		armatureNode:getAnimation():play(animationName, -1, 0)
	end
end
----------------------------------------------------------------------
-- 创建粒子节点
function Utils:createParticle(plistFile, autoRemove)
	local particle = cc.ParticleSystemQuad:create(plistFile)
	particle:setAutoRemoveOnFinish(autoRemove)
	return particle
end
----------------------------------------------------------------------
-- 获取分享的内容
function Utils:getShareContent()
	local tbShares = LogicTable:getAll("share_tplt")
	return tbShares[math.random(#tbShares)]
end
----------------------------------------------------------------------
-- 延迟执行
function Utils:delayExecute(duration, executeCF, param)
	if "function" ~= type(executeCF) then return end
	local runningScene = cc.Director:getInstance():getRunningScene()
	if nil == runningScene then
		executeCF(param)
		return
	end
	if "number" ~= type(duration) or duration < 0 then
		duration = 0
	end
	runningScene:runAction(cc.Sequence:create({cc.DelayTime:create(duration), cc.CallFunc:create(function()
		executeCF(param)
	end)}))
end
----------------------------------------------------------------------
-- 加载csv文件
function Utils:loadCsvFile(fileName)
	local function split(str, reps)
		local resultStrsList = {};
		string.gsub(str, '[^'..reps..']+', function(w) table.insert(resultStrsList, w) end)
		return resultStrsList
	end
	local function splitTypeAndName(value)
		local sp, ep = string.find(value, ":")
		if nil == sp or 1 == sp or nil == ep or string.len(value) == ep then
			sp, ep = string.find(value, "%.")
			if nil == sp or 1 == sp or nil == ep or string.len(value) == ep then
				return nil
			end
		end
		return string.sub(value, 1, sp - 1), string.sub(value, ep + 1, string.len(value))
	end
	local content = cc.FileUtils:getInstance():getStringFromFile(fileName)
	local lineStr = split(content, '\n\r')
	local titleList = split(lineStr[1], ",")
	local titleCount = #titleList
	local dataTable = {}
	for i=2, #lineStr do
		local row = split(lineStr[i], ",")
		if #row == titleCount then
			local data, key = {}, nil
			for j=1, titleCount do
				local value = row[j]
				local valueType, valueName = splitTypeAndName(titleList[j])
				if "key_number" == valueType then
					assert(nil == key, "Utils -> loadCsvFile() -> exist two key field at index '"..i.."' in file '"..fileName.."'")
					key = tonumber(value)
					data[valueName] = key
				elseif "key_string" == valueType then
					assert(nil == key, "Utils -> loadCsvFile() -> exist two key field at index '"..i.."' in file '"..fileName.."'")
					key = tostring(value)
					data[valueName] = key
				elseif "number" == valueType then
					data[valueName] = tonumber(value)
				elseif "string" == valueType then
					data[valueName] = tostring(value)
				elseif "list_number" == valueType then
					if "" == value or "nil" == value then
						data[valueName] = {}
					else
						data[valueName] = CommonFunc:stringSplit(value, "|", true)
					end
				elseif "list_string" == valueType then
					if "" == value or "nil" == value then
						data[valueName] = {}
					else
						data[valueName] = CommonFunc:stringSplit(value, "|", false)
					end
				elseif "tuple_number" == valueType then
					if "" == value or "nil" == value then
						data[valueName] = {}
					else
						data[valueName] = CommonFunc:parseTuple(value, "|", true)
					end
				elseif "tuple_string" == valueType then
					if "" == value or "nil" == value then
						data[valueName] = {}
					else
						data[valueName] = CommonFunc:parseTuple(value, "|", false)
					end
				else
					assert(nil, "Utils -> loadCsvFile() -> key '"..titleList[j].."' is error format at index '"..i.."' in file '"..fileName.."'")
				end
			end
			if nil == key then
				table.insert(dataTable, data)
			else
				dataTable[key] = data
			end
		end
	end
	return dataTable
end
----------------------------------------------------------------------
-- 收集副本信息
function Utils:collectCopyInfo(status)
	local info = {}
	-- 设备id
	info["device_id"] = ChannelProxy:getDeviceId()
	-- 渠道id
	info["channel_id"] = ChannelProxy:getChannelId()
	-- 关卡id
	info["copy_id"] = ModelPub:getCurPass()
	-- 关卡状态:成功,失败,取消
	info["status"] = status
	-- 英雄信息:id+等级
	info["heros"] = {}
	for i, heroId in pairs(DataMap:getSelectedHeroIds()) do
		info["heros"][tostring(heroId)] = LogicTable:get("hero_tplt", heroId, true).level
	end
	-- 剩余步数
	info["moves"] = ModelCopy:getMoves()
	-- 目标(收集目标:所有元素id+剩余个数,击杀目标:所有怪物id+剩余血量)
	info["collects"], info["kills"] = {}, {}
	for i, goal in pairs(ModelCopy:getGoals()) do
		local remainCount = ModelCopy:getRemainGoalCount(goal.id)
		if 0 == goal.id then		-- 击杀目标
			local copyInfo = nil
			if ModelPub:isSpeLevel() then	-- 特殊副本
				local speCopyId = CommonFunc:stringSplit(DataMap:getSpePass(), "_", false)
				copyInfo = LogicTable:get("copy_special_tplt", tonumber(speCopyId[2]), true)
			else							-- 普通副本
				copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), true)
			end
			local index = goal.count - remainCount + 1
			for i, monsterId in pairs(copyInfo.kill_goals) do
				local blood = 0			-- 已击杀的怪物
				if i == index then		-- 当前的怪物
					blood = MonsterHP
				elseif i > index then	-- 未出现的怪物
					blood = LogicTable:get("monster_tplt", monsterId, true).hp
				end
				table.insert(info["kills"], monsterId..":"..blood)
			end
		elseif goal.id > 0 then		-- 收集目标
			info["collects"][tostring(goal.id)] = remainCount
		end
	end
	-- 购买打折步数次数
	info["buy_discount_moves"] = ModelCopy:getBuyDiscountMovesCount()
	-- 购买步数次数
	info["buy_moves"] = ModelCopy:getBuyMovesCount()
	return info
end
----------------------------------------------------------------------
