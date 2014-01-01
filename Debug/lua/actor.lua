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
	
	self.currentRoutine = nil
	self.stateFuncName = "StateStart"
	
	self.enable = true
	self.isDead	= false
	self.updateOrder	= 0
	
	self.parent = nil
	self.children = {}
end

function Actor:Begin()
	if self.StateStart ~= nil then
		self.currentRoutine = Routine()
		if self:ChangeRoutine("StateStart") then
			GS.Scheduler:AddActor(self)
		else
			print("change_routine failed.")
		end
	end
end

function Actor:Dead()
	self.enable = false
	self.isDead = true
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

function Actor:ApplyPosToSpr()
	self.spr.x = self.x
	self.spr.y = self.y
end





function Actor:ChangeRoutine(name)
	if self.currentRoutine == nil then
		print("Actor:ChangeRoutine : routine not found :", name)
		return false
	end

	-- クラスの持つメンバ関数から探す
	local f = self[name]
  if f == nil or type(f) ~= "function" then
		print("Actor:change_routine : coroutine func not found :", name)
		return false
  end
  
	-- ルーチン変更してリスタートする
	self.currentRoutine:ChangeFunc(f)
	self.currentRoutine:Restart()
	self.state_func_name = name
	return true
end


function Actor:Wait(count)
	coyield("wait", count)
end


-- コルーチン内から呼ぶ関数
function Actor:Goto(label)
	coroutine.yield("goto", label)
end



