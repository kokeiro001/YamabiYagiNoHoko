-- グローバル空間から毎回探すと重いので、キャッシュを取る
local coyield = coroutine.yield

-- Actorには唯一となるIDを割り当てる
local ActorId = 1
function GetNextActorId()
	local id = ActorId
	ActorId = ActorId + 1
	return id
end

-- Actorクラス
-- 全てのゲーム内オブジェクトの基礎となる
-- 座標、スプライトを持ち、子Actorを持つことが出来る
class'Actor'

function Actor:__tostring()
	return "class Actor name="..self.name
end

-- IDが等しければ、同じオブジェクトである
function Actor:__eq(val)
	if val.id ~= nil and val.id == self.id then
		return true
	end
	return false
end

-- 初期化する
function Actor:__init()
	self.id = GetNextActorId()	-- IDを取得する

	self.spr = nil

	self.x = 0
	self.y = 0
	self.name = "class Actor"
	self.params = {}
	
	self.scheduler = nil
	
	self.currentRoutine = nil
	self.stateFuncName = "StateStart"	-- 初回のUpdateで呼び出される関数名
	
	self.enable = true
	self.isDead	= false
	self.updateOrder	= 0
	
	self.parent = nil
	self.children = {}
end

-- 座標を取得する(x, y)
function Actor:GetPos()
	return self.x, self.y
end

-- 座標を設定する
function Actor:SetPos(x, y)
	self.x = x
	self.y = y
end

-- Actorを有効にする
function Actor:Begin()
	if self.StateStart ~= nil then
		-- Actor開始用ルーチンに切り替える
		if self:ChangeRoutine("StateStart") then
			GS.Scheduler:AddActor(self)
			self.scheduler = GS.Scheduler
		else
			print("change_routine failed.")
		end
	end
end

-- Actorを無効にする
function Actor:Dead()
	self.enable = false
	self.isDead = true
	if self.anim ~= nil then
		self.anim:Dead()
	end
	
	-- Schedulerに削除フラグを立てるよう要請する。
	-- 適切なタイミングで、実際に破棄される
	GS.Scheduler:DeleteActor(self)
end

-- リソースの破棄を行う
function Actor:Dispose()
	-- Schedulerから、適切なタイミングで呼び出される
	self.params = nil
	self:RemoveFromParent()
	
	-- 描画システムから切り離す
	if self.spr ~= nil then
		GS.DrawSys:RemoveSprite(self.spr)
	end
	
	-- 子ActorをSchedulerから切り離す
	for i, chr in pairs(self.children) do
		GS.Scheduler:DeleteActor(chr)
	end
	self.children = {}

	self.drawSys = nil
	self.scheduler = nil
end



-- 子Actorを追加する
function Actor:AddChild(chr)
	chr.parent = self
	table.insert(self.children, chr)
	
	-- 子要素にスプライトが設定されている場合、自身のスプライトと関係付を行う
	if chr.spr ~= nil then
		-- 自身のスプライトが空の場合、子スプライトを追加するために空のスプライトを自身に付与する
		if self.spr == nil then
			self:CreateSpr()
			self.spr:Show()
		end
		self.spr:AddChild(chr.spr)
	end
end

-- 子Actorを全て削除する
function Actor:ClearChild()
	for i, chr in pairs(self.children) do
		chr:RemoveFromParent()
	end
	self.children = {}
end

-- 指定した子Actorを削除する
function Actor:RemoveChild(chr)
	if chr.parent == self then
		-- スプライトの関係を断つ
		if chr.spr ~= nil then
			self.spr:RemoveChild(chr.spr)
		end
		chr.parent = nil
		-- 子Actorをまとめるテーブルから削除する
		RemoveValue(self.children, chr)
	end
end

-- 親Actorから自身を切り離す
function Actor:RemoveFromParent()
	if self.parent ~= nil then
		-- スプライトの関係を断つ
		if self.spr ~= nil then
			self.spr:RemoveFromParent()
		end
		
		self.parent:RemoveChild(self)
	end
end

-- 子Actorのテーブルを取得する
function Actor:GetChild()
	return self.children
end

-- idから子Actorを取得する
function Actor:GetChildId(id)
	for idx, chr in ipairs(self.children) do
		if chr.id == id then
			return chr
		end
	end
	return nil
end


-- スプライトを取得する
function Actor:GetSpr()
	return self.spr
end

-- 空のスプライトを作成し、自身に付与する
function Actor:CreateSpr()
	self.spr = Sprite()
	self.spr.name = "lua_spr actor.id="..self.id
	
	-- 親Actorがいる場合、親のスプライトに自身のスプライトを付与する
	if self.parent ~= nil then
		self.parent:GetSpr():AddChild(self.spr)
	end
end

-- 描画システムに自身のスプライトを追加する。追加しないと描画されない。
function Actor:AddSprToDrawSystem()
	if self.spr ~= nil then
		GS.DrawSys:AddSprite(self.spr)
	end
end

