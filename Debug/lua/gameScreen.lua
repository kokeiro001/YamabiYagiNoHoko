local STAGE_BGM_NAME	= "karyuu_kyouen.ogg"
local ENDING_BGM_NAME	= "yukinagori.ogg"

local STAGE_FRAME = {	3000, 3000, 3000	}	-- ステージのクリアまでの時間
local STAGE_BACK_ALPHA = {	0.8, 0.8, 0.8	}	-- ステージの背景透明度

local MAX_STAGE_NUM = table.getn(STAGE_FRAME)

local UI_FADE_FRAME = 30

local HANT_ID = {
	ZAKO = 1, 
	ROCK = 2, 
	CELES =3 , 
	CLASH_ROCK = 4
}

-- scoore
local SCORE_X = 500
local SCORE_Y = 5

local POINT_PERFECT_BOUNUS = 5000
local POINT_ZAKO 				= 100
local POINT_CELES 			= 300
local POINT_ROCK 				= 50
local POINT_USE_CHARGE2	= 200
local POINT_PLAYER_ROCK_HIT	= -50
local POINT_ITEM 				= 1000

local FLOAT_POINT_Y_ZAKO		= 0
local FLOAT_POINT_Y_CELES		= 0
local FLOAT_POINT_Y_ROCK		= -20



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
local STAGE_DATA = {
	{	-- stage1
		ENEMY_SPAN = {
			{min=60, max=240}, 
			{min=20, max= 60},
			{min=60, max=120}
		},
	},
	{	-- stage2
		ENEMY_SPAN = {
			{min=60, max=240}, 
			{min=20, max= 60},
			{min=60, max=120}
		},
	},
	{	-- stage3
		ENEMY_SPAN = {
			{min=80, max=260},	-- min max
			{min=40, max=100},
			{min=60, max=120}
		},
	}
}

local ENEMY_ENCOUNT_FRAME 	= 20

local ENEMY_ANIM_SPD 	= 4
local CELES_ANIM_SPD	= 10
local ROCK_ROT_SPD 		= 0

local ENEMY_SPD = {
	10,					-- LINE_TOP
	SCROLL_SPD,	-- LINE_MIDDLE
	SCROLL_SPD	-- LINE_BOTTOM
}

local HIT_PLAYER_ROCK_X = PLAYER_X + 10


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


-- patca
local PATCAR_X 			= -50
local PATCAR_Y 			= PLAYER_Y - 10

-- marker
local MARKER_LEFT_X			= 100
local MARKER_RIGHT_X		= GetProperty("WindowWidth") - 150
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

function GetZOrder(name)
	if name == "slash" then return Z_ORDER_SLASH 
	else error("not def")
	end
end

function GetStage()
	if GS.CurrentScreen.name == "GameScreen" then
		return GS.CurrentScreen.stage
	end
	return nil
end
function GetPlayer()
	return GetStage().player
end
function GetCamera()
	return GetStage().camera
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

function GameScreen:StateStart(rt)
	while true do
		rt:Wait()
	end
end

function GameScreen:StateWatchDemo(rt)
	while true do
		if GS.InputMgr:IsKeyPush(KeyCode.KEY_Z) then
			self.stage:SkipDemo()
			self:Goto("StateStart")
		end
		rt:Wait()
	end
end

function GameScreen:BeginStage(stageNum)
	self.stage:BeginStage(stageNum)
	self.z = -10
	self:GetSpr():SortZ()
	GS.Scheduler:SortActor()
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

	self.demoAct = {}
	self.demoSpr = {}
	self.demoSkipable = true
	
end

function Stage:Begin()
	Actor.Begin(self)
	
	self.camera = Camera()
	self.camera:Begin()
	self:AddChild(self.camera)
	
	self.player = Player(self)
	self.player:Begin()
	self.player.x = PLAYER_X
	self.player.y = PLAYER_Y
	self.player:GetSpr().z = Z_ORDER_PLAYER
	self:AddChild(self.player)
	GetCamera():AddAutoApplyPosItem(self.player)
	
	self.back = GameBack()
	self.back:Begin()
	self.back.x = GetProperty("WindowWidth")
	self.back.y = 0
	self.back:GetSpr().z = Z_ORDER_BACK
	self:AddChild(self.back)
	
	self.scoreMgr = StageScore()
	self.scoreMgr:Begin()
	self.scoreMgr.x = SCORE_X
	self.scoreMgr.y = SCORE_Y
	self.scoreMgr:ApplyPosToSpr()
	self:AddChild(self.scoreMgr)
	
	self.stageNumAct = StageNumber()
	self.stageNumAct:Begin()
	self.stageNumAct.x = 10
	self.stageNumAct.y = 5
	self.stageNumAct:ApplyPosToSpr()
	self:AddChild(self.stageNumAct)

	self.pat = PatrolCar()
	self.pat:Begin()
	self.pat.x = PATCAR_X
	self.pat.y = PATCAR_Y
	self:AddChild(self.pat)
	
	self.enemyMgr = EnemyManager()
	self.enemyMgr:Begin()
	self:AddChild(self.enemyMgr)
	
	local clearFunc = function()
		self:ChangeRoutine("StateClear")
	end
	self.marker = StageMarker()
	self.marker:Begin(clearFunc)
	self:AddChild(self.marker)

	if GS.IsDebug then
		local window = Actor()
		window:Begin()
		window.x = -1
		window.y = -1
		window:SetTexture("debugWindow")
		GetCamera():AddAutoApplyPosItem(window)
		self:AddChild(window)
	end

	if GS.IsPlayBgm then
		GS.SoundMgr:PlayBgm(STAGE_BGM_NAME)
		GS.SoundMgr:SetBgmVol(50)
	end

end

function Stage:BeginStage(num)
	self.stageNum = num
	
	self.game:BeginFadeIn(STARTDEMO_FADEIN_FRAME)
	
	for idx, chr in ipairs(self:GetChild()) do
		if chr.BeginStartDemo ~= nil then
			chr:BeginStartDemo(num)
		end
	end
	
	self:ChangeRoutine("StateStartDemo"..num)
end

function Stage:SkipDemo()
	if self.demoType == "Start" then
		if self.demoSkipable then
			self:FinalizeStartDemo()
		end
	elseif self.demoType == "Clear" then
		if self.demoSkipable then
			self:FinalizeClearDemo()
		end
	else
		error("not def")
	end
