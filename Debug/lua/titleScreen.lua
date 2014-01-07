local DEBUG_MODE = true

local IS_PLAY_BGM = false
local BGM_NAME = "kamikaze.ogg"

local TUTORIAL_MARK = {
	{x =	164, 	y =	290},	-- 1
	{x =	143,	y =	138},	-- 2
	{x =	322,	y =	115},	-- 3
	{x =	220,	y =	223},	-- 4
	{x =	315,	y =	165},	-- 5
	{x =	337,	y =	280},	-- 6
	{x =	323, 	y =	220},	-- 7
}

class'ScreenBase'(Actor)
function ScreenBase:__init()
	Actor.__init(self)
end


class'TitleScreen'(ScreenBase)
function TitleScreen:__init()
	ScreenBase.__init(self)
	
end

function TitleScreen:Begin()
	ScreenBase.Begin(self)
	
	self:CreateSpr()
	
	-- back
	local backSpr = Sprite()
	backSpr:SetTextureMode("titleBack")
	self:GetSpr():AddChild(backSpr)
	
	-- menu
	self.menu = TitleMenu()
	self.menu:Begin()
	self.menu:CreateSpr()
	self.menu:GetSpr().name = "menu"
	self.menu:GetSpr():Show()
	self:AddChild(self.menu)
	self.menu:SetPos(0, 260)
	self.menu:ApplyPosToSpr()
	
	self.menu:AddMenuItem("ƒQ[ƒ€ŠJŽn", function()
		self:ChangeRoutine("StateToGame")
	end)
	
	self.menu:AddMenuItem("—V‚Ñ•û", function()
		self:OpenTutorial()
	end)

	self.menu:AddMenuItem("I—¹", function()
		GS.Appli:Exit(0)
	end)
	
	-- play bgm
	if IS_PLAY_BGM then
		GS.SoundMgr:PlayBgm(BGM_NAME)
		GS.SoundMgr:SetBgmVol(50)
	end
end

function TitleScreen:OpenTutorial()
	self.menu.enable = false
	
	local closed = function()
		self.menu.enable = true
	end
	
	local tutorial = Tutorial()
	tutorial:Begin(closed)
	self:AddChild(tutorial)
end

function TitleScreen:StateToGame(rt)
	local fadeSpr = Sprite()
	fadeSpr:SetTextureMode("whitePix")
	fadeSpr:SetTextureColorF(Color.Black)
	fadeSpr.drawWidth  = GetProperty("WindowWidth")
	fadeSpr.drawHeight = GetProperty("WindowHeight")
	fadeSpr.z = -1000
	self:GetSpr():AddChild(fadeSpr)
	self:GetSpr():SortZ()
	
	local span = 20
	for i=0, span do
		fadeSpr.alpha = i / span
		rt:Wait(0)
	end
	
	ChangeScreen(GameScreen())
	rt:Wait()
end



class 'Tutorial'(Actor)
function Tutorial:__init(exitFunc)
	Actor.__init(self)
	self.exitFunc = exitFunc
end

function Tutorial:Begin(closedFunc)
	Actor.Begin(self)

	self.closedFunc = closedFunc
	self:CreateSpr()
	
	
	local mouse = DebugMouseViewer()
	mouse:Begin()
	self:AddChild(mouse)
	
	self.backSpr = Sprite()
	self.backSpr.z = 1000
	self.backSpr:SetTextureMode("asoBack")
	self:GetSpr():AddChild(self.backSpr)
	
	self.markSprites = {}
	for i=1, 7 do
		local name = "aso"..i
		local spr = Sprite()
		local size = GS.GrMgr:GetTextureSize(name)
		spr:SetDivTextureMode(name, 2, 1, size.x / 2, size.y)
		spr.divTexIdx = 0
		spr:SetPos(TUTORIAL_MARK[i].x, TUTORIAL_MARK[i].y, -100000)
		spr:SetCenter(size.x / 4, size.y / 2)
		self:GetSpr():AddChild(spr)
		table.insert(self.markSprites, spr)
	end
	
	self.setumeiSpr = Sprite()
	self.setumeiSpr:SetDivTextureMode("asoSetumei", 4, 3, 146, 242)
	self.setumeiSpr:SetPos(475, 80)
	self.setumeiSpr.drawWidth = 130
	self:GetSpr():AddChild(self.setumeiSpr)
	
	self:GetSpr():SortZ()
	
	self.markNum = nil
	self:ChangeMark(1)
end

function Tutorial:ChangeMark(num)
	if self.markNum ~= nil then
		self.markSprites[self.markNum].divTexIdx = 0
	end
	
	self.markNum = num
	
	self.setumeiSpr.divTexIdx = num - 1
	self.markSprites[self.markNum].divTexIdx = 1
end

function Tutorial:StateStart(rt)
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_RIGHT) then
			local tmp = self.markNum + 1
			if tmp > 7 then tmp = 7 end
			self:ChangeMark(tmp)
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_LEFT) then
			local tmp = self.markNum - 1
			if tmp < 1 then tmp = 1 end
			self:ChangeMark(tmp)
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then
			self:Close()
		end
		rt:Wait()
	end
end

function Tutorial:Close()
	self:closedFunc()
	self:Exit()
end




class 'TitleMenu'(Actor)
function TitleMenu:__init()
	Actor.__init(self)
	self.cursor = 1
	self.menuItems = {}
end

function TitleMenu:AddMenuItem(text, selectedFunc)
	local item = Actor()
	item:Begin()
	item:SetText(text, Color.Black)
	
	item:GetSpr().x = GetProperty("WindowWidth") / 2
	item:GetSpr().y = table.getn(self.menuItems) * 30
	item:GetSpr().cx = item:GetSpr().width / 2
	item:GetSpr().cy = item:GetSpr().height / 2
	item:GetSpr().name = "menuItem text="..text
	
	item.selectedFunc = selectedFunc
	
	self:AddChild(item)
	table.insert(self.menuItems, item)
	self:ChangeCursor(0)
end

function TitleMenu:StateStart(rt)
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_UP) then
			self:ChangeCursor(-1)
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_DOWN) then
			self:ChangeCursor(1)
		end

		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then
			self.menuItems[self.cursor]:selectedFunc()
		end
		rt:Wait()
	end
end


function TitleMenu:ChangeCursor(offset)
	local preIdx = self.cursor
	self.cursor = self.cursor + offset
	
	-- ‘O‚Ì“z‚ÌF‚ð•‚É‚·‚é
	self.menuItems[preIdx]:GetSpr():SetTextColorF(Color.Black)
	
	if self.cursor < 1 then
		self.cursor = table.getn(self.menuItems)
	end

	if self.cursor > table.getn(self.menuItems) then
		self.cursor = 1
	end
	
	self.menuItems[self.cursor]:GetSpr():SetTextColorF(Color.Blue)
end





