----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2015-06-18
-- Brief:	界面工厂函数
----------------------------------------------------------------------
UIFactory = {}
----------------------------------------------------------------------
-- 创建一只鱼
function UIFactory:createFish(posStart, posControl1, posControl2, posEnd, sAcName, nScaleX, nScaleY, anchorPos, nTime, tbFade)
	local uiTime = cc.Node:create()
	local prePosX, prePosY = posStart.x, posStart.y
	local spFish = Utils:createArmatureNode(sAcName, "idle", true)
	spFish:setOpacity(0)
	spFish:setAnchorPoint(anchorPos)
	spFish:setScale(nScaleX, nScaleY)
	spFish:addChild(uiTime)
	spFish:setPosition(posStart)
	-- 走的路线
	local bezier = {
        posControl1,
        posControl2,
        posEnd
    }
    local bezierTo = cc.BezierTo:create(nTime, bezier)
	local function handler()
		local curPosX, curPosY = spFish:getPosition()
		local fDeg = 3.14/2
		if curPosY < prePosY and curPosX >= prePosX then
			fDeg = math.atan((curPosX - prePosX)/(curPosY - prePosY)) - 3.14
		elseif curPosY ~= prePosY then
			fDeg = math.atan((curPosX - prePosX)/(curPosY - prePosY))
		end
		spFish:setRotation(math.deg(fDeg))
		prePosX, prePosY = curPosX, curPosY
	end
	local function handlerFish()
		prePosX, prePosY = posStart.x, posStart.y
		spFish:setOpacity(0)
	end
	local arrayFade = {cc.FadeIn:create(0.5)}
	if tbFade[1] then
		local curTime = 0.5
		for _k, _t in pairs(tbFade) do
			table.insert(arrayFade, cc.DelayTime:create(_t[1] - curTime))
			table.insert(arrayFade, cc.FadeOut:create(0.5))
			table.insert(arrayFade, cc.DelayTime:create(_t[2]))
			table.insert(arrayFade, cc.FadeIn:create(0.5))
			curTime = _t[1] + 1 + _t[2]
		end
		table.insert(arrayFade, cc.DelayTime:create(nTime - curTime - 0.5))
	else
		table.insert(arrayFade, cc.DelayTime:create(nTime - 1))
	end
	table.insert(arrayFade, cc.FadeOut:create(0.5))
	spFish:runAction(cc.RepeatForever:create(cc.Sequence:create({ 
													cc.Spawn:create({
														bezierTo, 
														cc.Sequence:create(arrayFade),
													}),  
													cc.Place:create( posStart ), 
													cc.CallFunc:create(handlerFish), 
													cc.DelayTime:create(1 + math.random(30)/10) 
											})))
	uiTime:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.CallFunc:create(handler)})))
	return spFish
end
----------------------------------------------------------------------
-- 创建提示光圈
function UIFactory:createTipCircle()
	local node = cc.Node:create()
	local light1 = cc.Sprite:create("light_quan.png")
	local light2 = cc.Sprite:create("light_quan.png")
	local light3 = cc.Sprite:create("light_quan.png")
	light1:setScale(0)
	light2:setScale(0)
	light3:setScale(0)
	node:addChild(light1)
	node:addChild(light2)
	node:addChild(light3)
	local nLightT = 0.9
	local function handler()
		light1:setScale(0)
		light2:setScale(0)
		light3:setScale(0)
		light1:setOpacity(255)
		light2:setOpacity(255)
		light3:setOpacity(255)
		light1:runAction(cc.Spawn:create({
			cc.EaseSineOut:create(cc.ScaleTo:create(nLightT,1)),
			cc.FadeOut:create(1)    
		}))
		light2:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.3),
			cc.Spawn:create({
				cc.EaseSineOut:create(cc.ScaleTo:create(nLightT,1)),
				cc.FadeOut:create(nLightT)
			})
		}))
		light3:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.5),
			cc.Spawn:create({
				cc.EaseSineOut:create(cc.ScaleTo:create(nLightT,1)),
				cc.FadeOut:create(nLightT)
			})
		}))
	end
	node:runAction(cc.RepeatForever:create(cc.Sequence:create({
			cc.CallFunc:create(handler),
            cc.DelayTime:create(1.5)
        })))
	return node
end
----------------------------------------------------------------------
-- 特殊副本动画
function UIFactory:playSpecialCopyAnimation(bubbleBox, bubbleShader)
	bubbleBox:setPosition(cc.p(0, 25))
	bubbleShader:setPosition(cc.p(0, -25))
	--
	bubbleBox:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.MoveBy:create(1, cc.p(0, 10)),
		cc.MoveBy:create(1, cc.p(0, -10))
	})))
	--
	bubbleShader:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.ScaleTo:create(1, 0.7),
		cc.ScaleTo:create(1, 1)
	})))
end
----------------------------------------------------------------------