end

function Stage:InitStartDemoWait(cnt)
	self.demoType = "Start"
	self.demoSkipable = true
	
	-- remove all enemy
	self.enemyMgr:ClearEnemy()

	self.marker.enable = false
	self.encountCnt = 0
	
	self.game:ChangeRoutine("StateWatchDemo")
end

function Stage:FinalizeStartDemo()
	self.demoType = nil
	self.demoSkipable = false

	for idx, spr in ipairs(self.demoSpr) do
		self:GetSpr():RemoveChild(spr)
	end
	for idx, act in ipairs(self.demoAct) do
		act:Dead()
		self:RemoveChild(act)
	end

	if self.demoEndFunc ~= nil then
		self:demoEndFunc()
		self.demoEndFunc = nil
	end
	self:ChangeRoutine("StateGame")
	self.game:ChangeRoutine("StateStart")
	self:Wait()
end


function Stage:StateStartDemo1(rt)
	self:InitStartDemoWait()
	
	self.demoEndFunc = function()
		self.player.x = PLAYER_X
	end
	
	-- 一枚絵
	local topSpr = Sprite()
	topSpr.z = -100
	topSpr:SetTextureMode(STAGE_START_DEMO_NAMES[self.stageNum])
	self:GetSpr():AddChild(topSpr)
	self:GetSpr():SortZ()
	table.insert(self.demoSpr , topSpr)
	
	self:Wait(STARTDEMO_FADEIN_FRAME)
	
	-- 一枚絵表示時間
	rt:Wait(120)
	
	local height = 10
	local top, bottom = self:AddObi(height)
	table.insert(self.demoSpr , top)
	table.insert(self.demoSpr , bottom)
	self.player.x = -30
	
	-- 一枚絵をフェードアウト
	self:FadeSprWait(topSpr, 30, 1, 0)
	rt:Wait(30)
	
	-- プレイヤーを定位置へ
	self:MoveActWait(self.player, 60, PLAYER_X, PLAYER_Y)
	rt:Wait(60)
	
	-- 帯削除、開始
	self.demoSkipable = false
	self:RemoveObiWait(top, bottom, 30, height)
	self:FinalizeStartDemo()
end

function Stage:StateStartDemo2(rt)
	self:InitStartDemoWait()
	
	self.demoEndFunc = function()
		self.player:ChangeRoutine("StateStart")
		self.player:Show()
		self.player.x = PLAYER_X

		self.pat.enable = true
		self.pat:ChangeRoutine("StateStart")
		self.pat:Show()
		self.pat.spr.divTexIdx = 12
		self.pat.x = PATCAR_X
		self.pat.y = PATCAR_Y
		self:ChangeScrollSpd(SCROLL_SPD)
	end
	
	-- 一枚絵
	local topSpr = Sprite()
	topSpr.z = -100
	topSpr:SetTextureMode(STAGE_START_DEMO_NAMES[self.stageNum])
	self:GetSpr():AddChild(topSpr)
	self:GetSpr():SortZ()
	table.insert(self.demoSpr , topSpr)
	
	self:Wait(STARTDEMO_FADEIN_FRAME)

	-- 一枚絵表示時間
	rt:Wait(120)
	
	-- 帯表示
	local height = 10
	local top, bottom = self:AddObi(height)
	table.insert(self.demoSpr , top)
	table.insert(self.demoSpr , bottom)

	self:ChangeScrollSpd(0)
	-- アクターの位置設定
	local tmp = 100
	self.pat:Show()
	self.pat.x = tmp - (PLAYER_X - PATCAR_X)
	self.pat:MoveSpd(100, 3, 0)
	
	self.player:Show()
	self.player.x = tmp
	self.player:MoveSpd(100, 3, 0)

	-- 一枚絵をフェードアウト
	self:FadeSprWait(topSpr, 30, 1, 0)
	rt:Wait(30)

	for i=1, SCROLL_SPD + 2 do
		self.pat:MoveSpd(100, 3 - i, 0)
		self.player:MoveSpd(100, 3 - i, 0)
		self:ChangeScrollSpd(i)
		rt:Wait(3)
	end
	
	rt:Wait(80)
	self:ChangeScrollSpd(SCROLL_SPD)
	self.pat:Move(30, PATCAR_X, PATCAR_Y)
	self.player:Move(30, PLAYER_X, PLAYER_Y)
	rt:Wait(30)
	
	-- 帯削除、開始
	self.demoSkipable = false
	self:RemoveObiWait(top, bottom, 30, height)
	self:FinalizeStartDemo()
end

function Stage:StateStartDemo3(rt)
	self:InitStartDemoWait()
	
	self.demoEndFunc = function()
		self.player.x = PLAYER_X
	end
	
	local topSpr = Sprite()
	topSpr.z = -100
	topSpr:SetTextureMode(STAGE_START_DEMO_NAMES[self.stageNum])
	self:GetSpr():AddChild(topSpr)
	self:GetSpr():SortZ()
	table.insert(self.demoSpr , topSpr)
	
	self:Wait(STARTDEMO_FADEIN_FRAME)
	
	rt:Wait(60)
	
	local height = 10
	local top, bottom = self:AddObi(height)
	table.insert(self.demoSpr , top)
	table.insert(self.demoSpr , bottom)
	self.player.x = -30
	
	-- 一枚絵をフェードアウト
	self:FadeSprWait(topSpr, 30, 1, 0)

	-- 一枚絵表示時間
	rt:Wait(120)
	
	-- プレイヤーを定位置へ
	self:MoveActWait(self.player, 60, PLAYER_X, PLAYER_Y)
	rt:Wait(60)
	
	-- 帯削除、開始
	self.demoSkipable = false
	self:RemoveObiWait(top, bottom, 30, height)
	self:FinalizeStartDemo()
end




function Stage:StateClear(rt)
	self:ChangeRoutine("StateClearDemo"..self.stageNum)
	rt:Wait()
end

function Stage:InitClearDemo()
	self.demoType = "Clear"
	self.demoSkipable = true

	self.enemyMgr:BurstAllEnemy()
	
	for idx, chr in ipairs(self:GetChild()) do
		if chr.BeginClearDemo ~= nil then
			chr:BeginClearDemo(self.stageNum)
		end
	end

	self.game:ChangeRoutine("StateWatchDemo")
end

