--local TEST_TYPE = "Normal"
--local TEST_TYPE = "HoldDash"	-- 右キー押しっぱなしでダッシュ
--local TEST_TYPE = "Step"		-- 右キー押すと一定時間ダッシュ
local TEST_TYPE = "Charge"	-- 左キー押しっぱなしでチャージ

local DEBUG_MODE 	= true
local IS_PLAY_BGM	= false

local STAGE_FRAME = {	300, 300, 300	}	-- ステージのクリアまでの時間
local STAGE_BACK_ALPHA = {	0.8, 0.8, 0.8	}	-- ステージの背景透明度

local MAX_STAGE_NUM = table.getn(STAGE_FRAME)

-- lines
local LINE_HEIGHTS = { 100, 200, 320 }
local LINE_TOP			= 1
local LINE_MIDDLE		= 2
local LINE_BOTTOM		= 3

-- scroll
local SCROLL_SPD 			= 3
local DASH_SCROLL_SPD	= 8		-- ダッシュ中のスクロール速度
local STEP_FRAME 			= 30	-- ダッシュ時間

-- player
local PLAYER_X = 100
local PLAYER_Y = 320

-- enemy
local ENEMY_ANIM_SPD = 4
local ENEMY_ENCOUNT_FRAME = 20				-- 敵の出現間隔
local ENEMY_ENCOUNT_FRAME_DASH = 7		-- ダッシュ中の敵の出現間隔

local TOP_ENEMY_SPD 		= 10					-- 上段の敵の速度
local MIDDLE_ENEMY_SPD	= SCROLL_SPD	-- 中段
local BOTTOM_ENEMY_SPD	= SCROLL_SPD	-- 下段

local PROB_TOP_ENEMY			= 5					-- 出現比率
local PROB_MIDDLE_ENEMY		= 85
local PROB_BOTTOM_ENEMY		= 100

-- suriken
local SURIKEN_HIT_FRAME = 10					-- 敵にヒットするまでのフレーム
local LEFT_CHARGE_FRAME = 120					-- 左キーのチャージ時間

local GAUGE_Y 					= PLAYER_Y + 30
local MAX_GAUGE_WIDTH 	= 100
local GAUGE_HEIGHT 			= 15

local LINE_MIDDLE_LEFT_AREA = 400				-- 中段の左右判定X座標
local SLASHABEL_X_MIN = PLAYER_X + 30		-- 下段 斬れる最小X
local SLASHABEL_X_MAX = PLAYER_X + 200	-- 下段 斬れる最大X


-- particle
local BURST_ANIM_SPD = 3	-- 敵破裂エフェクトのアニメーション速度

-- patca
local PAT_ANIM_SPD = 1
local PATCAR_X = -50
local PATCAR_Y = 310

-- marker
local MARKER_LEFT_X			= 100
local MARKER_RIGHT_X		= GetProperty("WindowWidth") - 100
local MARKER_Y					= 30
local MARKER_HEIGHT			= 20
local MARKER_ANIM_SPD		= 10

-- demo tex names
local STAGE_START_DEMO_NAMES = {"stage1demo", "stage2demo", "stage3demo"}
local STAGE_CLEAR_DEMO_NAMES = {"stage1clear", "stage2clear", "stage3clear"}

local ROCK_ROT_SPD = 	-5		-- 毎フレーム指定角度転がる。度数法。


local STAGE_BACK_NAMES = { "stage1back", "stage2back", "stage3back" }



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
	
	self.backId = nil
end

