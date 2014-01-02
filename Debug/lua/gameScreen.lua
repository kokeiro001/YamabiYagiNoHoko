local DEBUG_MODE 	= true
local IS_PLAY_BGM	= false

local STAGE_FRAME = {	3000, 3000, 3000	}	-- ステージのクリアまでの時間
local STAGE_BACK_ALPHA = {	0.8, 0.8, 0.8	}	-- ステージの背景透明度

local MAX_STAGE_NUM = table.getn(STAGE_FRAME)

-- lines
local LINE_HEIGHTS = { 100, 200, 300 }
local LINE_TOP			= 1
local LINE_MIDDLE		= 2
local LINE_BOTTOM		= 3

-- scroll
local SCROLL_SPD 			= 3

-- player
local PLAYER_X = 100
local PLAYER_Y = LINE_HEIGHTS[LINE_BOTTOM]

-- enemy
local ENEMY_ENCOUNT_FRAME 	= 20

local ENEMY_ANIM_SPD 	= 4
local CELES_ANIM_SPD	= 10
local ROCK_ROT_SPD 		= 0

local TOP_ENEMY_SPD 		= 10					-- 上段の敵の速度
local MIDDLE_ENEMY_SPD	= SCROLL_SPD	-- 中段
local BOTTOM_ENEMY_SPD	= SCROLL_SPD	-- 下段

local TOP_ENEMY_SPAN_MIN				=  60		-- 敵の出現間隔
local TOP_ENEMY_SPAN_MAX				= 120
local BOTTOM_ENEMY_SPAN_MIN			=  60
local BOTTOM_ENEMY_SPAN_MAX			= 120


local HP_ZAKO			= 1		-- hp
local HP_ROCK			= 1
local HP_CELES		= 2
local PROB_CELES_STAGE2		= 30		-- ステージ２のセレスっちの出現確率(%)
local PROB_CELES_STAGE3		= 100

-- suriken
local DEAD_REASON_TIME_UP			= -1	-- タイムアップで死にますよID
local ATTACK_NORMAL_SURIKEN		= 1	-- 攻撃の種類
local ATTACK_CHARGE1_SURIKEN	= 2
local ATTACK_CHARGE2_SURIKEN	= 3
local ATTACK_SLASH					  = 4
local ATTACK_DAMAGE = {1, 1, 2, 1}	-- 攻撃力。直前のインデックス順

local SURIKEN_HIT_FRAME = 10		-- スリケンが敵に当たるまでの時間
local LEFT_CHARGE_FRAME = 60
local LEFT_CHARGE2_FRAME = 30
local SURIKEN_WAIT_FRAME = 15

local GAUGE_Y 					= PLAYER_Y + 30
local MAX_GAUGE_WIDTH 	= 100
local GAUGE_HEIGHT 			= 15

local SLASHABEL_X_MIN = PLAYER_X + 30		-- 下段 斬れる最小X
local SLASHABEL_X_MAX = PLAYER_X + 200	-- 下段 斬れる最大X


-- particle
local BURST_ANIM_SPD = 3	-- 敵破裂エフェクトのアニメーション速度
local SLASHED_ROCK_PCL_SPAN = 60
local SLASH_ANIM_SPD = 1

-- patca
local PAT_ANIM_SPD	= 1
local PATCAR_X 			= -50
local PATCAR_Y 			= PLAYER_Y - 10

-- marker
local MARKER_LEFT_X			= 100
local MARKER_RIGHT_X		= GetProperty("WindowWidth") - 100
local MARKER_Y					= 10
local MARKER_HEIGHT			= 20
local MARKER_ANIM_SPD		= 10

-- demo tex names
local STAGE_START_DEMO_NAMES = {"stage1demo", "stage2demo", "stage3demo"}
local STAGE_CLEAR_DEMO_NAMES = {"stage1clear", "stage2clear", "stage3clear"}


local STARTDEMO_FADEIN_FRAME	= 20
local CLEARDEMO_FADEOUT_FRAME	= 20

local STAGE_BACK_NAMES = { "stage1back", "stage2back", "stage3back" }
local GET_ITEM_WAIT_FRAME = 10