function Stage:FinalizeClearDemo()
	-- スキップ情報を初期化
	self.demoType = nil
	self.demoSkipable = false
	self:ChangeRoutine("StateGame")
	self.game:ChangeRoutine("StateStart")

	-- 終了関数が用意されてるなら実行
	if self.demoEndFunc ~= nil then
		self:demoEndFunc()
		self.demoEndFunc = nil
	end

	-- デモで使用したオブジェクトを削除
	for idx, spr in ipairs(self.demoSpr) do
		self:GetSpr():RemoveChild(spr)
	end
	for idx, act in ipairs(self.demoAct) do
		act:Dead()
		self:RemoveChild(act)
	end

	-- 次の画面へ
	if self.stageNum == MAX_STAGE_NUM then
		self:ChangeRoutine("StateEnding")
	else
		self.game:BeginStage(self.stageNum + 1)
	end
	self:Wait()
end


function Stage:StateClearDemo1(rt)
	self:InitClearDemo()
	
	rt:Wait(60)
	self:MoveActWait(self.player, 120, GetProperty("WindowWidth") / 2, PLAYER_Y)
	
	self:AddShowResult()
	while true do
		rt:Wait()
	end
end

function Stage:StateShownResult1(rt)
	self:ShowHaiku()
	rt:Wait(SHOW_HAIKU_FRAME)
	
	self.game:BeginFadeOut(60)
	self:MoveActWait(self.player, 60, GetProperty("WindowWidth") , PLAYER_Y)
	
	-- 一枚絵
	
	local stageClear = self:MakeDemoActor()
	stageClear:SetTexture(STAGE_CLEAR_DEMO_NAMES[self.stageNum])
	stageClear:ApplyPosToSpr()
	self:GetSpr():SortZ()

	-- フェードイン
	self.game:BeginFadeIn(20)
	rt:Wait(30)
	
	-- フェードアウト
	self.game:BeginFadeOut(CLEARDEMO_FADEOUT_FRAME)
	rt:Wait(CLEARDEMO_FADEOUT_FRAME)

	-- 終了
	self:FinalizeClearDemo()
end

function Stage:StateClearDemo2(rt)
	self:InitClearDemo()
	rt:Wait(60)
	
	-- プレイヤー、パトカーを前に進める
	self:ChangeScrollSpd(SCROLL_SPD + 1)
	self.player:Move(60, GetProperty("WindowWidth") / 2, PLAYER_Y)
	self.pat:Move(60, 100, PATCAR_Y)
	rt:Wait(90)
	
	-- パトカー下がる
	self.pat:Move(120, -100, PATCAR_Y)
	rt:Wait(120)
	
	-- パトカー突っ込む
	self.pat:Move(100, GetProperty("WindowWidth") + 100, PATCAR_Y)
	rt:Wait(25)
	
	-- 必殺・山火ジャンプ
	self.player:MoveJump(30, -100, 60)	-- 200Fで頂点到達。-100のとこ。
	self.player.anim:BeginAnim("jump")
	rt:Wait(60)
	self.player:ChangeRoutine("StateStart")
	self.player.anim:BeginAnim("run")
	
	rt:Wait(10)
	GS.SoundMgr:PlaySe("bosu")
	GetCamera():Shake(10, 10, 10)
	rt:Wait(60)
	
	self:AddShowResult()
	while true do
		rt:Wait()
	end
end

function Stage:StateShownResult2(rt)
	-- ハイク表示
	self:ShowHaiku()
	rt:Wait(SHOW_HAIKU_FRAME)
	
	self.game:BeginFadeOut(60)
	self:MoveActWait(self.player, 60, GetProperty("WindowWidth") , PLAYER_Y)
	
	-- 一枚絵どーん
	local stageClear = self:MakeDemoActor()
	stageClear:SetTexture(STAGE_CLEAR_DEMO_NAMES[self.stageNum])
	stageClear:ApplyPosToSpr()
	self:GetSpr():SortZ()

	-- フェードイン
	self.game:BeginFadeIn(20)
	rt:Wait(30)
	
	-- フェードアウト
	self.game:BeginFadeOut(CLEARDEMO_FADEOUT_FRAME)
	rt:Wait(CLEARDEMO_FADEOUT_FRAME)

	-- 終了
	self:FinalizeClearDemo()
end

function Stage:StateClearDemo3(rt)
	self:InitClearDemo()
	rt:Wait(60)
	
	self:MoveActWait(self.player, 120, GetProperty("WindowWidth") / 2, PLAYER_Y)
	rt:Wait(20)
	
	self:AddShowResult()
	while true do
		rt:Wait()
	end
end

function Stage:StateShownResult3(rt)
	self:ShowHaiku()
	rt:Wait(SHOW_HAIKU_FRAME)
	
	self.game:BeginFadeOut(60)
	self:MoveActWait(self.player, 60, GetProperty("WindowWidth") , PLAYER_Y)
	
	-- 一枚絵どーん
	local stageClear = self:MakeDemoActor()
	stageClear:SetTexture(STAGE_CLEAR_DEMO_NAMES[self.stageNum])
	stageClear:ApplyPosToSpr()
	self:GetSpr():SortZ()

	-- フェードイン
	self.game:BeginFadeIn(20)
	rt:Wait(30)
	
	-- フェードアウト
	self.game:BeginFadeOut(CLEARDEMO_FADEOUT_FRAME)
	rt:Wait(CLEARDEMO_FADEOUT_FRAME)

	-- 終了
	self:FinalizeClearDemo()
end





function Stage:StateGame(rt)
	for idx, chr in ipairs(self:GetChild()) do
		if chr.BeginStage ~= nil then
			chr:BeginStage(self.stageNum)
		end
	end

	while true do
		if GS.IsDebug then
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_A) then
				self.player:OnAddItem()
			end
			if GS.InputMgr:IsKeyPush(KeyCode.KEY_S) then
				GetCamera():Shake(5, 20, 20)
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
		rt:Wait()
	end
end





function Stage:StateEnding(rt)
	-- remove all enemy
	self.enemyMgr:ClearEnemy()
	if GS.IsPlayBgm then
		GS.SoundMgr:PlayBgm(ENDING_BGM_NAME)
		GS.SoundMgr:SetBgmVol(50)
	end
	
	for idx, chr in ipairs(self:GetChild()) do
		if chr.BeginEnding ~= nil then
			chr:BeginEnding()
		end
	end
	
	self.player:SetPos(PLAYER_X, PLAYER_Y)
	self.player:ClearItem()
	self.marker.enable = false
	self.marker:Hide()
	self.stageNumAct:Hide()
	self.scoreMgr:Hide()
	
	local span = 20
	self.game:BeginFadeIn(span)
	rt:Wait(span)
	
	while true do
		rt:Wait()
	end
	