function GameScreen:Begin()
	ScreenBase.Begin(self)
	
	self.stageNum = 1
	local player = Player(self)
	player:Begin()
	player.x = PLAYER_X
	player.y = PLAYER_Y
	player:GetSpr().z = 0
	self:AddChild(player)
	
	local back = GameBack()
	back:Begin()
	back.x = GetProperty("WindowWidth")
	back.y = 0
	back:GetSpr().z = 1000
	self:AddChild(back)
	self.backId = back.id

	local pat = PatrolCar()
	pat:Begin()
	pat.x = PATCAR_X
	pat.y = PATCAR_Y
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

	local clearFunc = function()
		self:ChangeRoutine("StateClear")
	end
	local marker = StageMarker()
	marker:Begin(clearFunc, STAGE_FRAME[self.stageNum])
	self:AddChild(marker)

	if DEBUG_MODE then
		if false then
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

		local slash = Actor()
		slash:Begin()
		slash:SetText("|")
		slash.x = SLASHABEL_X_MAX
		slash.y = LINE_HEIGHTS[LINE_BOTTOM]
		slash:ApplyPosToSpr()
		self:AddChild(slash)

		local left = Actor()
		left:Begin()
		left:SetText("|")
		left.x = LINE_MIDDLE_LEFT_AREA
		left.y = LINE_HEIGHTS[LINE_MIDDLE]
		left:ApplyPosToSpr()
		self:AddChild(left)
	end

	self:GetSpr():SortZ()
	
	if IS_PLAY_BGM then
		GS.SoundMgr:PlayBgm("gameBgm.ogg")
	end
	
	self.stageNum = nil
end

function GameScreen:BeginStage(stageNum)
	self.encountCnt = 0
	self.stageNum = stageNum
	self.stageNumAct:SetText("STAGE"..stageNum)
	
	for idx, chr in ipairs(self:GetChild()) do
		if chr.BeginStage ~= nil then
			chr:BeginStage(self.stageNum)
		end
	end
end

function GameScreen:StateStart(rt)
	local spr = Sprite()
	if self.stageNum == nil then
		self.stageNum = 1
	else
		self.stageNum = self.stageNum + 1
	end
	spr:SetTextureMode(STAGE_START_DEMO_NAMES[self.stageNum])
	self:GetSpr():AddChild(spr)
	
	for i=1, 60 do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then break end
		rt:Wait()
	end
	
	self:GetSpr():RemoveChild(spr)
	self:Goto("StateGame")
end

function GameScreen:StateGame(rt)
	self:BeginStage(self.stageNum)
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_C) then
			self:ChangeRoutine("StateClear")
		end
		
		self:CheckAddEnemy()
		
		rt:Wait()
	end
end

function GameScreen:CheckAddEnemy()
	local spAddFlag = false
	if TestType == "HoldDash" or "Step" then
		local cur = self:GetChildId(self.cursorId)
		if cur.isDash == true and self.encountCnt >= ENEMY_ENCOUNT_FRAME_DASH then
			spAddFlag = true
		end
	end
	
	if self.encountCnt >= ENEMY_ENCOUNT_FRAME or spAddFlag then
		local back = self:GetChildId(self.backId)
		local rnd = math.random(1, PROB_TOP_ENEMY + PROB_MIDDLE_ENEMY + PROB_BOTTOM_ENEMY)
		
		rnd = rnd  - PROB_TOP_ENEMY
		local line = nil
		local spd = nil
		while true do
			if rnd < 0 then
				line = LINE_TOP
				spd = (back.scrollSpd * TOP_ENEMY_SPD) / SCROLL_SPD
				break
			end
			rnd = rnd  - PROB_MIDDLE_ENEMY
			if rnd < 0 then
				line = LINE_MIDDLE
				spd = (back.scrollSpd * MIDDLE_ENEMY_SPD) / SCROLL_SPD
				break
			end
			rnd = rnd  - PROB_BOTTOM_ENEMY
			if rnd < 0 then
				line = LINE_BOTTOM
				spd = (back.scrollSpd * BOTTOM_ENEMY_SPD) / SCROLL_SPD
				break
			end
		end
		
		local enemy = nil
		if line == LINE_BOTTOM then
			enemy = Rock()
		else
			enemy = Enemy(math.random(0, 5))
		end
		enemy:Begin()
		
		enemy.line = line
		enemy.spd = spd
		enemy.x = GetProperty("WindowWidth") + 30
		enemy.y = LINE_HEIGHTS[enemy.line]
		enemy:ApplyPosToSpr()
		self:AddEnemy(enemy)

		self.encountCnt = 0
	end
	self.encountCnt = self.encountCnt + 1
end

