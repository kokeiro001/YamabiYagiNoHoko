local SurikenShotType = "3×3"
--local SurikenShotType = "QWE"
--local SurikenShotType = "Normal"	-- 今までのやつ



local DebugMode 	= true			-- デバッグ機能を有効にするか
local PlayBgmFlag	= false		-- BGMを再生するか

local ScrollSpd = 3

local PlayerX = 100
local PlayerY = 320

local PatAnimSpd = 1
local PatrolCarX = -50
local PatrolCarY = 310

local EnemyAnimationSpd = 4
local EnemyLine = { 100, 200, 320 }			-- ラインごとの敵の座標
local EnemyLineYoko = { 100, 200, 300 }	-- ラインごとの敵の座標

local EnemyEncountFrame = 10				-- この指定フレームごとに敵が出現する

local SurikenHitFrame = 10	-- スリケンが敵にヒットするまでのフレーム
local SurikenHitSize = 100

local BurstParticleAnimSpd = 3	-- 敵破裂エフェクトのアニメーション速度




if SurikenShotType == "3×3" then
	EnemyLine = { 50, 150, 250, 320 }			-- ラインごとの敵の座標
	EnemyLineYoko = { 100, 200, 300 }	-- ラインごとの敵の座標
end

local MaxCursorHeightIdx	= table.getn(EnemyLine) - 1
local MaxCursorWidthIdx		= table.getn(EnemyLineYoko)





function GetGame()
	if GS.CurrentScreen.name == "GameScreen" then
		return GS.CurrentScreen
	end
	return nil
end

class'GameScreen'(ScreenBase)
function GameScreen:__init()
	ScreenBase.__init(self)
	self.name = "GameScreen"
	
	self.stageNum = 1
	self.allEnemies = {}
	self.surikens = {}
end

function GameScreen:Begin()
	ScreenBase.Begin(self)
	
	self.stageNum = 1
	local player = Player(self)
	player:Begin()
	player.x = PlayerX
	player.y = PlayerY
	player:GetSpr().z = 0
	self:AddChild(player)
	
	local back = GameBack()
	back:Begin()
	back.x = GetProperty("WindowWidth")
	back.y = 0
	back:GetSpr().z = 1000
	self:AddChild(back)

	local pat = PatrolCar()
	pat:Begin()
	pat.x = PatrolCarX
	pat.y = PatrolCarY
	pat:ApplyPosToSpr()
	self:AddChild(pat)
	
	local stageNumAct = Actor()
	stageNumAct:Begin()
	stageNumAct:SetText("STAGE"..self.stageNum)
	stageNumAct.x = 10
	stageNumAct.y = 10
	stageNumAct:ApplyPosToSpr()
	self:AddChild(stageNumAct)
	self.stageNumAct = stageNumAct

	if DebugMode then
		local hint = Actor()
		hint:Begin()
		hint:SetText("F3 Game Script Reload\n"..
								 "A Rapid Suriken \n"..
								 "T Goto Title\n")
		hint:GetSpr():SetFontSize(14)
		hint.x = 600
		hint.y = 10
		hint:ApplyPosToSpr()
		self:AddChild(hint)
	end

	self:GetSpr():SortZ()
	
	if PlayBgmFlag then
		GS.SoundMgr:PlayBgm("gameBgm.ogg")
	end

	self:BeginStage(1)
end

function GameScreen:BeginStage(stageNum)
	self.stageNum = stageNum
	self.stageNumAct:SetText("STAGE"..stageNum)
end

function GameScreen:StateStart(rt)

	-- 
	local encountCnt = 0
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_T) then
			ChangeScreen(TitleScreen())
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_C) then
			self:ChangeRoutine("StateClear")
		end
		
		if encountCnt >= EnemyEncountFrame  then
			local enemy = Enemy(math.random(0, 5))
			enemy:Begin()
			
			enemy.line = math.random(1, MaxCursorHeightIdx)
			enemy.x = GetProperty("WindowWidth") + 30
			enemy.y = EnemyLine[enemy.line]
			enemy:ApplyPosToSpr()
			self:AddEnemy(enemy)

			encountCnt = 0
		end
		
		encountCnt = encountCnt + 1
		rt:Wait()
	end