-- haiku
local SHOW_HAIKU_FRAME = 120
local HAIKU_TEXT = {	-- 半角スペースで区切ってね
	{"イナカの道は 走るだけでも キモチイイ", "テキがいる キビシイバトルに なりそうだ", "かかってくるなら ヨウシャしない インガオホー"},
	{"ニンジャめし 買うの忘れてた", "ナンデ？パトカーナンデ？", "ゼッタイに あきらめはしない 待ってろトモミ"},
	{"どなたかな 気持ち悪くなった 帰ろう", "長く 苦しい 戦いだった", "セレスっち まずは名前を なんとかすべし"}
}


local Z_ORDER_FRONT		= -1000
local Z_ORDER_SLASH		= 90
local Z_ORDER_PLAYER	= 100
local Z_ORDER_ROCK		= 110
local Z_ORDER_BACK		= 1000


function GetStage()
	if GS.CurrentScreen.name == "GameScreen" then
		return GS.CurrentScreen.stage
	end
	return nil
end
function GetPlayer()
	return GetStage().player
end


class'GameScreen'(ScreenBase)
function GameScreen:__init()
	ScreenBase.__init(self)
	self.name = "GameScreen"
	self.stage = nil
end

function GameScreen:Begin()
	ScreenBase.Begin(self)

	self.fadeAct = Actor()
	self.fadeAct:Begin()
	self.fadeAct:SetTexture("whitePix")
	self.fadeAct:GetSpr():SetTextureColorF(Color.Black)
	self.fadeAct:GetSpr():Hide()
	self.fadeAct:GetSpr().drawWidth  = GetProperty("WindowWidth")
	self.fadeAct:GetSpr().drawHeight = GetProperty("WindowHeight")
	self.fadeAct:GetSpr().z = Z_ORDER_FRONT
	self:AddChild(self.fadeAct)
	
	self.stage = Stage(self)
	self.stage:Begin()
	self:AddChild(self.stage)
	self:BeginStage(1)
end

function GameScreen:BeginStage(stageNum)
	self.stage:BeginStage(stageNum)
	self.z = -10
	self:GetSpr():SortZ()
end

function GameScreen:BeginFadeIn(cnt)
	self.fadeAct.enable = true

	self.fadeAct:ChangeFunc(function(rt)
		rt:GetSpr():Show()
		for i=0, cnt do
			rt:GetSpr().alpha = 1 - (i/cnt)
			rt:Wait()
		end
		rt:GetSpr().alpha = 0
		rt:GetSpr():Hide()
		rt.enable = false
		rt:Wait()
		
	end)
end

function GameScreen:BeginFadeOut(cnt)
	self.fadeAct.enable = true

	self.fadeAct:ChangeFunc(function(rt)
		rt:GetSpr():Show()
		for i=0, cnt do
			rt:GetSpr().alpha = (i/cnt)
			rt:Wait()
		end
		rt:GetSpr().alpha = 1
		rt.enable = false
		rt:Wait()
	end)
end



class 'Stage'(Actor)
function Stage:__init(game)
	Actor.__init(self)
	self.game = game
	self.allEnemies = {}
end

function Stage:Begin()
	Actor.Begin(self)
	
	self.player = Player(self)
	self.player:Begin()
	self.player.x = PLAYER_X
	self.player.y = PLAYER_Y
	self.player:GetSpr().z = Z_ORDER_PLAYER
	self:AddChild(self.player)
	
	self.back = GameBack()
	self.back:Begin()
	self.back.x = GetProperty("WindowWidth")
	self.back.y = 0
	self.back:GetSpr().z = Z_ORDER_BACK
	self:AddChild(self.back)
	
	self.stageNumAct = Actor()
	self.stageNumAct:SetText("")
	self.stageNumAct:Begin()
	self.stageNumAct.x = 10
	self.stageNumAct.y = 5
	self.stageNumAct:ApplyPosToSpr()
	self:AddChild(self.stageNumAct)

	self.pat = PatrolCar()
	self.pat:Begin()
	self.pat.x = PATCAR_X
	self.pat.y = PATCAR_Y
	self.pat:ApplyPosToSpr()
	self:AddChild(self.pat)
	
	local clearFunc = function()
		self:ChangeRoutine("StateClear")
	end
	self.marker = StageMarker()
	self.marker:Begin(clearFunc)
	self.marker.enable = false
	self:AddChild(self.marker)

	if DEBUG_MODE then
		local slash = Actor()
		slash:Begin()
		slash:SetText("|")
		slash.x = SLASHABEL_X_MAX
		slash.y = LINE_HEIGHTS[LINE_BOTTOM]
		slash:ApplyPosToSpr()
		self:AddChild(slash)
	end

	self:GetSpr():SortZ()
	
	if IS_PLAY_BGM then
		GS.SoundMgr:PlayBgm("gameBgm.ogg")
	end

