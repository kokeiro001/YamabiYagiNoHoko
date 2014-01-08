require("actor")

class 'Animation'(Actor)
function Animation:__init()
	Actor.__init(self)
end

function Animation:Begin()
	Actor.Begin(self)
end

function Animation:BeginAnim(name)
	error("–¢ŽÀ‘•")
end

function Animation:SetOwner(owner)
	self.owner = owner
	if self.ChangedOwner ~= nil then
		self:ChangedOwner()
	end
end




class 'PlayerAnim'(Animation)
function PlayerAnim:__init(mode)
	Actor.__init(self)
end

function PlayerAnim:ChangedOwner()
	local spr = self.owner:GetSpr()
	spr.name = "player anim spr"
	spr.divTexIdx = 0
	spr:SetCenter(16, 16)
end

function PlayerAnim:BeginAnim(name)
	if name == "run" then
		self:ChangeRoutine("StateRun")
	elseif name == "jump" then
		self:ChangeRoutine("StateJump")
	else
		error("not def")
	end
end

function PlayerAnim:StateRun(rt)
	local spr = self.owner:GetSpr()

	while true do
		for idx=0, 5 do
			spr.divTexIdx = idx
			rt:Wait(3)
		end
	end
end

function PlayerAnim:StateJump(rt)
	local spr = self.owner:GetSpr()
	while true do
		spr.divTexIdx = 5
		rt:Wait(10000)
	end
end

class 'PlayerYagiAnim'(PlayerAnim)
function PlayerYagiAnim:__init(mode)
	PlayerAnim.__init(self)
end

function PlayerYagiAnim:StateRun(rt)
	local spr = self.owner:GetSpr()

	while true do
		for idx=12, 17 do
			spr.divTexIdx = idx
			rt:Wait(3)
		end
	end
end

function PlayerYagiAnim:StateJump(rt)
	local spr = self.owner:GetSpr()
	while true do
		spr.divTexIdx = 17
		rt:Wait(10000)
	end
end



local PAT_ANIM_SPD	= 1

class 'PatcarAnim'(Animation)
function PatcarAnim:__init()
	Actor.__init(self)
	
end

function PatcarAnim:ChangedOwner()
	self.owner:SetDivTexture("patcar", 4, 4, 100, 50)

	local spr = self.owner:GetSpr()
	spr.name = "patcar spr"
	spr.divTexIdx = 12

	GetCamera():AddAutoApplyPosItem(self.owner)
end

function PatcarAnim:StateStart(rt)
	local spr = self.owner:GetSpr()
	while true do
		for idx=12, 15 do
			spr.divTexIdx = idx
			rt:Wait(PAT_ANIM_SPD)
		end
	end
end



class 'CelesAnim'(Animation)
function CelesAnim:__init()
	Actor.__init(self)
end

function CelesAnim:BeginAnim()
	self:ChangeRoutine("StateStart")
end

function CelesAnim:ChangedOwner()
	self.owner:SetDivTexture("celes", 3, 2, 50, 50)
	local spr = self.owner:GetSpr()
	spr.name = "celes anim spr"
	spr.cx = 25
	spr.cy = 25
end

function CelesAnim:StateStart(rt)
	local spr = self.owner:GetSpr()
	local wait = 10
	while true do
		spr.divTexIdx = 0
		rt:Wait(wait)
		spr.divTexIdx = 1
		rt:Wait(wait)
		spr.divTexIdx = 2
		rt:Wait(wait)
		spr.divTexIdx = 1
		rt:Wait(wait)
	end
end


class 'SimpleAnimation'(Animation)
function SimpleAnimation:__init()
	Actor.__init(self)
	
	self:SetDefaultAnim("def")
	
	self.animData = {}
end

function SimpleAnimation:SetDefaultAnim(name)
	self.defAnimName = name
end


function SimpleAnimation:AddFrameAnimData(name, beginFrame, endFrame, waitFrame)
	self.animData[name] = 
		{
			t		= "FrameAnim", 
			b 	= beginFrame, 
			e		= endFrame, 
			w 	= waitFrame
		}
end

function SimpleAnimation:BeginAnim(name)
	self.currentAnimName = name
	local t = self.animData[name]["t"]
	if t == "FrameAnim" then
		self:ChangeRoutine("StateFrameAnim")
	else
		error("not def")
	end
end

function SimpleAnimation:StateFrameAnim(rt)
	local spr = self.owner:GetSpr()
	local data = self.animData[self.currentAnimName]
	while true do
		for idx=data.b, data.e do
			spr.divTexIdx = idx
			rt:Wait(data.w)
		end
	end
end



