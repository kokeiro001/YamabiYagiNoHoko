-- particle
local BURST_ANIM_SPD = 3	-- 敵破裂エフェクトのアニメーション速度
local SLASHED_ROCK_PCL_SPAN = 60
local SLASH_ANIM_SPD = 1


-- 二次関数的な挙動で移動する物体の座標を計算する
-- @param maxX		最高到達点
-- @param maxTime	最高到達点にたどり着くまでの時間
-- @param nowTime	経過時間
function CalcPhyMove(maxX, maxTime, nowTime)
	return (2 * maxX * nowTime) / maxTime - 
					0.5*( 2 * maxX * (nowTime * nowTime)) / (maxTime * maxTime)
end



class 'Particle'(Actor)
function Particle:__init()
	Actor.__init(self)
end

-- 爆発パーティクル
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


-- アニメーションの内容
function BurstParticle:StateStart(rt)
	for idx = 1, 10 do
		for waitCnt = 1, BURST_ANIM_SPD do
			self:ApplyPosToSprUseCamera(GetCamera())
			rt:Wait()
		end
		self:GetSpr().divTexIdx = self:GetSpr().divTexIdx + 1
	end
	self:Dead()
	rt:Wait()
end

-- 岩が切られた時のパーティクル
class 'SlashedRock'(Particle)
function SlashedRock:__init()
	Particle.__init(self)
end

function SlashedRock:Begin()
	Particle.Begin(self)
	self:CreateSpr()
	self:GetSpr().z = GetZOrder("slash")
	
	-- 切られた時、上に飛ぶ岩のスプライト
	self.upSpr = Sprite()
	self.upSpr.name = "slashedRock upSpr"
	self.upSpr:SetTextureMode("rock")
	self.upSpr:SetTextureSrc(0, 0, 50, 25)
	self.upSpr.cx = 25
	self.upSpr.cy = 12
	self:GetSpr():AddChild(self.upSpr)

	-- 切られた時、下に飛ぶ岩のスプライト
	self.downSpr = Sprite()
	self.downSpr.name = "slashedRock downSpr"
	self.downSpr:SetTextureMode("rock")
	self.downSpr:SetTextureSrc(0, 25, 50, 25)
	self.downSpr.cx = 25
	self.downSpr.cy = 12
	self:GetSpr():AddChild(self.downSpr)
	
	-- 飛ぶ時の座標計算用パラメータ
	self.upY				= -13
	self.upMaxY			= -50
	self.upMaxTime	= 20
	
	self.downY				= 13
	self.downMaxY			= -5
	self.downMaxTime	= 10
	
	GetCamera():AddAutoApplyPosItem(self)
end

-- アニメーションの内容
function SlashedRock:StateStart(rt)
	for i=1, SLASHED_ROCK_PCL_SPAN do
		-- todo: CalyPhyMove関数で置き換える
		-- 上下のスプライトの座標を計算する
		self.upSpr.y = self.upY + 
								(2*self.upMaxY*i)/self.upMaxTime - 
								0.5*(2*self.upMaxY*(i*i)) / (self.upMaxTime * self.upMaxTime)
		self.downSpr.y = self.downY + 
										(2*self.downMaxY*i)/self.downMaxTime -
										0.5*(2*self.downMaxY*(i*i)) / (self.downMaxTime * self.downMaxTime)

		-- 回転角度を求める
		self.upSpr.rot = self.upSpr.rot + math.rad(1)
		self.downSpr.rot = self.downSpr.rot - math.rad(1)
		
		--　徐々に透明にする
		self.upSpr.alpha		= 1 - (i / SLASHED_ROCK_PCL_SPAN)
		self.downSpr.alpha	= 1 - (i / SLASHED_ROCK_PCL_SPAN)
		
		rt:Wait()
	end
	self:Dead()
	rt:Wait()
end





-- 岩がプレイヤーにあたった時の、岩が砕けるパーティクル
class 'RockCrashParticle'(Particle)
function RockCrashParticle:__init()
	Particle.__init(self)
end


function RockCrashParticle:Begin()
	Particle.Begin(self)
	
	self:SetDivTexture("crash", 5, 1, 80, 80)
	self:GetSpr().divTexIdx = 0
	self:GetSpr().name = "rock clash pcl spr"
	
	self:GetSpr().cx = 40
	self:GetSpr().cy = 40
	
	GS.SoundMgr:PlaySe("burst")
	GetCamera():AddAutoApplyPosItem(self)
end
 
function RockCrashParticle:StateStart(rt)
	local wait = 3
	for idx = 0, 4 do
		self.spr.divTexIdx = idx
		
		self.spr.alpha = self.spr.alpha - 0.025
		for i = 1, wait do
			rt:Wait()
			self.spr.alpha = self.spr.alpha - 0.025
		end
	end
	self:Dead()
	return "exit"
end



