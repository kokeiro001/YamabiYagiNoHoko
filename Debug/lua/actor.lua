local coyield = coroutine.yield


local ActorId = 1
function GetNextActorId()
	local id = ActorId
	ActorId = ActorId + 1
	return id
end

class'Actor'

function Actor:__tostring()
	return "class Actor name="..self.name
end

function Actor:__eq(val)
	if val.id ~= nil and val.id == self.id then
		return true
	end
	return false
end

function Actor:__init()
	self.id = GetNextActorId()

	self.spr = nil

	self.x = 0
	self.y = 0
	self.name = "class Actor"
	self.params = {}
	
	self.scheduler = nil
	
	self.currentRoutine = nil
	self.stateFuncName = "StateStart"
	
	self.enable = true
	self.isDead	= false
	self.updateOrder	= 0
	
	self.parent = nil
	self.children = {}
end

function Actor:GetPos()
	return self.x, self.y
end

function Actor:SetPos(x, y)
	self.x = x
	self.y = y
end

function Actor:Begin()
	if self.StateStart ~= nil then
		if self:ChangeRoutine("StateStart") then
			GS.Scheduler:AddActor(self)
			self.scheduler = GS.Scheduler
		else
			print("change_routine failed.")
		end
	end
end

function Actor:Dead()
	self.enable = false
	self.isDead = true
	if self.anim ~= nil then
		self.anim:Dead()
	end
		
	GS.Scheduler:DeleteActor(self)
end

function Actor:Dispose()
	self.params = nil
	self:RemoveFromParent()
	
	-- remove from draw system
	if self.spr ~= nil then
		GS.DrawSys:RemoveSprite(self.spr)
	end
	
	-- remove children from scheduler
	for i, chr in pairs(self.children) do
--		chr:RemoveFromParent()
		GS.Scheduler:DeleteActor(chr)
	end
	self.children = {}

--	self.spr = nil
	self.drawSys = nil
	self.scheduler = nil
end




function Actor:AddChild(chr)
	chr.parent = self
	table.insert(self.children, chr)
	
	if chr.spr ~= nil then
		if self.spr == nil then
			self:CreateSpr()
			self.spr:Show()
		end
		self.spr:AddChild(chr.spr)
	end
end

function Actor:ClearChild()
	for i, chr in pairs(self.children) do
		chr:RemoveFromParent()
	end
	self.children = {}
end

function Actor:RemoveChild(chr)
	if chr.parent == self then
		if chr.spr ~= nil then
			self.spr:RemoveChild(chr.spr)
		end
		chr.parent = nil
		RemoveValue(self.children, chr)
	end
end

function Actor:RemoveFromParent()
	if self.parent ~= nil then
		if self.spr ~= nil then
			self.spr:RemoveFromParent()
		end
		
		self.parent:RemoveChild(self)
	end
end

function Actor:GetChild()
	return self.children
end

function Actor:GetChildId(id)
	for idx, chr in ipairs(self.children) do
		if chr.id == id then
			return chr
		end
	end
	return nil
end



function Actor:GetSpr()
	return self.spr
end

function Actor:CreateSpr()
	self.spr = Sprite()
	self.spr.name = "lua_spr actor.id="..self.id
	
	if self.parent ~= nil then
		self.parent:GetSpr():AddChild(self.spr)
	end
end

function Actor:AddSprToDrawSystem()
	if self.spr ~= nil then
		GS.DrawSys:AddSprite(self.spr)
	end
end

function Actor:SetTexture(name)
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextureMode(name)
end

function Actor:SetDivTexture(name, xdiv, ydiv, width, height)
	if self.spr == nil then
		self:CreateSpr()
	end
	--self.spr:SetDivTextureMode(name, xdiv, ydiv, width, height)
	self.spr:SetDivTextureMode(name, xdiv, ydiv, width, height)
end


-- 色はClorFで指定すること
function Actor:SetText(text, col)
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextMode(text)
	if col ~= nil then
		self.spr:SetTextColorF(col)
	end
end

function Actor:SetText2(text, fontName, col)
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextMode2(text, fontName)
	if col ~= nil then
		self.spr:SetTextColorF(col)
	end
end

function Actor:ApplyPosToSpr()
	self.spr.x = self.x
	self.spr.y = self.y
end

function Actor:ApplyPosToSprUseCamera(camera)
	local x, y = camera:GetValidPos()
	self.spr.x = self.x - x
	self.spr.y = self.y - y
end

function Actor:Show()
	self:GetSpr():Show()
end

function Actor:Hide()
	self:GetSpr():Hide()
end

function Actor:ChangeRoutine(name)
	-- クラスの持つメンバ関数から探す
	local f = self[name]
  if f == nil or type(f) ~= "function" then
		error("Actor:change_routine : coroutine func not found :"..name)
		return false
  end
 
	if self.scheduler == nil then
		self.currentRoutine = Routine()
		GS.Scheduler:AddActor(self)
		self.scheduler = GS.Scheduler
	end

	-- ルーチン変更してリスタートする
	self.currentRoutine:ChangeFunc(f)
	self.state_func_name = name
	return true