end

function Stage:BeginStage(num)
	self.stageNum = num
	
	self.stageNumAct:SetText("STAGE"..self.stageNum)
	
	if num == 2 then
		self.pat.enable = true
		self.pat:Show()
	else
		self.pat.enable = false
		self.pat:Hide()
	end

	self.game:BeginFadeIn(STARTDEMO_FADEIN_FRAME)
	self:ChangeRoutine("StateStart")


function Stage:StateStart(rt)
	local spr = Sprite()
	spr:SetTextureMode(STAGE_START_DEMO_NAMES[self.stageNum])
	self:GetSpr():AddChild(spr)
	self:GetSpr():SortZ()
	
	self.marker.enable = false
	
	-- remove all enemy
	while table.getn(self.allEnemies) > 0 do
		self:RemoveEnemy(self.allEnemies[1])
	end
	
	-- fade in
	rt:Wait(STARTDEMO_FADEIN_FRAME)
	
	for i=1, 60 do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then break end
		rt:Wait()
	end
	-- fade out

	self.encountCnt = 0
	self.addTopEnemyDelay = 0
	self.enemyTopSpanCnt = 0
	self.addBottomEnemyDelay = 0
	self.enemyBottomSpanCnt = 0

	self.stageNumAct:SetText("STAGE"..self.stageNum)

	
	for idx, chr in ipairs(self:GetChild()) do
		if chr.BeginStage ~= nil then
			chr:BeginStage(self.stageNum)
		end
	end

	self:GetSpr():RemoveChild(spr)
	self:Goto("StateGame")
end

function Stage:StateGame(rt)
	while true do
		if DEBUG_MODE then
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_A) then
				self.player:OnAddItem()
			end
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_C) then
				self.marker:OnGoal()
			end
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_1) then
				self.game:BeginStage(1)
			end
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_2) then
				self.game:BeginStage(2)
			end
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_3) then
				self.game:BeginStage(3)
			end
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_4) then
				self:ChangeRoutine("StateEnding")
			end
		end
		
		self:CheckAddEnemy()
		
		rt:Wait()
	end
end

end

function Stage:GetEnemies()
	return self.allEnemies
end

function Stage:AddEnemy(enemy)
	self:AddChild(enemy)
	table.insert(self.allEnemies, enemy)
end
function Stage:RemoveEnemy(enemy)
	enemy:Dead()
	RemoveValue(self.allEnemies, enemy)
	self:RemoveChild(enemy)
end

function Stage:CheckAddEnemy()
	self.enemyTopSpanCnt = self.enemyTopSpanCnt + 1
	self.enemyBottomSpanCnt = self.enemyBottomSpanCnt + 1
	
	if self.enemyTopSpanCnt == TOP_ENEMY_SPAN_MIN then
		local span = TOP_ENEMY_SPAN_MAX - TOP_ENEMY_SPAN_MIN
		local chance = span / ENEMY_ENCOUNT_FRAME
		self.addTopEnemyDelay = math.random(1, chance)
	end
	
	if self.enemyBottomSpanCnt == BOTTOM_ENEMY_SPAN_MIN then
		local span = BOTTOM_ENEMY_SPAN_MAX - BOTTOM_ENEMY_SPAN_MIN
		local chance = span / ENEMY_ENCOUNT_FRAME
		self.addBottomEnemyDelay = math.random(1, chance)
	end

	if self.encountCnt >= ENEMY_ENCOUNT_FRAME then
		-- 上段追加判定
		local forceAddTopEnemy = false
		if self.addTopEnemyDelay > 0 then
			self.addTopEnemyDelay = self.addTopEnemyDelay - 1
			if self.addTopEnemyDelay == 0 then
				forceAddTopEnemy = true
			end
		end
	
		-- 下段追加判定
		local forceAddBottomEnemy = false
		if not forceAddTopEnemy then
			if self.addBottomEnemyDelay > 0 then
				self.addBottomEnemyDelay = self.addBottomEnemyDelay - 1
				if self.addBottomEnemyDelay == 0 then
					forceAddBottomEnemy = true
				end
			end
		end

		local back = self.back
		
		local line = nil
		local spd = nil
		if forceAddTopEnemy then
			line = LINE_TOP
			spd = (back.scrollSpd * TOP_ENEMY_SPD) / SCROLL_SPD
			self.enemyTopSpanCnt = 0
		elseif forceAddBottomEnemy then
			line = LINE_BOTTOM
			spd = (back.scrollSpd * BOTTOM_ENEMY_SPD) / SCROLL_SPD
			self.enemyBottomSpanCnt = 0
		else
			line = LINE_MIDDLE
			spd = (back.scrollSpd * MIDDLE_ENEMY_SPD) / SCROLL_SPD
		end
		
		local enemy = nil
		if line == LINE_BOTTOM then
			enemy = Rock()
		else
			-- zako or ceres
			if self.stageNum == 1 then
				enemy = Enemy(math.random(0, 5))
			elseif self.stageNum == 2 then
				if math.random(1, 100) <= PROB_CELES_STAGE2 then
					enemy = Celes()
				else
					enemy = Enemy(math.random(0, 5))
				end
			elseif self.stageNum == 3 then
				if math.random(1, 100) <= PROB_CELES_STAGE3 then
					enemy = Celes()
				else
					enemy = Enemy(math.random(0, 5))
				end
			end
		end
		enemy:Begin()
		
		enemy.line = line
		enemy.spd = spd
		enemy.x = GetProperty("WindowWidth") + 30
		enemy.y = LINE_HEIGHTS[enemy.line]
		enemy:ApplyPosToSpr()
		self:AddEnemy(enemy)
		self:GetSpr():SortZ()

		self.encountCnt = 0
	end
	self.encountCnt = self.encountCnt + 1