function GameScreen:StateClear(rt)
	-- すべての敵をbom
	local deadTargets = {}
	for idx, enemy in ipairs(self.allEnemies) do
		if enemy.suriken == nil then
			table.insert(deadTargets, enemy)
		end
	end
	while table.getn(deadTargets) > 0 do
		local enemy = deadTargets[1]
		self:DeadEnemy(enemy)
		RemoveValue(deadTargets, enemy)
	end
	
	
	local stageClear = Actor()
	if self.stageNum == MAX_STAGE_NUM then
		stageClear:SetText("AllClear")
	else
		stageClear:SetText("Stage"..self.stageNum.." Clear")
	end
	stageClear.x = 300
	stageClear.y = 200
	stageClear:ApplyPosToSpr()
	self:AddChild(stageClear)
	
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then
			break
		end
		
		rt:Wait()
	end
	
	if self.stageNum == MAX_STAGE_NUM then
		ChangeScreen(TitleScreen())
	else
		self:RemoveChild(stageClear)
		self:ChangeRoutine("StateStart")
	end
	rt:Wait()
end

function GameScreen:GetEnemies()
	return self.allEnemies
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

function GameScreen:DeadEnemy(enemy)
	local pcl = BurstParticle()
	pcl:Begin()
	pcl.x = enemy.x
	pcl.y = enemy.y
	self:AddChild(pcl)
	self:RemoveEnemy(enemy)
end

function GameScreen:ChangeScrollSpd(spd)
	for idx, enemy in ipairs(self.allEnemies) do
		if enemy.line == LINE_TOP then
			enemy.spd = (TOP_ENEMY_SPD * spd) / SCROLL_SPD
			
		elseif enemy.line == LINE_MIDDLE then
			enemy.spd = (MIDDLE_ENEMY_SPD * spd) / SCROLL_SPD
			
		elseif enemy.line == LINE_BOTTOM then
			enemy.spd = (BOTTOM_ENEMY_SPD * spd) / SCROLL_SPD
		else
			error("unknown line")
		end
	end
	
	local back = self:GetChildId(self.backId)
	back.scrollSpd = (SCROLL_SPD * spd) / SCROLL_SPD
end




class 'Player'(Actor)
function Player:__init(game)
	Actor.__init(self)
	self.game = game
end

function Player:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("yamabi", 6, 4, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "player spr"
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
	
	self.animCnt = 0

	local cursor = nil
	if TEST_TYPE == "Normal" then
		cursor = PlayerCursor(self)
	elseif TEST_TYPE == "HoldDash" then
		cursor = PlayerCursorHoldDash(self)
	elseif TEST_TYPE == "Step" then
		cursor = PlayerCursorStep(self)
	elseif TEST_TYPE == "Charge" then
		cursor = PlayerCursorCharge(self)
	else
		error("not def test tyep")
	end
	
	cursor:Begin()
	GetGame():AddChild(cursor)
	GetGame().cursorId = cursor.id
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
end

function PlayerCursor:ThrowSuriken(act)
	local suriken = Suriken()
	suriken:Begin()
	suriken.target = act
	suriken.x = self.player.x + 30
	suriken.y = self.player.y - 10
	suriken:ApplyPosToSpr()
	suriken:CalcMoveParam(act.x - act.spd * SURIKEN_HIT_FRAME, act.y)
	act.suriken = suriken
	GetGame():AddSuriken(suriken)
end

function PlayerCursor:StateStart(rt)
	while true do
		-- move cursor
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_UP) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_TOP and
					 enemy.suriken == nil then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_DOWN) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_BOTTOM and 
					 enemy.suriken == nil and
					 (SLASHABEL_X_MIN <= enemy.x and enemy.x <= SLASHABEL_X_MAX) then
					self:ThrowSuriken(enemy)
				end
			end
		end
		
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_LEFT) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_MIDDLE and 
					 enemy.suriken == nil and
					 enemy.x < LINE_MIDDLE_LEFT_AREA then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_RIGHT) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_MIDDLE and 
					 enemy.suriken == nil and
					 enemy.x >= LINE_MIDDLE_LEFT_AREA then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		
		rt:Wait()
	end
end



class 'PlayerCursorHoldDash'(PlayerCursor)
function PlayerCursorHoldDash:__init(player)
	PlayerCursor.__init(self, player)
	self.isDash = false
end

