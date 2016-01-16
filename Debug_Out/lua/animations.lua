require("actor")

-- アニメーション機能を提供する
class 'Animation'(Actor)
function Animation:__init()
	Actor.__init(self)
end

-- 初期化する
function Animation:Begin()
	Actor.Begin(self)
end

-- 指定されたメンバ関数名のアニメーションを開始する
function Animation:BeginAnim(name)
	error("継承先でオーバーライドして使用してください！")
end

-- 親を変更する
function Animation:SetOwner(owner)
	self.owner = owner
	if self.ChangedOwner ~= nil then
		self:ChangedOwner()
	end
end



-- プレイヤーのアニメーション機能を提供する
class 'PlayerAnim'(Animation)
function PlayerAnim:__init(mode)
	Actor.__init(self)
end

-- 親を変更する
function PlayerAnim:ChangedOwner()
	local spr = self.owner:GetSpr()
	spr.name = "player anim spr"
	spr.divTexIdx = 0
	spr:SetCenter(16, 16)
end

-- 指定されたアニメーションを再生する
function PlayerAnim:BeginAnim(name)
	if name == "run" then
		self:ChangeRoutine("StateRun")
	elseif name == "jump" then
		self:ChangeRoutine("StateJump")
	else
		error("not def")
	end
end

-- 「走る」アニメーションを再生する
function PlayerAnim:StateRun(rt)
	local spr = self.owner:GetSpr()

	while true do
		for idx=0, 5 do
			spr.divTexIdx = idx
			rt:Wait(3)
		end
	end
end

-- 「ジャンプ」アニメーションを再生する
function PlayerAnim:StateJump(rt)
	local spr = self.owner:GetSpr()
	while true do
		spr.divTexIdx = 5
		rt:Wait(10000)
	end
end

--　やぎのアニメーション機能を提供する
class 'PlayerYagiAnim'(PlayerAnim)
function PlayerYagiAnim:__init(mode)
	PlayerAnim.__init(self)
end

-- 「走る」アニメーション
function PlayerYagiAnim:StateRun(rt)
	local spr = self.owner:GetSpr()

	while true do
		for idx=12, 17 do
			spr.divTexIdx = idx
			rt:Wait(3)
		end
	end
end

-- 「ジャンプ」アニメーション
function PlayerYagiAnim:StateJump(rt)
	local spr = self.owner:GetSpr()
	while true do
		spr.divTexIdx = 17
		rt:Wait(10000)
	end
end



local PAT_ANIM_SPD	= 1

-- パトカーのアニメーション機能を提供する
class 'PatcarAnim'(Animation)
function PatcarAnim:__init()
	Actor.__init(self)
	
end

-- 親を変更する
function PatcarAnim:ChangedOwner()
	-- パトカーの画像を読み込む
	self.owner:SetDivTexture("patcar", 4, 4, 100, 50)

	local spr = self.owner:GetSpr()
	spr.name = "patcar spr"
	spr.divTexIdx = 12

	GetCamera():AddAutoApplyPosItem(self.owner)
end

-- アニメーションを再生する
function PatcarAnim:StateStart(rt)
	local spr = self.owner:GetSpr()
	while true do
		for idx=12, 15 do
			spr.divTexIdx = idx
			rt:Wait(PAT_ANIM_SPD)
		end
	end
end


-- セレスっちのアニメーション機能を提供する
class 'CelesAnim'(Animation)
function CelesAnim:__init()
	Actor.__init(self)
end

function CelesAnim:BeginAnim()
	self:ChangeRoutine("StateStart")
end

-- 親を変更する
function CelesAnim:ChangedOwner()
	-- セレスっちの画像を読み込む
	self.owner:SetDivTexture("celes", 3, 2, 50, 50)
	local spr = self.owner:GetSpr()
	spr.name = "celes anim spr"
	spr.cx = 25
	spr.cy = 25
end

-- 横にゆらゆら揺れるアニメーションを再生する
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


-- 簡易的なアニメーション機能を提供する
class 'SimpleAnimation'(Animation)
function SimpleAnimation:__init()
	Actor.__init(self)
	
	self:SetDefaultAnim("def")
	
	self.animData = {}
end

function SimpleAnimation:SetDefaultAnim(name)
	self.defAnimName = name
end

-- アニメーションの再生に必要なデータを追加する
function SimpleAnimation:AddFrameAnimData(name, beginFrame, endFrame, waitFrame)
	self.animData[name] = 
		{
			t		= "FrameAnim", 
			b 	= beginFrame, 
			e		= endFrame, 
			w 	= waitFrame
		}
end

-- AddFrameAnimDataで登録したアニメーションを開始する
function SimpleAnimation:BeginAnim(name)
	self.currentAnimName = name
	local t = self.animData[name]["t"]
	if t == "FrameAnim" then
		self:ChangeRoutine("StateFrameAnim")
	else
		error("not def")
	end
end

-- AddFrameAnimDataで登録したアニメーションを再生する
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



