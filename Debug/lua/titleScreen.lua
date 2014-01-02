local DEBUG_MODE = true


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
	local backSpr = Sprite()
	backSpr:SetTextureMode("titleBack")
	self:GetSpr():AddChild(backSpr)
	
	if DEBUG_MODE then
		local act = TestObject()
		act:Begin()
		act.params.spd = 3
		self:AddChild(act)
	end
	
	local menu = TitleMenu()
	menu:Begin()
	menu:CreateSpr()
	menu:GetSpr().name = "menu"
	menu:GetSpr():Show()
	self:AddChild(menu)
	
	menu.x = 0
	menu.y = 260
	menu:ApplyPosToSpr()
	
	menu:AddMenuItem("ゲーム開始", function()
		self:ChangeRoutine("StateToGame")
	end)
	
	menu:AddMenuItem("遊び方", function()
		GS.SoundMgr:PlaySe("metal")
	end)

	menu:AddMenuItem("終了", function()
		GS.Appli:Exit(0)
	end)
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


class 'TestObject'(Actor)
function TestObject:__init()
	Actor.__init(self)

end

function TestObject:Begin()
	Actor.Begin(self)
	self:SetTexture("player")
end

function TestObject:StateStart(rt)
	local spd = self.params.spd
	while true do
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) then
			self.x = self.x - spd
		end
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_RIGHT) then
			self.x = self.x + spd
		end
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_UP) then
			self.y = self.y - spd
		end
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_DOWN) then
			self.y = self.y + spd
		end
		self:ApplyPosToSpr()
		rt:Wait()
	end
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
	
	-- 前の奴の色を黒にする
	self.menuItems[preIdx]:GetSpr():SetTextColorF(Color.Black)
	
	if self.cursor < 1 then
		self.cursor = table.getn(self.menuItems)
	end

	if self.cursor > table.getn(self.menuItems) then
		self.cursor = 1
	end
	
	self.menuItems[self.cursor]:GetSpr():SetTextColorF(Color.Blue)
end