function PlayerCursorHoldDash:StateStart(rt)
	while true do
		-- move cursor
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_UP) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_TOP and
					 enemy.suriken == nil then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_DOWN) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_BOTTOM and 
					 enemy.suriken == nil and
					 (SLASHABEL_X_MIN <= enemy.x and enemy.x <= SLASHABEL_X_MAX) then
					self:ThrowSuriken(enemy)
				end
			end
		end
		
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_LEFT) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_MIDDLE and 
					 enemy.suriken == nil then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_RIGHT) then
			self.isDash = true
			GetGame():ChangeScrollSpd(DASH_SCROLL_SPD)
		else 
			self.isDash = false
			GetGame():ChangeScrollSpd(SCROLL_SPD)
		end
		
		rt:Wait()
	end
end


class 'PlayerCursorStep'(PlayerCursor)
function PlayerCursorStep:__init(player)
	PlayerCursor.__init(self, player)
	
	self.stepCnt = 0
end

function PlayerCursorStep:StateStart(rt)
	while true do
		-- move cursor
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_UP) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_TOP and
					 enemy.suriken == nil then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_DOWN) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_BOTTOM and 
					 enemy.suriken == nil and
					 (SLASHABEL_X_MIN <= enemy.x and enemy.x <= SLASHABEL_X_MAX) then
					self:ThrowSuriken(enemy)
				end
			end
		end
		
		
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_LEFT) then
			local enemies = GetGame():GetEnemies()
			for idx, enemy in ipairs(enemies) do
				if enemy.line == LINE_MIDDLE and 
					 enemy.suriken == nil then
					self:ThrowSuriken(enemy)
					break
				end
			end
		end
		
		if self.stepCnt == 0
			 and GS.InputMgr:IsKeyPush(KeyCode.KEY_RIGHT) then
			self.stepCnt = STEP_FRAME
			GetGame():ChangeScrollSpd(DASH_SCROLL_SPD)
		end
		
		if self.stepCnt > 0 then
			self.stepCnt = self.stepCnt - 1
			if self.stepCnt == 0 then
				GetGame():ChangeScrollSpd(SCROLL_SPD)
			end
		end

		rt:Wait()
	end
end

class 'PlayerCursorCharge'(PlayerCursor)
function PlayerCursorCharge:__init(player)
	PlayerCursor.__init(self, player)
	
	self.stepCnt = 0
end

function PlayerCursorCharge:Begin()
	PlayerCursor.Begin(self)
	
	local gauge = Gauge()
	
	local releaseFunc = function()
		local enemies = GetGame():GetEnemies()
		local targets = {}
		for idx, enemy in ipairs(enemies) do
			if enemy.line == LINE_MIDDLE then
				table.insert(targets, enemy)
			end
		end
		
		for idx, enemy in ipairs(targets) do
			self:ThrowSuriken(enemy)
		end
	end
	
	gauge:Begin(releaseFunc)
	gauge.x = PLAYER_X - MAX_GAUGE_WIDTH / 2 + 15
	gauge.y = GAUGE_Y
	
	GetGame():AddChild(gauge)
	self.gaugeId = gauge.id
end

function PlayerCursorCharge:StateStart(rt)
	while true do
		if not GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) then
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_UP) then
				local enemies = GetGame():GetEnemies()
				for idx, enemy in ipairs(enemies) do
					if enemy.line == LINE_TOP and
						 enemy.suriken == nil then
						self:ThrowSuriken(enemy)
						break
					end
				end
			end
			
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_DOWN) then
				local enemies = GetGame():GetEnemies()
				for idx, enemy in ipairs(enemies) do
					if enemy.line == LINE_BOTTOM and 
						 enemy.suriken == nil and
						 (SLASHABEL_X_MIN <= enemy.x and enemy.x <= SLASHABEL_X_MAX) then
						self:ThrowSuriken(enemy)
						break
					end
				end
			end

			if GS.InputMgr:IsKeyPush(KeyCode.KEY_RIGHT) then
				local enemies = GetGame():GetEnemies()
				for idx, enemy in ipairs(enemies) do
					if enemy.line == LINE_MIDDLE and 
						 enemy.suriken == nil then
						self:ThrowSuriken(enemy)
						break
					end
				end
			end
		end
		rt:Wait()
	end
end



