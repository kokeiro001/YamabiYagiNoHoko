
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
	
	self:SetTexture("titleBack")
	
	
	local act = TestObject()
	act:Begin()
	act.params.spd = 3
	
	self:AddChild(act)
	
	local menu = TitleMenu()
	menu:Begin()
	menu:CreateSpr()
	menu:GetSpr().name = "menu"
	menu:GetSpr():Show()
	self:AddChild(menu)
	
	menu.x = 0
	menu.y = 260
	menu:ApplyPosToSpr()
	
	menu:AddMenuItem("�Q�[���J�n", function()
		ChangeScreen(GameScreen())
	end)
	
	menu:AddMenuItem("�V�ѕ�", function()
		GS.SoundMgr:PlaySe("metal")
	end)

	menu:AddMenuItem("�I��", function()
		GS.Appli:Exit(0)
	end)
end

function TitleScreen:StateStart(rt)
	while true do
		rt:Wait()
	end
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
	
	-- �O�̓z�̐F�����ɂ���
	self.menuItems[preIdx]:GetSpr():SetTextColorF(Color.Black)
	
	if self.cursor < 1 then
		self.cursor = table.getn(self.menuItems)
	end

	if self.cursor > table.getn(self.menuItems) then
		self.cursor = 1
	end
	
	self.menuItems[self.cursor]:GetSpr():SetTextColorF(Color.Blue)
end