end

function GameScreen:StateClear(rt)
	
	local stageClear = Actor()
	stageClear:SetText("StageClear")
	stageClear.x = 300
	stageClear.y = 200
	stageClear:ApplyPosToSpr()
	self:AddChild(stageClear)
	
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_1) then
			break
		end
		
		rt:Wait()
	end
	
	self:BeginStage(self.stageNum + 1)
	self:RemoveChild(stageClear)
	self:ChangeRoutine("StateStart")
	rt:Wait()
end

function GameScreen:AddEnemy(enemy)
	self:AddChild(enemy)
	table.insert(self.allEnemies, enemy)
end
function GameScreen:RemoveEnemy(enemy)
	enemy:Dead()
	RemoveValue(self.allEnemies, enemy)
	self:RemoveChild(enemy)
end

function GameScreen:AddSuriken(suriken)
	table.insert(self.surikens, suriken)
	self:AddChild(suriken)
end

function GameScreen:RemoveSuriken(suriken)
	RemoveValue(self.surikens, suriken)
	self:RemoveChild(suriken)
end


function GameScreen:CheckHit(bounds)
	local deleteTmp = nil
	for idx, enemy in ipairs(self.allEnemies) do
		if bounds:CheckHit(Point2DI(enemy.x, enemy.y)) then
			local pcl = BurstParticle()
			pcl:Begin()
			pcl.x = enemy.x
			pcl.y = enemy.y
			self:AddChild(pcl)
			
			if deleteTmp == nil then deleteTmp = {} end
			table.insert(deleteTmp, enemy)
		end
	end
	
	if deleteTmp ~= nil then
		for idx, enemy in ipairs(deleteTmp) do
			self:RemoveEnemy(enemy)
		end
	end
end



class 'Player'(Actor)
function Player:__init(game)
	Actor.__init(self)
	self.game = game
	
	self.cursor = nil
end

function Player:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("yamabi", 6, 4, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "player spr"
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
	
	self.animCnt = 0

	if SurikenShotType == "Normal" then
		self.cursor = PlayerCursor(self)
	elseif SurikenShotType == "QWE" then
		self.cursor = PlayerCursor2(self)
	elseif SurikenShotType == "3×3" then
		self.cursor = PlayerCursor3(self)
	end
	
	self.cursor:Begin()
	self:AddChild(self.cursor)
end

function Player:StateStart(rt)
	self:ApplyPosToSpr()
	while true do
		for idx=0, 5 do
			self:GetSpr().divTexIdx = idx
			for wait = 1, 3 do
				rt:Wait()
			end
		end
	end
end



--@PlayerCursor
class 'PlayerCursor'(Actor)
function PlayerCursor:__init(player)
	Actor.__init(self)
	
	self.player = player
	self.game = player.game
	
	self.iy = 1
	self.ix = 1
	self.y = EnemyLine[self.iy]
	self.x = EnemyLineYoko[self.ix]
end

function PlayerCursor:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("zako", 5, 6, 32, 32)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "player cursor spr"
	self:GetSpr():SetDrawPosAbsolute()
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
	self:GetSpr().alpha = 0.5
	
	self.x = PlayerX
end

function PlayerCursor:StateStart(rt)
	while true do
		-- move cursor
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_UP) then
			self.iy = self.iy - 1
			if self.iy < 1 then
				self.iy = 1
			end
			self.y = EnemyLine[self.iy]
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_DOWN) then
			self.iy = self.iy + 1
			if self.iy > MaxCursorHeightIdx then
				self.iy = MaxCursorHeightIdx
			end
			self.y = EnemyLine[self.iy]
		end
		
		
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) and 
			 GS.InputMgr:IsKeyHold(KeyCode.KEY_RIGHT) then
			self.ix = 2
			self.x = EnemyLineYoko[self.ix]
		elseif GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) then
			self.ix = 1
			self.x = EnemyLineYoko[self.ix]
		elseif GS.InputMgr:IsKeyHold(KeyCode.KEY_RIGHT) then
			self.ix = 3
			self.x = EnemyLineYoko[self.ix]
		else
			self.ix = 2
			self.x = EnemyLineYoko[self.ix]
		end
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) or 
			 (DebugMode and GS.InputMgr:IsKeyHold(KeyCode.KEY_A))then
			self:ThrowSuriken()
		end
		
		self:ApplyPosToSpr()
		rt:Wait()
	end