-- 指定したエイリアスの画像をスプライトに設定する
function Actor:SetTexture(name)
	-- 自身のスプライトが空の場合、空のスプライトを自身に付与する
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextureMode(name)
end

-- 指定したエイリアスの画像をスプライトに設定する
-- @param name	画像のエイリアス
-- @param xdiv	使用画像の横の分割数
-- @param ydiv	使用画像の縦の分割数
-- @param width	分割後の画像の幅(pix)
-- @param height	分割後の画像の高さ(pix)
function Actor:SetDivTexture(name, xdiv, ydiv, width, height)
	-- 自身のスプライトが空の場合、空のスプライトを自身に付与する
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetDivTextureMode(name, xdiv, ydiv, width, height)
end


-- 色はClorFで指定すること
function Actor:SetText(text, col)
	-- 自身のスプライトが空の場合、空のスプライトを自身に付与する
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextMode(text)
	if col ~= nil then
		self.spr:SetTextColorF(col)
	end
end

function Actor:SetText2(text, fontName, col)
	-- 自身のスプライトが空の場合、空のスプライトを自身に付与する
	if self.spr == nil then
		self:CreateSpr()
	end
	self.spr:SetTextMode2(text, fontName)
	if col ~= nil then
		self.spr:SetTextColorF(col)
	end
end

-- Actorの座標をスプライトにも適用する
function Actor:ApplyPosToSpr()
	self.spr.x = self.x
	self.spr.y = self.y
end

-- Actorの座標をスプライトにも適用する。
-- cameraを利用した補正を行う
function Actor:ApplyPosToSprUseCamera(camera)
	local x, y = camera:GetValidPos()
	self.spr.x = self.x - x
	self.spr.y = self.y - y
end

-- スプライトを表示する
function Actor:Show()
	self:GetSpr():Show()
end

-- スプライトを非表示にする
function Actor:Hide()
	self:GetSpr():Hide()
end

-- 毎フレーム呼び出すルーチンを変更する。メンバ関数名を指定する。
function Actor:ChangeRoutine(name)
	-- クラスの持つメンバ関数から探す
	local f = self[name]
  if f == nil or type(f) ~= "function" then
		error("Actor:change_routine : coroutine func not found :"..name)
		return false
  end

  -- スケジューラが未設定の場合、自身を登録する
	if self.scheduler == nil then
		self.currentRoutine = Routine()
		GS.Scheduler:AddActor(self)
		self.scheduler = GS.Scheduler
	end

	-- ルーチン変更してリスタートする
	self.currentRoutine:ChangeFunc(f)
	self.state_func_name = name
	return true
end

-- 毎フレーム呼び出すルーチンを変更する。引数に指定された関数をルーチンとして設定する。
function Actor:ChangeFunc(func)
	-- todo: Actor:ChangeRoutineと記述が重複している。リファクタリングする。

  -- スケジューラが未設定の場合、自身を登録する
	if self.scheduler == nil then
		self.currentRoutine = Routine()
		GS.Scheduler:AddActor(self)
		self.scheduler = GS.Scheduler
	end

	-- ルーチン変更してリスタートする
	self.currentRoutine:ChangeFunc(func)
	self.state_func_name = ""
	return true
end

-- 指定されたフレーム数、ルーチンの呼び出しを停止する
function Actor:Wait(count)
	coyield("wait", count or 0)
end


-- コルーチン内から呼ぶ関数
function Actor:Goto(label)
	coroutine.yield("goto", label)
end

-- コルーチンを終了する
function Actor:Exit(label)
	coroutine.yield("exit")
end

-- アニメーションを設定する。動作内容はAnimationクラスを参照する
function Actor:SetAnimation(anim)
	anim:Begin()
	anim:SetOwner(self)
	self.anim = anim
end


-- ルーチンを開始する
function Actor:StateStart(rt)
	while true do
		rt:Wait()
	end
end




-- 指定フレームの間、指定された速度(pix)で移動する
-- 移動そのものがルーチンとして設定されるため、他の動作をしながら移動することはできない
function Actor:MoveSpd(cnt, spdX, spdY)
	self.cnt = cnt
	self.spdX = spdX
	self.spdY = spdY
	self:ChangeRoutine("StateMoveSpd")
end

-- 実際の移動を行うルーチン。
-- 直上のMoveSpdメンバ関数から呼び出される
function Actor:StateMoveSpd(rt)
	for i=1, self.cnt do
		self.x = self.x + self.spdX
		self.y = self.y + self.spdY
		rt:Wait()
	end
	-- 処理が終了したら呼び出すルーチンを元に戻す
	self:Goto("StateStart")
end

-- 指定されたフレーム数かけて、指定された座標へ移動する
function Actor:Move(cnt, toX, toY)
	self.cnt = cnt
	self.fromX = self.x
	self.fromY = self.y
	self.toX = toX
	self.toY = toY
	self:ChangeRoutine("StateMove")
end