-- @Suriken
class 'Suriken'(Actor)
function Suriken:__init()
	Actor.__init(self)
	
	self.target = nil
	
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
	local cnt = SURIKEN_HIT_FRAME
	for i = 1, cnt do
		self:GetSpr().rot = self:GetSpr().rot + math.rad(30)
		self.x = self.srcX + ((self.destX - self.srcX) * i) / cnt
		self.y = self.srcY + ((self.destY - self.srcY) * i) / cnt
		self:ApplyPosToSpr()
		rt:Wait()
	end
	
	GetGame():DeadEnemy(self.target)
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
	
	self.spd = 0
	self.kind = kind
	self.suriken = nil
end

function Enemy:Dead()
	Actor.Dead(self)
	self.suriken = nil
end

function Enemy:Begin()
	Actor.Begin(self)
	self:SetActTexture()
end

function Enemy:SetActTexture()
	self.animCnt = 0
	self:SetDivTexture("zako", 5, 6, 32, 32)
	self:GetSpr().divTexIdx = self.kind * 5
	self:GetSpr().name = "zako spr"
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
end

function Enemy:StateStart(rt)
	while true do
		self.x = self.x - self.spd
		if self.x < -30 then
			GetGame():RemoveEnemy(self)
			rt:Wait()
		end
		
		self.animCnt = self.animCnt + 1
		if self.animCnt > ENEMY_ANIM_SPD then
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

--@Rock
class 'Rock'(Enemy)
function Rock:__init()
	Enemy.__init(self)
	
	self.spd = 0
	self.kind = kind
	self.suriken = nil
end

function Rock:SetActTexture()
	self:SetDivTexture("rock", 4, 1, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "rock spr"
	self:GetSpr().cx = 25
	self:GetSpr().cy = 25
end

function Rock:StateStart(rt)
	while true do
		self.x = self.x - self.spd
		if self.x < -30 then
			GetGame():RemoveEnemy(self)
			rt:Wait()
		end
		
		self:GetSpr().rot = self:GetSpr().rot + math.rad(ROCK_ROT_SPD)
		
		self:ApplyPosToSpr()
		rt:Wait()
	end
end




--@GameBack
class 'GameBack'(Actor)
function GameBack:__init()
	Actor.__init(self)
	self.scrollSpd = nil
end

function GameBack:Begin()
	Actor.Begin(self)
	
	self.scrollSpd = SCROLL_SPD
	self:CreateSpr()

	self.sprites = {}
	local sprX = 0
	for i = 1, 3 do
		local spr = Sprite()
		spr:SetTextureMode("stage1back")
		spr.name = "stage back spr num="..i
		spr.x = sprX
		self:GetSpr():AddChild(spr)
		sprX = sprX + spr.width
		table.insert(self.sprites, spr)
	end
end

function GameBack:BeginStage(stageNum)
	local sprX = 0
	for idx, spr in ipairs(self.sprites) do
		spr:SetTextureMode(STAGE_BACK_NAMES[stageNum])
		spr.x = sprX
		spr.alpha = STAGE_BACK_ALPHA[stageNum]
		sprX = sprX + spr.width
	end
end

function GameBack:StateStart(rt)
	while true do
		for idx, spr in pairs(self.sprites) do
			spr.x = spr.x - self.scrollSpd
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
		if self.animCnt > PAT_ANIM_SPD then
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
		for waitCnt = 1, BURST_ANIM_SPD do
			rt:Wait()
		end
		self:GetSpr().divTexIdx = self:GetSpr().divTexIdx + 1
	end
	self:Dead()
	rt:Wait()
end






--@Gauge
class 'Gauge'(Actor)
function Gauge:__init()
	Actor.__init(self)

	self.chargeCnt = nil
end


function Gauge:Begin(func, funcParam)
	Actor.Begin(self)
	self.releaseGaugeFunc = func
	self.releaseGaugeParam = funcParam

	self:SetTexture("whitePix")
	
	self:GetSpr().drawHeight = GAUGE_HEIGHT
	
	self.chargeCnt = 0
	self:GetSpr():SetTextureColorF(Color.White)
	self:GetSpr().drawWidth  = 1

	local back = Sprite()
	back:SetTextureMode("whitePix")
	back.alpha = 0.3
	back.drawWidth  = MAX_GAUGE_WIDTH
	back.drawHeight = GAUGE_HEIGHT
	back.z = 10
	self:GetSpr():AddChild(back)
end

function Gauge:StateStart(rt)
	self:ApplyPosToSpr()
	
	self.chargeCnt = 0
	self:GetSpr():SetTextureColorF(Color.White)
	self:GetSpr().drawWidth  = 1
	
	while true do
		if GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) then
			self:Goto("StateCharge")
		end
		rt:Wait()
	end