end

function PlayerCursor:ThrowSuriken()
	local suriken = Suriken()
	suriken:Begin()
	suriken.x = self.player.x + 30
	suriken.y = self.player.y - 10
	suriken:ApplyPosToSpr()
	suriken:CalcMoveParam(self.x, self.y)
	GetGame():AddSuriken(suriken)
end


class 'PlayerCursor2'(PlayerCursor)
function PlayerCursor2:__init(player)
	PlayerCursor.__init(self, player)
end

function PlayerCursor2:StateStart(rt)
	while true do
		local isShot = false
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Q) then
			self.x = EnemyLineYoko[1]
			self.y = EnemyLine[1]
			isShot = true
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_W) then
			self.x = EnemyLineYoko[2]
			self.y = EnemyLine[1]
			isShot = true
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_E) then
			self.x = EnemyLineYoko[3]
			self.y = EnemyLine[1]
			isShot = true
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_A) then
			self.x = EnemyLineYoko[1]
			self.y = EnemyLine[2]
			isShot = true
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_S) then
			self.x = EnemyLineYoko[2]
			self.y = EnemyLine[2]
			isShot = true
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_D) then
			self.x = EnemyLineYoko[3]
			self.y = EnemyLine[2]
			isShot = true
		end
		
		if isShot then
			self:ThrowSuriken()
		end
		
		self:ApplyPosToSpr()
		rt:Wait()
	end
end



class 'PlayerCursor3'(PlayerCursor)
function PlayerCursor3:__init(player)
	PlayerCursor.__init(self, player)
end

function PlayerCursor3:StateStart(rt)
	while true do
		-- move cursor
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_UP) and 
			 GS.InputMgr:IsKeyHold(KeyCode.KEY_DOWN) then
			self.iy = 2
			self.y = EnemyLine[self.iy]
		elseif GS.InputMgr:IsKeyHold(KeyCode.KEY_UP) then
			self.iy = 1
			self.y = EnemyLine[self.iy]
		elseif GS.InputMgr:IsKeyHold(KeyCode.KEY_DOWN) then
			self.iy = 3
			self.y = EnemyLine[self.iy]
		else
			self.iy = 2
			self.y = EnemyLine[self.iy]
		end
		
		
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) and 
			 GS.InputMgr:IsKeyHold(KeyCode.KEY_RIGHT) then
			self.ix = 2
			self.x = EnemyLineYoko[self.ix]
		elseif GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) then
			self.ix = 1
			self.x = EnemyLineYoko[self.ix]
		elseif GS.InputMgr:IsKeyHold(KeyCode.KEY_RIGHT) then
			self.ix = 3
			self.x = EnemyLineYoko[self.ix]
		else
			self.ix = 2
			self.x = EnemyLineYoko[self.ix]
		end
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) or 
			 (DebugMode and GS.InputMgr:IsKeyHold(KeyCode.KEY_A))then
			self:ThrowSuriken()
		end
		
		self:ApplyPosToSpr()
		rt:Wait()
	end
end



-- @Suriken
class 'Suriken'(Actor)
function Suriken:__init()
	Actor.__init(self)
	
	self.srcX = 0
	self.srcY = 0
	self.destX = 0
	self.destY = 0
	
	self.hitable = false
end

function Suriken:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("suriken", 4, 1, 32, 32)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "suriken spr"
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
	
	self:GetSpr().rot = math.random(0, 100)
	self:GetSpr().rotX = 0
	self:GetSpr().rotY = 0
end