end


function Stage:StateClear(rt)
	-- すべての敵をbom
	local deadTargets = {}
	for idx, enemy in ipairs(self.allEnemies) do
		if enemy.attacker == nil then
			table.insert(deadTargets, enemy)
		end
	end
	while table.getn(deadTargets) > 0 do
		local enemy = deadTargets[1]
		enemy:DeadAction(DEAD_REASON_TIME_UP)
		self:RemoveEnemy(enemy)
		RemoveValue(deadTargets, enemy)
	end
	
	-- ウェイトかける
	for i=1, 40 do
		rt:Wait()
	end
	
	-- ハイク
	local haiku = Haiku()
	haiku:Begin(self.stageNum, self.score)
	haiku.x = 280
	haiku.y = 60
	haiku:ApplyPosToSpr()
	self:AddChild(haiku)

	for i=1, SHOW_HAIKU_FRAME do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then break end
		rt:Wait()
	end
	rt:Wait()

	-- 一枚絵どーん
	local stageClear = Actor()
	stageClear:SetTexture(STAGE_CLEAR_DEMO_NAMES[self.stageNum])
	stageClear.x = 0
	stageClear.y = 0
	stageClear:ApplyPosToSpr()
	self:AddChild(stageClear)
	self:GetSpr():SortZ()
	
	
	-- Z押すまで待機
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then
			break
		end
		
		rt:Wait()
	end
	
	-- フェードアウト
	self.game:BeginFadeOut(CLEARDEMO_FADEOUT_FRAME)
	rt:Wait(CLEARDEMO_FADEOUT_FRAME)


	-- 次の画面へ
	if self.stageNum == MAX_STAGE_NUM then
		self:ChangeRoutine("StateEnding")
	else
		self.game:BeginStage(self.stageNum + 1)
	end
	self:RemoveChild(stageClear)
	self:RemoveChild(haiku)
	rt:Wait()
end

function Stage:StateEnding(rt)
	-- remove all enemy
	while table.getn(self.allEnemies) > 0 do
		self:RemoveEnemy(self.allEnemies[1])
	end

	local spr = Sprite()
	spr.x = 30
	spr.y = 30
	spr:SetTextMode(
		"企画 　　　　スーパーウルトラサンボマンボマーシャルアーツ\n"..
		"グラフィック　ねちょ、ガンサー\n"..
		"プログラマ　　コケいろ")
	self:GetSpr():AddChild(spr)
	
	
	self.stageNumAct:Hide()
	self.marker.enable = false
	self.marker:Hide()
	
	local span = 20
	-- fade in
	self.game:BeginFadeIn(span)
	rt:Wait(span)
	
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then
			break
		end
		
		rt:Wait()
	end
	
	-- fade out
	self.game:BeginFadeOut(span)
	rt:Wait(span)
	
	self:GetSpr():RemoveChild(spr)
	ChangeScreen(TitleScreen())
	return "exit"
end