end

function Actor:ChangeFunc(func)
	if self.scheduler == nil then
		self.currentRoutine = Routine()
		GS.Scheduler:AddActor(self)
		self.scheduler = GS.Scheduler
	end

	self.currentRoutine:ChangeFunc(func)
	self.state_func_name = ""
	return true
end

function Actor:Wait(count)
	coyield("wait", count or 0)
end


-- コルーチン内から呼ぶ関数
function Actor:Goto(label)
	coroutine.yield("goto", label)
end

function Actor:Exit(label)
	coroutine.yield("exit")
end


function Actor:SetAnimation(anim)
	anim:Begin()
	anim:SetOwner(self)
	self.anim = anim
end



function Actor:StateStart(rt)
	while true do
		rt:Wait()
	end
end





function Actor:MoveSpd(cnt, spdX, spdY)
	self.cnt = cnt
	self.spdX = spdX
	self.spdY = spdY
	self:ChangeRoutine("StateMoveSpd")
end

function Actor:StateMoveSpd(rt)
	for i=1, self.cnt do
		self.x = self.x + self.spdX
		self.y = self.y + self.spdY
		rt:Wait()
	end
	self:Goto("StateStart")
end

function Actor:Move(cnt, toX, toY)
	self.cnt = cnt
	self.fromX = self.x
	self.fromY = self.y
	self.toX = toX
	self.toY = toY
	self:ChangeRoutine("StateMove")
end

function Actor:StateMove(rt)
	local saX = self.fromX - self.toX
	local saY = self.fromY - self.toY
	for i=1, self.cnt do
		self.x = self.toX + saX * (1 - (i / self.cnt))
		self.y = self.toY + saY * (1 - (i / self.cnt))
		rt:Wait()
	end
	self.x = self.toX
	self.y = self.toY
	self:Goto("StateStart")
end

function Actor:MoveJump(maxTime, maxY, enableTime)
	self.srcY = self.y
	self.maxTime = maxTime
	self.maxY = maxY
	self.enableTime = enableTime
	self:ChangeRoutine("StateMoveJump")
end

function Actor:StateMoveJump(rt)
	for i=1, self.enableTime do
		self.y = self.srcY 
						 + (2*self.maxY*i)/self.maxTime
						 -0.5*(2*self.maxY*(i*i)) / (self.maxTime * self.maxTime)
		rt:Wait()
	end
	self.y = self.srcY
	self:Goto("StateStart")
end



class 'FadeHelper'(Actor)
function FadeHelper:__init(owner)
	Actor.__init(self)
	self.owner = owner
end

function FadeHelper:StateStart(rt)
	while true do
		rt:Wait()
	end
end

function FadeHelper:Fade(cnt, fromX, fromY, fromAlpha, toX, toY, toAlpha)
	local spr = self.owner:GetSpr()
	self.cnt				= cnt
	self.fromX			= fromX
	self.fromY			= fromY
	self.fromAlpha	= fromAlpha
	self.toX				= toX
	self.toY				= toY
	self.toAlpha		= toAlpha
	
	self.owner:SetPos(fromX, fromY)
	spr.alpha = fromAlpha
	self.owner:ApplyPosToSpr()

	for i=0, spr:GetChildCnt()-1 do
		local chr = spr:GetChild(i)
		chr.alpha = self.fromAlpha
	end
	
	self:ChangeRoutine("StateFade")
end

function FadeHelper:StateFade(rt)
	local owner = self.owner
	local spr = owner:GetSpr()

	local len = spr:GetChildCnt()
	local saX = self.fromX - self.toX
	local saY = self.fromY - self.toY
	local saAlpha = self.fromAlpha - self.toAlpha
	
	for i=1, self.cnt do
		owner.x = self.toX + saX * (1 - (i / self.cnt))
		owner.y = self.toY + saY * (1 - (i / self.cnt))
		spr.alpha = self.toAlpha + saAlpha * (1 - (i / self.cnt))
		
		for j=0, len-1 do
			local chr = spr:GetChild(j)
			chr.alpha = self.toAlpha + saAlpha * (1 - (i / self.cnt))
		end
		owner:ApplyPosToSpr()
		rt:Wait()
	end
	self:Goto("StateStart")
end




class 'DemoActor'(Actor)
function DemoActor:__init()
	Actor.__init(self)
end

function DemoActor:StateStart(rt)
	while true do
		rt:Wait()
	end
end









class 'DebugMouseViewer'(Actor)
function DebugMouseViewer:__init()
	Actor.__init(self)
end

function DebugMouseViewer:Begin()
	Actor.Begin(self)
	self:SetText("tmp")
	self:GetSpr():SetFontSize(12)
	self:GetSpr().z = -100000000
end

function DebugMouseViewer:StateStart(rt)
	local prePos = Point2DI()
	while true do
		local pos = GS.InputMgr:GetMousePos()
		if pos.x ~= prePos.x and pos.y ~= prePos.y then
			prePos = pos
			self:GetSpr():SetText(string.format("MousePos(%3d, %3d)", pos.x, pos.y))
		end
		rt:Wait()
	end
end