-- 直上のMoveメンバ関数から呼び出される、実際に移動する方法が記載されたメンバ関数
function Actor:StateMove(rt)
	local saX = self.fromX - self.toX
	local saY = self.fromY - self.toY
	for i=1, self.cnt do
		self.x = self.toX + saX * (1 - (i / self.cnt))
		self.y = self.toY + saY * (1 - (i / self.cnt))
		rt:Wait()
	end
	self.x = self.toX
	self.y = self.toY
	-- 処理が終了したら呼び出すルーチンを元に戻す
	self:Goto("StateStart")
end

-- ジャンプする
-- @param maxTime as num	最高到達点にたどり着くまでの時間
-- @param maxTime as num	最高到達点の高さ
-- @param maxTime as num	ジャンプーチンが終了するまでの時間
function Actor:MoveJump(maxTime, maxY, enableTime)
	self.srcY = self.y
	self.maxTime = maxTime
	self.maxY = maxY
	self.enableTime = enableTime
	self:ChangeRoutine("StateMoveJump")
end

-- 直上のMoveJumpメンバ関数から呼び出される、実際にジャンプの方法が記載されたメンバ関数
function Actor:StateMoveJump(rt)
	for i=1, self.enableTime do
		self.y = self.srcY 
						 + (2*self.maxY*i)/self.maxTime
						 -0.5*(2*self.maxY*(i*i)) / (self.maxTime * self.maxTime)
		rt:Wait()
	end
	self.y = self.srcY
	-- 処理が終了したら呼び出すルーチンを元に戻す
	self:Goto("StateStart")
end


-- フェード処理を行う機能を提供するクラス
class 'FadeHelper'(Actor)
function FadeHelper:__init(owner)
	Actor.__init(self)
	self.owner = owner
end

function FadeHelper:StateStart(rt)
	while true do
		rt:Wait()
	end
end

-- 座標、アルファ値をフェードする
function FadeHelper:Fade(cnt, fromX, fromY, fromAlpha, toX, toY, toAlpha)
	local spr = self.owner:GetSpr()
	self.cnt				= cnt
	self.fromX			= fromX
	self.fromY			= fromY
	self.fromAlpha	= fromAlpha
	self.toX				= toX
	self.toY				= toY
	self.toAlpha		= toAlpha
	
	self.owner:SetPos(fromX, fromY)
	spr.alpha = fromAlpha
	self.owner:ApplyPosToSpr()

	-- スプライトに自身のアルファ値を適用する。問答無用で上書きする。別途管理するべき。そもそも座標もカラーも同じメンバ関数でフェードしようとするなんておこがましい。ハードコーディングの産物。こうしてセカイは闇に染まる。
	for i=0, spr:GetChildCnt()-1 do
		local chr = spr:GetChild(i)
		chr.alpha = self.fromAlpha
	end
	
	-- ルーチンを開始する
	self:ChangeRoutine("StateFade")
end

-- 直上のFadeメンバ関数から呼び出される、実際にフェード方法が記載されたメンバ関数
function FadeHelper:StateFade(rt)
	local owner = self.owner
	local spr = owner:GetSpr()

	local len = spr:GetChildCnt()
	local saX = self.fromX - self.toX
	local saY = self.fromY - self.toY
	local saAlpha = self.fromAlpha - self.toAlpha
	
	for i=1, self.cnt do
		-- 自身の座標、アルファ値を更新する
		owner.x = self.toX + saX * (1 - (i / self.cnt))
		owner.y = self.toY + saY * (1 - (i / self.cnt))
		spr.alpha = self.toAlpha + saAlpha * (1 - (i / self.cnt))
		
		-- 子スプライトの座標、アルファ値を更新する
		for j=0, len-1 do
			local chr = spr:GetChild(j)
			chr.alpha = self.toAlpha + saAlpha * (1 - (i / self.cnt))
		end
		owner:ApplyPosToSpr()
		rt:Wait()
	end
	-- 処理が終了したら呼び出すルーチンを元に戻す
	self:Goto("StateStart")
end



-- ステージ開始前の一枚絵とかを表示するためにとりあえず作成されたクラス。が、中身は空。
-- 拡張したくなった時にはココに機能を追加していく
class 'DemoActor'(Actor)
function DemoActor:__init()
	Actor.__init(self)
end

function DemoActor:StateStart(rt)
	while true do
		rt:Wait()
	end
end








-- マウスの座標を表示する機能を提供するクラス。
class 'DebugMouseViewer'(Actor)
function DebugMouseViewer:__init()
	Actor.__init(self)
end

function DebugMouseViewer:Begin()
	Actor.Begin(self)
	self:SetText("tmp")
	self:GetSpr():SetFontSize(12)
	self:GetSpr().z = -100000000	-- 手前に描画する
end

function DebugMouseViewer:StateStart(rt)
	-- マウスの座標を表示する
	local prePos = Point2DI()
	while true do
		local pos = GS.InputMgr:GetMousePos()
		if pos.x ~= prePos.x and pos.y ~= prePos.y then
			prePos = pos
			self:GetSpr():SetText(string.format("MousePos(%3d, %3d)", pos.x, pos.y))
		end
		rt:Wait()
	end
end