function Stage:ChangeScrollSpd(spd)
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
	
	local back = self.back
	back.scrollSpd = (SCROLL_SPD * spd) / SCROLL_SPD
end




--@Player
class 'Player'(Actor)
function Player:__init()
	Actor.__init(self)
	self.itemSprites = {}
end

function Player:Begin()
	Actor.Begin(self)
	
	self:SetDivTexture("yamabi", 6, 4, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "player spr"
	self:GetSpr().cx = 16
	self:GetSpr().cy = 16
	
	self.animCnt = 0

	local cursor = PlayerCursorCharge()
	cursor:Begin()
	GetStage():AddChild(cursor)
	GetStage().cursorId = cursor.id

end

function Player:BeginStage(num)
	while table.getn(self.itemSprites) > 0 do
		self:DecItem()
	end
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


function Player:AddItem(x, y)
	local item = Actor()
	item:Begin()
	item:SetDivTexture("suriken", 4, 1, 32, 32)
	item:GetSpr().x = x
	item:GetSpr().y = y
	item:GetSpr().cx = 16
	item:GetSpr().cy = 16
	
	item:ChangeFunc(function(act)
		for i=1, GET_ITEM_WAIT_FRAME do
			act.x = x + (self.x - x) * (i / GET_ITEM_WAIT_FRAME)
			act.y = self.y
			act:ApplyPosToSpr()
			act:Wait()
		end
		act:Dead()
		self:OnAddItem()
		act:Wait()
	end)
	
	GetStage():AddChild(item)
end

function Player:OnAddItem()
	GS.SoundMgr:PlaySe("bell")
	local cnt = table.getn(self.itemSprites)
	local spr = Sprite()
	spr.name = "item"
	spr:SetDivTextureMode("suriken", 4, 1, 32, 32)

	spr:SetDrawPosAbsolute()
	spr.x = 10 + cnt * 32
	spr.y = 40
	self:GetSpr():AddChild(spr)
	table.insert(self.itemSprites, spr)
end

function Player:DecItem()
	local cnt = self:GetItemCnt()
	local spr  = self.itemSprites[cnt]
	self:GetSpr():RemoveChild(spr)
	table.remove(self.itemSprites)
end

function Player:GetItemCnt()
	return table.getn(self.itemSprites)
end




--@PlayerCursor
class 'PlayerCursor'(Actor)
function PlayerCursor:__init()
	Actor.__init(self)
end

function PlayerCursor:ThrowSuriken(act, kind)
	local suriken = Suriken()
	suriken:Begin()
	suriken.kind = kind
	suriken.target = act
	suriken.x = GetPlayer().x + 30
	suriken.y = GetPlayer().y - 10
	suriken:ApplyPosToSpr()
	suriken:CalcMoveParam(act.x - act.spd * SURIKEN_HIT_FRAME, act.y)
	act.attacker = suriken
	GetStage():AddChild(suriken)
end

function PlayerCursor:Slash(act)
	local slash = Slash()
	slash:Begin()
	slash.target = act
	slash.x = act.x
	slash.y = act.y
	slash:ApplyPosToSpr()
	act.attacker = slash
	GetStage():AddChild(slash)
end

class 'PlayerCursorCharge'(PlayerCursor)
function PlayerCursorCharge:__init()
	PlayerCursor.__init(self)
	
	self.attackWaitCnt = 0
	self.itemCnt = 0
end

function PlayerCursorCharge:ThrowSuriken(act, kind)
	PlayerCursor.ThrowSuriken(self, act, kind)
	self.attackWaitCnt = SURIKEN_WAIT_FRAME
end

function PlayerCursorCharge:Begin()
	PlayerCursor.Begin(self)
	
	local gauge = Gauge()
	
	local releaseFunc = function()
		for idx, enemy in ipairs(GetStage():GetEnemies()) do
			if enemy.line == LINE_MIDDLE then
				self:ThrowSuriken(enemy, ATTACK_CHARGE1_SURIKEN)
			end
		end
	end
	local releaseFunc2 = function()
		for idx, enemy in ipairs(GetStage():GetEnemies()) do
			self:ThrowSuriken(enemy, ATTACK_CHARGE2_SURIKEN)
		end
		GetPlayer():DecItem()
	end
	
	gauge:Begin(releaseFunc, releaseFunc2)
	gauge.x = PLAYER_X - MAX_GAUGE_WIDTH / 2 + 15
	gauge.y = GAUGE_Y
	
	GetStage():AddChild(gauge)
	self.gaugeId = gauge.id
end

function PlayerCursorCharge:StateStart(rt)
	local inputStack = {}
	local useKeys = {
		KeyCode.KEY_UP,
		KeyCode.KEY_RIGHT,
		KeyCode.KEY_DOWN
	}

	while true do
		if self.attackWaitCnt > 0 then
			self.attackWaitCnt = self.attackWaitCnt - 1
		end
		
		-- キーが押されていなければスタックから削除
		local i = 1
		while i <= table.getn(inputStack) do
			if GS.InputMgr:IsKeyFree(inputStack[i]) then
				table.remove(inputStack, i)
			else
				i = i + 1
			end
		end
		
		-- キー押されてて、スタックに追加されてなければ追加
		for idx, code in ipairs(useKeys) do
			if GS.InputMgr:IsKeyHold(code) and
				FindValue(inputStack, code) == nil then
				table.insert(inputStack, 1, code)
			end
		end
		
		if self.attackWaitCnt == 0 and
			 not GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) 
			 and table.getn(inputStack) > 0 then
			 
			local keyCode = inputStack[1]
			if keyCode == KeyCode.KEY_UP then
				local enemies = GetStage():GetEnemies()
				for idx, enemy in ipairs(enemies) do
					if enemy.line == LINE_TOP and
						 enemy.attacker == nil then
						self:ThrowSuriken(enemy, ATTACK_NORMAL_SURIKEN)
						break
					end
				end
			end
			
			if keyCode == KeyCode.KEY_RIGHT then
				local enemies = GetStage():GetEnemies()
				for idx, enemy in ipairs(enemies) do
					if enemy.line == LINE_MIDDLE and 
						 enemy.attacker == nil then
						self:ThrowSuriken(enemy, ATTACK_NORMAL_SURIKEN)
						break
					end
				end
			end

			-- slash
			if keyCode == KeyCode.KEY_DOWN then
				local enemies = GetStage():GetEnemies()
				for idx, enemy in ipairs(enemies) do
					if enemy.line == LINE_BOTTOM and 
						 enemy.attacker == nil and
						 (SLASHABEL_X_MIN <= enemy.x and enemy.x <= SLASHABEL_X_MAX) then
						self:Slash(enemy)
						break
					end
				end
			end

		end
		rt:Wait()
	end
