----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-03
-- Brief: 关于免责声明界面
----------------------------------------------------------------------
UIDEFINE("UIDisclaimer", "Disclaimer.csb")
function UIDisclaimer:onStart(ui, param)
	--滚动条
	local ScrollView_1 = self:getChild("ScrollView_1")
	--self:addTouchEvent(scrollView, function(sender)
	
	--end, true, true, 0)	
	
	-- 版本号
	local nativeInfo = json.decode(G.CONFIG["native_info"])
	local resrouceFlag = ""
	if 1 == G.CONFIG["update_type"] then
		resrouceFlag = "(内网)"
	elseif 2 == G.CONFIG["update_type"] then
		resrouceFlag = "(外网)"
	end
	local versionInfo = (nativeInfo["version"] or "0").."."..(nativeInfo["build"] or "0")..resrouceFlag
	
	local numberText = ccui.Text:create(LanguageStr("About",versionInfo), "", 20)
	numberText:setPosition(cc.p(172, 190))
	numberText:setAnchorPoint(cc.p(0.5,0.5))
	ScrollView_1:addChild(numberText)
	--numberText:ignoreContentAdaptWithSize(true)
	numberText:setContentSize( cc.size(330, 300) )
	numberText:setColor( cc.c3b(74, 37, 37) )
	numberText:setString(LanguageStr("About",versionInfo))
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
end

function UIDisclaimer:onTouch(touch, event, eventCode)
end

function UIDisclaimer:onUpdate(dt)
end

function UIDisclaimer:onDestroy()
end