end
function Stage:StateEnding2(rt)
	-- fade out
	local span = 60
	self.game:BeginFadeOut(span)
	rt:Wait(span)
	
	rt:Wait(60)
	
	ChangeScreen(TitleScreen())
	return "exit"
end

function Stage:ChangeScrollSpd(spd)
	for idx, enemy in ipairs(self.enemyMgr:GetEnemies()) do
		enemy.spd = (ENEMY_SPD[enemy.line] * spd) / SCROLL_SPD
	end
	
	self.back.scrollSpd = (SCROLL_SPD * spd) / SCROLL_SPD
end

function Stage:GetEnemies()
	return self.enemyMgr:GetEnemies()
end



function Stage:MakeDemoActor()
	local act = Actor()
	self:AddChild(act)
	table.insert(self.demoAct, act)
	return act
end

function Stage:ShowHaiku()
	local haiku = Haiku()
	haiku:Begin(self.stageNum, self.score)
	haiku.x = 140
	haiku.y = 120
	haiku:ApplyPosToSpr()
	self:AddChild(haiku)
	table.insert(self.demoAct, haiku)
	return haiku
end

function Stage:AddShowResult()
	local shownFunc = function()
		GS.SoundMgr:PlaySe("bell")
		self:ChangeRoutine("StateShownResult"..self.stageNum)
	end
	
	local result = StageResult(self.scoreMgr.idCnt, 
														 self.scoreMgr.isPerfect, 
														 shownFunc)
	result:Begin()
	result:SetPos(170, 20)
	result:ApplyPosToSpr()
	self:AddChild(result)
	table.insert(self.demoAct, result)
end

function Stage:FadeSprWait(spr, cnt, from, to)
	local sa = from - to
	for i=1, cnt do
		spr.alpha = to + sa * (1 - (i / cnt))
		self:Wait()
	end
end

function Stage:ToCameraWait(cnt, x, y)
	local cam = GetCamera()
	local fromX, fromY = cam:GetPos()
	local saX, saY = fromX - x, fromY - y
	for i=1, cnt do
		cam.x = x + saX * (1 - (i / cnt))
		cam.y = y + saY * (1 - (i / cnt))
		self:Wait()
	end
end

function Stage:MoveActWait(act, cnt, x, y)
	local fromX, fromY = act:GetPos()
	local saX, saY = fromX - x, fromY - y
	
	for i=1, cnt do
		act.x = x + saX * (1 - (i / cnt))
		act.y = y + saY * (1 - (i / cnt))
		self:Wait()
	end
end

function Stage:AddObi(height)
	local top = Sprite()
	top:SetTextureMode("whitePix")
	top:SetTextureColorF(Color.Black)
	top.drawWidth  = GetProperty("WindowWidth")
	top.drawHeight = height
	top.z = -50
	self:GetSpr():AddChild(top)

	local bottom = Sprite()
	bottom:SetTextureMode("whitePix")
	bottom:SetTextureColorF(Color.Black)
	bottom.drawWidth  = GetProperty("WindowWidth")
	bottom.y = GetProperty("WindowHeight") - height
	bottom.z = -50
	bottom.drawHeight = height
	self:GetSpr():AddChild(bottom)

	self:GetSpr():SortZ()
	return top, bottom
end

function Stage:RemoveObiWait(top, bottom, span, height)
	for i=1, span do
		top.y			= -height + height * (1 - (i/span))
		bottom.y	= GetProperty("WindowHeight") - height + height * (i/span)
		top.alpha = (1 - (i/span))
		bottom.alpha = (1 - (i/span))
		self:Wait()
	end
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
	self:SetAnimation(PlayerAnim())
	self.anim:BeginAnim("run")
	
	local cursor = PlayerCursorCharge()
	cursor:Begin()
	GetStage():AddChild(cursor)
	GetStage().cursorId = cursor.id
end

function Player:BeginStartDemo(num)
	self:ClearItem()
	self.anim:BeginAnim("run")
end