end

class 'Attacker'(Actor)
function Attacker:__init()
	Actor.__init(self)
	self.target = nil
end

function Attacker:Attack()
	if self.target:Damage(ATTACK_DAMAGE[self.kind]) then
		self.target:DeadAction(self.kind)
		GetStage():RemoveEnemy(self.target)
	end
	self.target.attacker = nil
end

-- @Suriken
class 'Suriken'(Attacker)
function Suriken:__init()
	Attacker.__init(self)
	
	self.srcX = 0
	self.srcY = 0
	self.destX = 0
	self.destY = 0
end

function Suriken:Begin()
	Attacker.Begin(self)
	
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
	
	self:Attack()
	
	GetStage():RemoveChild(self)
	self:Dead()
	rt:Wait()
end

function Suriken:CalcMoveParam(x, y)
	self.srcX = self.x
	self.srcY = self.y
	
	self.destX = x
	self.destY = y
end

--@Slash
class 'Slash'(Attacker)
function Slash:__init()
	Attacker.__init(self)
	self.kind = ATTACK_SLASH
end

function Slash:Begin()
	Attacker.Begin(self)
	
	self:SetDivTexture("slash", 5, 1, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "slash spr"
	self:GetSpr().cx = 25
	self:GetSpr().cy = 25
	self:GetSpr().drawWidth = -50
	
	GS.SoundMgr:PlaySe("slash")
end

function Slash:StateStart(rt)
	self:Attack()
	self:GetSpr().x = self:GetSpr().x  + 50
	for idx = 0, 4 do
		rt:Wait(SLASH_ANIM_SPD)
		self:GetSpr().divTexIdx = idx
	end
	
	GetStage():RemoveChild(self)
	self:Dead()
	rt:Wait()
end







--@Enemy
class 'Enemy'(Actor)
function Enemy:__init(kind)
	Actor.__init(self)
	
	self.spd = 0
	self.kind = kind
	self.attacker = nil
	self.hp = HP_ZAKO
end

function Enemy:Damage(dmg)
	self.hp = self.hp - dmg
	if self.hp <= 0 then
		return true
	end
	return false
end

function Enemy:DeadAction(kind)
	local pcl = BurstParticle()
	pcl:Begin()
	pcl.x = self.x
	pcl.y = self.y
	pcl:ApplyPosToSpr()
	GetStage():AddChild(pcl)
end

function Enemy:Dead()
	Actor.Dead(self)
	self.attacker = nil
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
			GetStage():RemoveEnemy(self)
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
	self.hp = HP_ROCK
end

function Rock:SetActTexture()
	self:SetDivTexture("rock", 4, 1, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "rock spr"
	self:GetSpr().cx = 25
	self:GetSpr().cy = 25
	self:GetSpr().z = Z_ORDER_ROCK
end

function Rock:DeadAction(attackKind)
	if attackKind == ATTACK_SLASH then 
		GetStage().player:AddItem(self.x, self.y)
		-- add particle
		local pcl = SlashedRock()
		pcl:Begin()
		pcl.x = self.x
		pcl.y = self.y
		GetStage():AddChild(pcl)
		GetStage():GetSpr():SortZ()
	end
	if attackKind == ATTACK_CHARGE2_SURIKEN or 
		 attackKind == DEAD_REASON_TIME_UP then 
		local pcl = BurstParticle()
		pcl:Begin()
		pcl.x = self.x
		pcl.y = self.y
		GetStage():AddChild(pcl)
	end
end

function Rock:StateStart(rt)
	while true do
		self.x = self.x - self.spd
		if self.x < -30 then
			GetStage():RemoveEnemy(self)
			rt:Wait()
		end
		
		self:GetSpr().rot = self:GetSpr().rot + math.rad(ROCK_ROT_SPD)
		
		self:ApplyPosToSpr()
		rt:Wait()
	end
end



--@Celes
class 'Celes'(Enemy)
function Celes:__init()
	Enemy.__init(self)
	self.hp = HP_CELES
end

function Celes:Damage(dmg)
	local res = Enemy.Damage(self, dmg)
	if res then	-- 死ななかった
		GS.SoundMgr:PlaySe("selesDead")
	else
		GS.SoundMgr:PlaySe("selesDamage")
	end
	
	return res
end

function Celes:SetActTexture()
	self:SetDivTexture("celes", 3, 2, 50, 50)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "ceres spr"
	self:GetSpr().cx = 25
	self:GetSpr().cy = 25
	
	self.animAct = Actor()
	self.animAct:Begin()
	self.animAct:ChangeFunc(function(act)
		local cnt = 0
		while true do
			self:GetSpr().divTexIdx = 0
			act:Wait(CELES_ANIM_SPD)
			self:GetSpr().divTexIdx = 1
			act:Wait(CELES_ANIM_SPD)
			self:GetSpr().divTexIdx = 2
			act:Wait(CELES_ANIM_SPD)
			self:GetSpr().divTexIdx = 1
			act:Wait(CELES_ANIM_SPD)
		end
	end)
	self:AddChild(self.animAct)
end


function Celes:StateStart(rt)
	while true do
		self.x = self.x - self.spd
		if self.x < -30 then
			GetStage():RemoveEnemy(self)
			rt:Wait()
		end
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



class 'Particle'(Actor)
function Particle:__init()
	Actor.__init(self)
end


--@BurstParticle
class 'BurstParticle'(Particle)
function BurstParticle:__init()
	Particle.__init(self)
end


function BurstParticle:Begin()
	Particle.Begin(self)
	
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

--@SlashedRock
class 'SlashedRock'(Particle)
function SlashedRock:__init()
	Particle.__init(self)
end

function SlashedRock:Begin()
	Particle.Begin(self)
	self:CreateSpr()
	self:GetSpr().z = Z_ORDER_SLASH
	
	self.upSpr = Sprite()
	self.upSpr.name = "slashedRock upSpr"
	self.upSpr:SetTextureMode("rock")
	self.upSpr:SetTextureSrc(0, 0, 50, 25)
	self.upSpr.cx = 25
	self.upSpr.cy = 12
	self:GetSpr():AddChild(self.upSpr)

	self.downSpr = Sprite()
	self.downSpr.name = "slashedRock downSpr"
	self.downSpr:SetTextureMode("rock")
	self.downSpr:SetTextureSrc(0, 25, 50, 25)
	self.downSpr.cx = 25
	self.downSpr.cy = 12
	self:GetSpr():AddChild(self.downSpr)
	
	self.upY				= -13
	self.upMaxY			= -50
	self.upMaxTime	= 20
	
	self.downY				= 13
	self.downMaxY			= -5
	self.downMaxTime	= 10
end


function SlashedRock:StateStart(rt)
	self:ApplyPosToSpr()
	for i=1, SLASHED_ROCK_PCL_SPAN do
		self.upSpr.y = self.upY + 
								(2*self.upMaxY*i)/self.upMaxTime - 
								0.5*(2*self.upMaxY*(i*i)) / (self.upMaxTime * self.upMaxTime)
		self.downSpr.y = self.downY + 
										(2*self.downMaxY*i)/self.downMaxTime -
										0.5*(2*self.downMaxY*(i*i)) / (self.downMaxTime * self.downMaxTime)

		self.upSpr.rot = self.upSpr.rot + math.rad(1)
		self.downSpr.rot = self.downSpr.rot - math.rad(1)
		
		self.upSpr.alpha		= 1 - (i / SLASHED_ROCK_PCL_SPAN)
		self.downSpr.alpha	= 1 - (i / SLASHED_ROCK_PCL_SPAN)
		
		rt:Wait()
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


function Gauge:Begin(func, func2)
	Actor.Begin(self)
	self.releaseGaugeFunc = func
	self.releaseGaugeFunc2 = func2

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
			if GetPlayer():GetItemCnt() == 0 then
				self:Goto("StateCharge")
			else
				self:Goto("StateCharge2")
			end
		end
		rt:Wait()
	end
end


function Gauge:StateCharge(rt)
	self.chargeCnt = 0
	while GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) do
		self.chargeCnt = self.chargeCnt + 1
		self:GetSpr().drawWidth  = 1 + (MAX_GAUGE_WIDTH * self.chargeCnt) / LEFT_CHARGE_FRAME
			
		if GetPlayer():GetItemCnt() > 0 then
			self:Goto("StateCharge2")
		end

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
		self.releaseGaugeFunc()
	end
	
	self:Goto("StateStart")
end


function Gauge:StateCharge2(rt)
	while GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) do
		self.chargeCnt = self.chargeCnt + 1
		self:GetSpr().drawWidth  = 1 + (MAX_GAUGE_WIDTH * self.chargeCnt) / LEFT_CHARGE_FRAME
		
		if self.chargeCnt == LEFT_CHARGE2_FRAME then
			self:Goto("StateCharge2_2")
		end
		
		rt:Wait()
	end
	self:Goto("StateStart")