end

function Gauge:StateCharge(rt)
	self.chargeCnt = 0
	while GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) do
		self.chargeCnt = self.chargeCnt + 1
		
			self:GetSpr().drawWidth  = 1 + (MAX_GAUGE_WIDTH * self.chargeCnt) / LEFT_CHARGE_FRAME
			
		if self.chargeCnt == LEFT_CHARGE_FRAME then
			self:Goto("StateMaxHold")
		end
		rt:Wait()
	end
	self:Goto("StateStart")
end

function Gauge:StateMaxHold(rt)
	GS.SoundMgr:PlaySe("metal")
	self:GetSpr():SetTextureColorF(Color.Red)
	while GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) do
		rt:Wait()
	end
	
	if self.releaseGaugeFunc ~= nil then
		self.releaseGaugeFunc(self.releaseGaugeParam)
	end
	
	self:Goto("StateStart")
end



--@StageMarker
class 'StageMarker'(Actor)
function StageMarker:__init()
	Actor.__init(self)
	self.nowFrame = 0
end

function StageMarker:Begin(func, stageFrame)
	Actor.Begin(self)
	self.goalFunc = func
	self.stageFrame = stageFrame
	self:CreateSpr()
	
	self.isGoaled = false
	
	local left = Sprite()
	left:SetTextureMode("whitePix")
	left:SetTextureColorF(Color.Black)
	left.x 			= MARKER_LEFT_X
	left.y 			= MARKER_Y
	left.cx 		= left.width / 2
	left.cy 		= left.height / 2
	left.drawWidth 	= 1
	left.drawHeight	= MARKER_HEIGHT
	self:GetSpr():AddChild(left)
	
	local right = Sprite()
	right:SetTextureMode("whitePix")
	right:SetTextureColorF(Color.Black)
	right.x 		= MARKER_RIGHT_X
	right.y 		= MARKER_Y
	right.cx 		= right.width / 2
	right.cy 		= right.height / 2
	right.drawWidth 	= 1
	right.drawHeight	= MARKER_HEIGHT
	self:GetSpr():AddChild(right)
	
	local yamabi = Sprite()
	yamabi.name = "maker"
	yamabi:SetDivTextureMode("runMarker", 6, 2, 32, 32)
	yamabi.y = MARKER_Y + 10
	yamabi.divTexIdx	= 1
	yamabi.cx 				= 16
	yamabi.cy 				= 16
	self:GetSpr():AddChild(yamabi)
	self.maker = yamabi
	
	self.animCnt = 0
end


function StageMarker:BeginStage(stageNum)
	self.isGoaled = false
	self.nowFrame = 0
end

function StageMarker:InitStageClear(stageNum)
	self.isGoaled = true
	local width = MARKER_RIGHT_X - MARKER_LEFT_X
	self.maker.x = MARKER_LEFT_X + width
end

function StageMarker:StateStart(rt)
	while true do
		self.animCnt = self.animCnt + 1
		if self.animCnt >= MARKER_ANIM_SPD then
			self.maker.divTexIdx = self.maker.divTexIdx + 1
			if self.maker.divTexIdx >= 6 then
				self.maker.divTexIdx = 0
			end
			self.animCnt = 0
		end
		
		if not self.isGoaled then
			self.nowFrame = self.nowFrame + 1
			local width = MARKER_RIGHT_X - MARKER_LEFT_X
			self.maker.x = MARKER_LEFT_X + (width * self.nowFrame) / self.stageFrame
			
 			if self.nowFrame >= self.stageFrame then
				self:goalFunc()
				self.isGoaled = true
			end
		end
		
		rt:Wait()
	end
end