function Player:AddItem(x, y)
	local item = Actor()
	item:Begin()
	item:SetDivTexture("suriken", 4, 1, 32, 32)
	item.x = x
	item.y = y
	item:GetSpr().cx = 16
	item:GetSpr().cy = 16
	item:ApplyPosToSprUseCamera(GetCamera())
	
	GetCamera():AddAutoApplyPosItem(item)
	item:ChangeFunc(function(act)
		for i=1, GET_ITEM_WAIT_FRAME do
			act.x = x + (self.x - x) * (i / GET_ITEM_WAIT_FRAME)
			act.y = self.y
			
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

function Player:ClearItem()
	while table.getn(self.itemSprites) > 0 do
		self:DecItem()
	end
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
	suriken:ApplyPosToSprUseCamera(GetCamera())
	GetCamera():AddAutoApplyPosItem(suriken)
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
	slash:ApplyPosToSprUseCamera(GetCamera())
	act.attacker = slash
	GetStage():AddChild(slash)
end

class 'PlayerCursorCharge'(PlayerCursor)
function PlayerCursorCharge:__init()
	PlayerCursor.__init(self)
	
	self.attackWaitCnt = 0
	self.itemCnt = 0
end

function PlayerCursorCharge:BeginStartDemo(num)
	self.slashLine:Hide()
end
function PlayerCursorCharge:BeginStage(num)
	self.slashLine:Show()
end
function PlayerCursorCharge:BeginClearDemo(num)
	self.slashLine:Hide()
end
function PlayerCursorCharge:BeginEnding()
	self.slashLine:Hide()
end


function PlayerCursorCharge:ThrowSuriken(act, kind)
	PlayerCursor.ThrowSuriken(self, act, kind)
	self.attackWaitCnt = SURIKEN_WAIT_FRAME
end

function PlayerCursorCharge:Begin()
	PlayerCursor.Begin(self)
	
	-- make gauge
	local gauge = Gauge()
	gauge.enable = false
	
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
		if GetPlayer():GetItemCnt() > 0 then
			GetPlayer():DecItem()
		end
	end
	
	gauge:Begin(releaseFunc, releaseFunc2)
	gauge.x = PLAYER_X - MAX_GAUGE_WIDTH / 2 + 15
	gauge.y = GAUGE_Y
	GetStage():AddChild(gauge)

	-- slash line
	self.slashLine = Actor()
	self.slashLine:Begin()
	self.slashLine:SetText("|")
	self.slashLine.x = SLASHABEL_X_MAX
	self.slashLine.y = LINE_HEIGHTS[LINE_BOTTOM]
	GetCamera():AddAutoApplyPosItem(self.slashLine)
	self:AddChild(self.slashLine)
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
		GetStage().enemyMgr:RemoveEnemy(self.target)
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
	
	GS.SoundMgr:PlaySe("slash")
end

function Slash:StateStart(rt)
	self:Attack()
	for idx = 0, 4 do
		rt:Wait(SLASH_ANIM_SPD)
		self:GetSpr().divTexIdx = idx
	end
	
	GetStage():RemoveChild(self)
	self:Dead()
	rt:Wait()
end



class'EnemyManager'(Actor)
function EnemyManager:__init(idCnt)
	Actor.__init(self)
	self.enemies = {}
end

function EnemyManager:Begin()
	Actor.Begin(self)
end

function EnemyManager:BeginStartDemo()
	self.enable = false
end

function EnemyManager:BeginStage(num)
	self.enable = true
	self:ChangeRoutine("StateStart")
end

function EnemyManager:BeginClearDemo()
	self.enable = false
end

function EnemyManager:BeginEnding()
	self.enable = true
	self:ChangeRoutine("StateEnding")
end



function EnemyManager:GetEnemies()
	return self.enemies
end

function EnemyManager:AddEnemy(enemy)
	GetStage():AddChild(enemy)
	table.insert(self.enemies, enemy)
	GetStage():GetSpr():SortZ()
end

function EnemyManager:RemoveEnemy(enemy)
	enemy:Dead()
	RemoveValue(self.enemies, enemy)
	GetStage():RemoveChild(enemy)
end

function EnemyManager:ClearEnemy()
	while table.getn(self.enemies) > 0 do
		self:RemoveEnemy(self.enemies[1])
	end
end

function EnemyManager:BurstAllEnemy()
	-- すべての敵をbom
	local deadTargets = {}
	for idx, enemy in ipairs(self.enemies) do
		enemy.hp = 1
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
	
end

function EnemyManager:StateStart(rt)
	local updateCnt = 0
	local data = {}
	local spanData = STAGE_DATA[GetStage().stageNum].ENEMY_SPAN

	for line = LINE_TOP, LINE_BOTTOM do
		table.insert(data, {waitCycle=0})
	end

	while true do
		for line = LINE_TOP, LINE_BOTTOM do
		
			if data[line].waitCycle <= 0 then 
				-- 出現させる
				local enemy = self:CreateEnemy(line)
				self:AddEnemy(enemy)
				
				-- 何周期後に出現するか決める
				local span = spanData[line].max - spanData[line].min
				local chance = span / ENEMY_ENCOUNT_FRAME
				data[line].waitCycle = math.random(0, chance) + spanData[line].min / ENEMY_ENCOUNT_FRAME
			end
			data[line].waitCycle = data[line].waitCycle - 1
		end
		rt:Wait(ENEMY_ENCOUNT_FRAME)
	end
end

function EnemyManager:StateEnding(rt)
	while true do
		self:AddTextEnemy("ドット絵　ねちょ", LINE_TOP)
		rt:Wait(120)
		self:AddTextEnemy("イラスト　ガンサー", LINE_MIDDLE)
		rt:Wait(120)
		
		self:AddTextEnemy("プログラム　コケいろ", LINE_TOP)
		rt:Wait(120)
		
		self:AddTextEnemy("企画　スーパーウルトラサンボマンボマーシャルアーツ", LINE_MIDDLE)
		rt:Wait(300)

		self:AddTextEnemy("さんきゅーふぉーぷれいんぐ！", LINE_MIDDLE)
		rt:Wait(240)
		
		GetStage():ChangeRoutine("StateEnding2")
		self.enable = false
		rt:Wait()
	end
end

function EnemyManager:AddTextEnemy(text, line)
	local x = 640
	for i=1, string.len(text), 2 do
		local char = string.sub(text, i, i+1)
		if char ~= "　" then
			local enemy = CharactorEnemy(char)
			enemy:Begin()
			enemy.spdDownCnt	= 30
			enemy.spd			= 8
			enemy.spd2		= 2
			enemy.line		= line
			enemy.x 			= x
			enemy.y				= LINE_HEIGHTS[enemy.line]
			enemy:ApplyPosToSprUseCamera(GetCamera())
			GetCamera():AddAutoApplyPosItem(enemy)

			self:AddEnemy(enemy)
			x = x + enemy:GetSpr().width
		else
			x = x + 20
		end
	end
end

function EnemyManager:CreateEnemy(line)
	local back = GetStage().back
	local spd = (back.scrollSpd * ENEMY_SPD[line]) / SCROLL_SPD
	
	local enemy = nil
	if line == LINE_BOTTOM then
		enemy = Rock()
	else
		if GetStage().stageNum == 1 then
			enemy = Enemy(math.random(0, 5))
		elseif GetStage().stageNum == 2 then
			if math.random(1, 100) <= PROB_CELES_STAGE2 then
				enemy = Celes()
			else
				enemy = Enemy(math.random(0, 5))
			end
		elseif GetStage().stageNum == 3 then
			if math.random(1, 100) <= PROB_CELES_STAGE3 then
				enemy = Celes()
			else
				enemy = Enemy(math.random(0, 5))
			end
		end
	end
	enemy:Begin()
	
	enemy.line	= line
	enemy.spd		= spd
	enemy.x			= GetProperty("WindowWidth") + 30
	enemy.y			= LINE_HEIGHTS[enemy.line]
	enemy:ApplyPosToSprUseCamera(GetCamera())
	GetCamera():AddAutoApplyPosItem(enemy)
	return enemy
end


--@Enemy
class 'Enemy'(Actor)
function Enemy:__init(kind)
	Actor.__init(self)
	self.hantId = HANT_ID.ZAKO
	
	self.spd = 0
	self.kind = kind
	self.attacker = nil
	self.hp = HP_ZAKO
	self.point = POINT_ZAKO
	self.floatPointY = FLOAT_POINT_Y_ZAKO
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
	pcl:ApplyPosToSprUseCamera(GetCamera())
	GetStage():AddChild(pcl)
	self:UpdateScore(kind)
end

function Enemy:UpdateScore(kind)
	if kind == DEAD_REASON_TIME_UP then
		return
	end
	
	local point = nil
	if kind == ATTACK_CHARGE2_SURIKEN then
		point = POINT_USE_CHARGE2
	else
		point = self.point
	end
	
	GetStage().scoreMgr:AddPoint(point)
	GetStage().scoreMgr:AddHantCnt(self.hantId)
	self:AddPointAct(point)
end

function Enemy:AddPointAct(point)
	if point == 0 then
		return nil
	end
	local pointAct = Actor()
	pointAct:Begin()
	pointAct.x = self.x
	pointAct.y = self.y + self.floatPointY
	
	local col
	if point > 0 then 
		col = Color.Black
	else
		col = Color.Red
	end
	pointAct:SetText(tostring(point), col)
	pointAct:GetSpr():SetFontSize(24)
	pointAct:GetSpr().cx = pointAct:GetSpr().width / 2
	pointAct:GetSpr().yx = pointAct:GetSpr().height / 2
	pointAct:ApplyPosToSpr()
	GetCamera():AddAutoApplyPosItem(pointAct)
	
	pointAct:ChangeFunc(function(rt)
		local span = 30
		for i=1,span do
			pointAct.y = pointAct.y - 0.5
			pointAct:GetSpr().alpha = 1 - (i / span)
			rt:Wait()
		end
		return "exit"
	end)
	GetStage():AddChild(pointAct)
	return pointAct
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
		if self.x < -30 and self.attacker == nil then
			GetStage().enemyMgr:RemoveEnemy(self)
			GetStage().scoreMgr:FailedPerfect()
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
		
		self:ApplyPosToSprUseCamera(GetCamera())
		rt:Wait()
	end
end

--@Rock
class 'Rock'(Enemy)
function Rock:__init()
	Enemy.__init(self)
	self.hantId = HANT_ID.ROCK

	self.hp = HP_ROCK
	self.point = POINT_ROCK
	self.floatPointY = FLOAT_POINT_Y_ROCK
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
		pcl:ApplyPosToSprUseCamera(GetCamera())
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
	self:UpdateScore(attackKind)
end

function Rock:StateStart(rt)
	while true do
		self.x = self.x - self.spd
		if self.x < HIT_PLAYER_ROCK_X and self.attacker == nil then
			GetStage().scoreMgr:AddPoint(POINT_PLAYER_ROCK_HIT)
			GetStage().scoreMgr:AddHantCnt(HANT_ID.CLASH_ROCK)
			local pact = self:AddPointAct(POINT_PLAYER_ROCK_HIT)
			if pact ~= nil then
				pact.y = pact.y - 20
			end
			
			local pcl = RockCrashParticle()
			pcl:Begin()
			pcl:SetPos(self.x, self.y)
			pcl:ApplyPosToSpr()
			GetStage():AddChild(pcl)

			GetStage().enemyMgr:RemoveEnemy(self)
			GetStage().scoreMgr:FailedPerfect()
			rt:Wait()
		end
		self:GetSpr().rot = self:GetSpr().rot + math.rad(ROCK_ROT_SPD)
		self:ApplyPosToSprUseCamera(GetCamera())
		rt:Wait()
	end
end



--@Celes
class 'Celes'(Enemy)
function Celes:__init()
	Enemy.__init(self)
	self.hantId = HANT_ID.CELES

	self.hp = HP_CELES
	self.point = POINT_CELES
	self.floatPointY = FLOAT_POINT_Y_CELES
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
		if self.x < -30 and self.attacker == nil  then
			GetStage().enemyMgr:RemoveEnemy(self)
			GetStage().scoreMgr:FailedPerfect()
			rt:Wait()
		end
		self:ApplyPosToSprUseCamera(GetCamera())
		rt:Wait()
	end
end



class 'CharactorEnemy'(Enemy)
function CharactorEnemy:__init(char)
	Enemy.__init(self)
	self.hp = 1
	self.char = char
	self.liveCnt = 0
	self.point = 0
end

function CharactorEnemy:SetActTexture()
	self:SetText(self.char)
	self:GetSpr().name = "char spr"
	self:GetSpr().cx = self:GetSpr().width  / 2
	self:GetSpr().cy = self:GetSpr().height / 2
end


function CharactorEnemy:StateStart(rt)
	while true do
		self.liveCnt = self.liveCnt + 1
		if self.liveCnt > self.spdDownCnt then
			self.spd = self.spd2
		end
		
		self.x = self.x - self.spd
		if self.x < -30 and self.attacker == nil  then
			GetStage().enemyMgr:RemoveEnemy(self)
			GetStage().scoreMgr:FailedPerfect()
			rt:Wait()
		end
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

function GameBack:BeginStartDemo(stageNum)
	local sprX = 0
	for idx, spr in ipairs(self.sprites) do
		spr:SetTextureMode(STAGE_BACK_NAMES[stageNum])
		spr.x = sprX
		spr.alpha = STAGE_BACK_ALPHA[stageNum]
		sprX = sprX + spr.width
	end
end

function GameBack:StateStart(rt)
	local sprCnt = table.getn(self.sprites)
	while true do
		local x, y = GetCamera():GetPos()
		self:GetSpr().x = -x
		self:GetSpr().y = -y
		for idx, spr in pairs(self.sprites) do
			spr.x = spr.x - self.scrollSpd
			-- 左に行き過ぎたら右へ
			if spr.x + spr.width + self:GetSpr().x < 0 then
				spr.x = spr.x + sprCnt * spr.width
			end
			-- 右に行き過ぎたら左へ
			if spr.x + self:GetSpr().x > GetProperty("WindowWidth") then
				spr.x = spr.x - 6 * spr.width
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
	self:SetAnimation(PatcarAnim())
end

function PatrolCar:BeginStartDemo(num)
	if num == 2 then
		self.enable = true
		self:Show()
	else
		self.enable = false
		self:Hide()
	end
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

	self.backSpr = Sprite()
	self.backSpr:SetTextureMode("whitePix")
	self.backSpr.alpha = 0.3
	self.backSpr.drawWidth  = MAX_GAUGE_WIDTH
	self.backSpr.drawHeight = GAUGE_HEIGHT
	self.backSpr.z = 10
	self:GetSpr():AddChild(self.backSpr)
	
	GetCamera():AddAutoApplyPosItem(self)
end

function Gauge:BeginStartDemo(num)
	self.enable = false
	self:Hide()
	self.backSpr:Hide()
end

function Gauge:BeginStage(num)
	self.enable = true

	self:Show()
	self.backSpr:Show()
end

function Gauge:BeginClearDemo(num)
	self.enable = false
	self.chargeCnt = 0
	self:GetSpr():SetTextureColorF(Color.White)
	self:GetSpr().drawWidth  = 1
	
	self:Hide()
	self.backSpr:Hide()
end

function Gauge:StateStart(rt)
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

	self.fadeHelper = FadeHelper(self)
	
	self.animCnt = 0
end


function StageMarker:BeginStartDemo(stageNum)
	self.enable = false
	self.isGoaled = false
	self.nowFrame = 0
	self.maker.x = MARKER_LEFT_X
	self.stageFrame = STAGE_FRAME[stageNum]
	
	self:Hide()
end


function StageMarker:BeginStage(stageNum)
	self.enable = true
	local toX, toY = self:GetPos()
	
	self:Show()
	self.fadeHelper:Fade(UI_FADE_FRAME,
											 toX, toY - 10, 0,
											 toX, toY, 1)
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

class 'CameraShakeActor'(Actor)
function CameraShakeActor:__init(camera)
	Actor.__init(self)
	self.camera = camera
end

function CameraShakeActor:Begin(stageNum)
	Actor.Begin(self)
end

function CameraShakeActor:Shake(cnt, x, y)
	self.enable = true
	self.params.cnt	= cnt
	self.params.x		= x
	self.params.y		= y
	self:ChangeRoutine("StateShake")
end

function CameraShakeActor:StateShake(rt)
	local params = self.params
	local wait = 2
	local camera = self.camera
	for i=1, params.cnt, wait do
		self.x = math.random(-params.x, params.x)
		self.y = math.random(-params.y, params.y)
		rt:Wait(2)
	end
	self.enable = false
	self.x = 0
	self.y = 0
	rt:Wait()
end


class 'Camera'(Actor)
function Camera:__init()
	Actor.__init(self)
	self.items = {}
end

function Camera:Begin(stageNum)
	Actor.Begin(self)
	self.updateOrder = -10000
	
	self.shakeAct = CameraShakeActor(self)
	self.shakeAct:Begin()
	self.shakeAct:AddChild(self.shakeAct)
end

function Camera:BeginStartDemo(num)
	self:SetPos(0, 0)
	self.shakeAct:SetPos(0, 0)
end

function Camera:StateStart(rt)
	local spd = 6
	while true do
		if GS.IsDebug then
			if GS.InputMgr:IsKeyHold(KeyCode.KEY_J) then
				self.x = self.x - spd
			end
			if GS.InputMgr:IsKeyHold(KeyCode.KEY_L) then
				self.x = self.x + spd
			end
			if GS.InputMgr:IsKeyHold(KeyCode.KEY_I) then
				self.y = self.y - spd
			end
			if GS.InputMgr:IsKeyHold(KeyCode.KEY_K) then
				self.y = self.y + spd
			end
		end
		self:AutoApply()
		rt:Wait()
	end
end

function Camera:Shake(cnt, x, y)
	self.shakeAct:Shake(cnt, x, y)
end


function Camera:AddAutoApplyPosItem(item)
	table.insert(self.items, item)
end

function Camera:AutoApply()
	for idx, item in ipairs(self.items) do
		item:ApplyPosToSprUseCamera(self)
	end
end

function Camera:GetValidPos()
	return self.x + self.shakeAct.x,
				 self.y + self.shakeAct.y
end


class'StageScore'(Actor)
function StageScore:__init()
	Actor.__init(self)
	self.point = 0
	self.idCnt = {}
	self.isPerfect = nil
end

function StageScore:Begin()
	Actor.Begin(self)
	self:CreateSpr()
	self:UpdateText()
	self.fadeHelper = FadeHelper(self)
end

function StageScore:BeginStartDemo(stageNum)
	self.update = true
	self.isPerfect = true
	ClearTable(self.idCnt)
	self.point = 0
	self:UpdateText()
	self:Hide()
end

function StageScore:BeginStage(num)
	self:Show()
	self.fadeHelper:Fade(UI_FADE_FRAME,
											 self.x, self.y - 10, 0,
											 self.x, self.y, 1)
end

function StageScore:AddPoint(point)
	self.point = self.point + point
	self:UpdateText()
end

function StageScore:AddHantCnt(hantId)
	self.idCnt[hantId] = (self.idCnt[hantId] or 0) + 1
	self.update = true
end

function StageScore:UpdateText()
	if self:GetSpr():IsDraw() then
		self:SetText("得点："..self.point)
	end
end

function StageScore:FailedPerfect()
	self.isPerfect = false
end

function StageScore:GetPointVal()
	return self.point
end



class'StageNumber'(Actor)
function StageNumber:__init()
	Actor.__init(self)
end

function StageNumber:Begin()
	Actor.Begin(self)
	self:SetText("")
	self.fadeHelper = FadeHelper(self)
end

function StageNumber:BeginStartDemo(stageNum)
	self:SetText("STAGE"..stageNum)
	self:Hide()
end

function StageNumber:BeginStage(num)
	self:Show()
	self.fadeHelper:Fade(UI_FADE_FRAME,
											 self.x, self.y - 10, 0,
											 self.x, self.y, 1)
end





class'StageResult'(Actor)
function StageResult:__init(idCnt, isPerfect, shownFunc)
	Actor.__init(self)
	
	self.idCnt = CopyTable(idCnt)
	self.isPerfect = isPerfect
	self.shownFunc = shownFunc
end

function StageResult:Begin()
	Actor.Begin(self)
	
	self:CreateSpr()
	
	self.lines = {}

	local hantCnt = 0
	for k, v in pairs(self.idCnt) do
		if k ~= HANT_ID.CLASH_ROCK then
			hantCnt = hantCnt + v
		end
	end
	
	self.hantAct = Actor()
	self.hantAct:Begin()
	self.hantAct:SetText(string.format("撃破数 %10d", hantCnt))
	self.hantAct:Hide()
	self.hantAct:SetPos(0, 40)
	self.hantAct:ApplyPosToSpr()
	self:AddChild(self.hantAct)
	
	self.crashAct = Actor()
	self.crashAct:Begin()
	self.crashAct:SetText(string.format("衝突数 %10d", self.idCnt[HANT_ID.CLASH_ROCK] or 0))
	self.crashAct:Hide()
	self.crashAct:SetPos(0, 80)
	self.crashAct:ApplyPosToSpr()
	self:AddChild(self.crashAct)

	-- item
	self.itemAct = Actor()
	self.itemAct:Begin()
	self.itemAct:SetDivTexture("suriken", 4, 1, 32, 32)
	self.itemAct:GetSpr().cx = 16
	self.itemAct:GetSpr().cy = 16
	self.itemAct:SetPos(0, 150)
	self.itemAct:ApplyPosToSpr()
	
	-- item text
	self.itemAct.textSpr = Sprite()
	local cnt = GetPlayer():GetItemCnt()
	local score = POINT_ITEM * cnt
	local text = string.format("%d × %d = ", POINT_ITEM, cnt)
	self.itemAct.textSpr:SetTextMode(text)
	self.itemAct.textSpr.cy = self.itemAct.textSpr.height / 2
	self.itemAct.textSpr.x = 40
	self.itemAct:GetSpr():AddChild(self.itemAct.textSpr)
	
	-- item score
	local itemScoreSpr = Sprite()
	itemScoreSpr:SetTextMode(tostring(POINT_ITEM*cnt))
	itemScoreSpr.cx = itemScoreSpr.width
	itemScoreSpr.x = 300
	itemScoreSpr.cy = itemScoreSpr.height / 2
	self.itemAct.scoreSpr = itemScoreSpr
	self.itemAct:GetSpr():AddChild(itemScoreSpr)
	self.itemAct.score = POINT_ITEM * cnt
	
	self.itemAct:Hide()
	self.itemAct.textSpr:Hide()
	self.itemAct.scoreSpr:Hide()
	self:AddChild(self.itemAct)
	
	-- perfect
	if self.isPerfect then
		self.perfectAct = Actor()
		self.perfectAct:Begin()
		self.perfectAct:SetText("全滅ボーナス")
		self.perfectAct:GetSpr().cy = self.perfectAct:GetSpr().height / 2
		self.perfectAct:SetPos(0, 190)
		self.perfectAct:ApplyPosToSpr()

		local spr = Sprite()
		spr:SetTextMode(tostring(POINT_PERFECT_BOUNUS))
		spr.cx = spr.width
		spr.x = 300
		spr.cy = spr.height / 2
		self.perfectAct.scoreSpr = spr
		self.perfectAct:GetSpr():AddChild(spr)

		self.perfectAct.score = POINT_PERFECT_BOUNUS
	
		self.perfectAct:Hide()
		self.perfectAct.scoreSpr:Hide()
		self:AddChild(self.perfectAct)
	end

	self.totalAct = Actor()
	self.totalAct:Begin()
	self.totalAct:SetText("総合")
	self.totalAct:GetSpr():SetFontSize(30)
	self.totalAct:GetSpr().cy = self.totalAct:GetSpr().height / 2
	self.totalAct:SetPos(0, 250)
	self.totalAct:ApplyPosToSpr()

	local totalVal = GetStage().scoreMgr:GetPointVal()
	local spr = Sprite()
	spr:SetTextMode(tostring(totalVal))
	spr:SetFontSize(30)
	spr.cx = spr.width
	spr.x = 300
	spr.cy = spr.height / 2
	self.totalAct.scoreSpr = spr
	self.totalAct:GetSpr():AddChild(spr)

	self.totalAct.score = totalVal

	self.totalAct:Hide()
	self.totalAct.scoreSpr:Hide()
	self:AddChild(self.totalAct)
end

function StageResult:StateStart(rt) 
	self.hantAct:Show()
	GS.SoundMgr:PlaySe("bosu")
	rt:Wait(30)

	self.crashAct:Show()
	GS.SoundMgr:PlaySe("bosu")
	rt:Wait(30)

	self.itemAct:Show()
	self.itemAct.textSpr:Show()
	self.itemAct.scoreSpr:Show()
	GS.SoundMgr:PlaySe("bosu")
	rt:Wait(30)

	if self.isPerfect then
		self.perfectAct:Show()
		self.perfectAct.scoreSpr:Show()
		GS.SoundMgr:PlaySe("bosu")
		rt:Wait(30)
	end

	self.totalAct:Show()
	self.totalAct.scoreSpr:Show()
	GS.SoundMgr:PlaySe("bosu")

	rt:Wait(60)

	local tmp = 100
	while self.itemAct.score > 0 do
		local hoge = nil
		if self.itemAct.score < tmp then
			hoge = self.itemAct.score
		else
			hoge = tmp
		end
		GetStage().scoreMgr:AddPoint(hoge)
		self.itemAct.score = self.itemAct.score - hoge
		self.itemAct.scoreSpr:SetText(tostring(self.itemAct.score))
		self.itemAct.scoreSpr.cx = self.itemAct.scoreSpr.width

		self.totalAct.score = self.totalAct.score + hoge
		self.totalAct.scoreSpr:SetText(tostring(self.totalAct.score))
		self.totalAct.scoreSpr.cx = self.totalAct.scoreSpr.width
		rt:Wait()
	end
	rt:Wait(60)

	if self.isPerfect then
		while self.perfectAct.score > 0 do
			local hoge = nil
			if self.perfectAct.score < tmp then
				hoge = self.perfectAct.score
			else
				hoge = tmp
			end
			GetStage().scoreMgr:AddPoint(hoge)
			self.perfectAct.score = self.perfectAct.score - hoge
			self.perfectAct.scoreSpr:SetText(tostring(self.perfectAct.score))
			self.perfectAct.scoreSpr.cx = self.perfectAct.scoreSpr.width

			self.totalAct.score = self.totalAct.score + hoge
			self.totalAct.scoreSpr:SetText(tostring(self.totalAct.score))
			self.totalAct.scoreSpr.cx = self.totalAct.scoreSpr.width
			rt:Wait()
		end
		rt:Wait(60)
	end

	if self.shownFunc ~= nil then
		self.shownFunc()
	end
	while true do
		rt:Wait()
	end
end