function Suriken:StateStart(rt)
	local cnt = SurikenHitFrame
	for i = 1, cnt do
		self:GetSpr().rot = self:GetSpr().rot + math.rad(30)
		self.x = self.srcX + ((self.destX - self.srcX) * i) / cnt
		self.y = self.srcY + ((self.destY - self.srcY) * i) / cnt
		self:ApplyPosToSpr()
		rt:Wait()
	end
	
	local hitBounds = RectI(
			self.x - SurikenHitSize / 2, 
			self.y - SurikenHitSize / 2,
			SurikenHitSize, SurikenHitSize)
	GetGame():CheckHit(hitBounds)
	GetGame():RemoveSuriken(self)
	self:Dead()
	rt:Wait()
end

function Suriken:CalcMoveParam(x, y)
	self.srcX = self.x
	self.srcY = self.y
	
	self.destX = x
	self.destY = y
end








--@Enemy
class 'Enemy'(Actor)
function Enemy:__init(kind)
	Actor.__init(self)
	
	self.kind = kind
end

function Enemy:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("zako", 5, 6, 32, 32)
	self:GetSpr().divTexIdx = self.kind * 5
	self:GetSpr().name = "player spr"
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
	
	self.animCnt = 0
end

function Enemy:StateStart(rt)
	while true do
		self.x = self.x - ScrollSpd
		if self.x < -30 then
			self:Dead()
			rt:Wait()
		end
		
		self.animCnt = self.animCnt + 1
		if self.animCnt > EnemyAnimationSpd then
			local idx = self:GetSpr().divTexIdx
			idx = idx + 1
			if idx >= (self.kind + 1) * 5 then
				idx = self.kind * 5
			end
			self:GetSpr().divTexIdx = idx
			self.animCnt = 0
		end
		
		self:ApplyPosToSpr()
		rt:Wait()
	end
end




--@GameBack
class 'GameBack'(Actor)
function GameBack:__init()
	Actor.__init(self)
end

function GameBack:Begin()
	Actor.Begin(self)
	
	self:CreateSpr()
	
	self.sprites = {}
	local sprX = 0
	for i = 1, 3 do
		local spr = Sprite()
		spr:SetTextureMode("stage1back")
		spr.name = "stage1 spr num="..i
		spr.x = sprX
		self:GetSpr():AddChild(spr)
		sprX = sprX + spr.width
		table.insert(self.sprites, spr)
	end
end

function GameBack:StateStart(rt)
	while true do
		for idx, spr in pairs(self.sprites) do
			spr.x = spr.x - ScrollSpd
			if spr.x + spr.width < 0 then
				spr.x = spr.x + 3 * spr.width
			end
		end
		rt:Wait()
	end
end






--@PatrolCar
class 'PatrolCar'(Actor)
function PatrolCar:__init()
	Actor.__init(self)
end

function PatrolCar:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("patcar", 4, 4, 100, 50)
	self:GetSpr().divTexIdx = 12
	self:GetSpr().name = "patcar spr"
	
	self.animCnt = 0
end

function PatrolCar:StateStart(rt)
	while true do
		self.animCnt = self.animCnt + 1
		if self.animCnt > PatAnimSpd then
			self:GetSpr().divTexIdx = self:GetSpr().divTexIdx + 1
			if self:GetSpr().divTexIdx >= 16 then
				self:GetSpr().divTexIdx = 12
			end
			self.animCnt = 0
		end
		rt:Wait()
	end
end



--@BurstParticle
class 'BurstParticle'(Actor)
function BurstParticle:__init()
	Actor.__init(self)
end


function BurstParticle:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("burst0", 10, 1, 120, 120)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "burst spr"
	
	self:GetSpr().cx = 60
	self:GetSpr().cy = 80
	
	self.animCnt = 0
	
	GS.SoundMgr:PlaySe("burst")
end



function BurstParticle:StateStart(rt)
	self:ApplyPosToSpr()
	for idx = 1, 10 do
		for waitCnt = 1, BurstParticleAnimSpd do
			rt:Wait()
		end
		self:GetSpr().divTexIdx = self:GetSpr().divTexIdx + 1
	end
	self:Dead()
	rt:Wait()
end