end

function Gauge:StateCharge2_2(rt)
	GS.SoundMgr:PlaySe("bosu")
	self.chargeCnt = LEFT_CHARGE2_FRAME
	self:GetSpr():SetTextureColorF(Color.Black)
	while GS.InputMgr:IsKeyHold(KeyCode.KEY_LEFT) do
		self.chargeCnt = self.chargeCnt + 1
		self:GetSpr().drawWidth  = 1 + (MAX_GAUGE_WIDTH * self.chargeCnt) / LEFT_CHARGE_FRAME
		
		if self.chargeCnt == LEFT_CHARGE_FRAME then
			self:Goto("StateMaxHold")
		end
		rt:Wait()
	end
	self.releaseGaugeFunc2()
	self:Goto("StateStart")
end


--@StageMarker
class 'StageMarker'(Actor)
function StageMarker:__init()
	Actor.__init(self)
	self.nowFrame = 0
	self.stageFrame = 0
end

function StageMarker:Begin(func)
	Actor.Begin(self)
	self.goalFunc = func
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
	self.enable = true
	self.isGoaled = false
	self.nowFrame = 0
	self.maker.x = MARKER_LEFT_X
	self.stageFrame = STAGE_FRAME[stageNum]
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
				self:OnGoal()
			end
		end
		
		rt:Wait()
	end
end

function StageMarker:OnGoal()
	self:goalFunc()
	self.isGoaled = true

	self.nowFrame = self.stageFrame
	local width = MARKER_RIGHT_X - MARKER_LEFT_X
	self.maker.x = MARKER_LEFT_X + width
end





--@Haiku
class 'Haiku'(Actor)
function Haiku:__init()
	Actor.__init(self)
end

function Haiku:Begin(stageNum, score)
	Actor.Begin(self)
	
	local rank = 3
	local text = HAIKU_TEXT[stageNum][rank]
	local tmp = {}
	text = string.gsub(text, " ", "\n")
	self:SetText(text)
end

function Haiku:StateStart(rt)
	while true do
		rt:Wait()
	end
end




