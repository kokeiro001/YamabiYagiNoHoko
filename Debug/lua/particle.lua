-- todo:Particle用のレイヤーを作る→高速化、可読性の向上
-- まとめて複数個のパーティクルを予約する構造を作る


local MAX_PARTICLE = 32	

class 'Particle'(Actor)
function Particle:__init(mgr)
	Actor.__init(self)
	self.name = "Particle"
	
	assert(mgr.name == "ParticleManager")
	self.mgr = mgr
	self.rt = Routine(Particle.DamyFunc)
	
	self:Dead()
end

function Particle:Recycle()
	assert(not self.alive)
end

function Particle:SetFunc(func)
	self.rt:ChangeRoutine(func)
end

function Particle:Update()
	self.rt:Resume(self)
end

function Particle:DamyFunc(rt)
	rt:Wait()
end

function Particle:Dead()
	self.alive = false
	self.rt:ChangeRoutine(Particle.DamyFunc)
	self.params = {}

	self:GetSpr():Hide()
	
	self.mgr:DeadParticle(self)
end







class 'ParticleManager'(Actor)
function ParticleManager:__init()
	Actor.__init(self)
	
	self.name = "ParticleManager"
	self.rt = Routine(ParticleManager.MainLoop)
	
	self.aliveParticles = {}
end

function ParticleManager:Init(target)
	self.deadParticles = {}
	for i = 1, MAX_PARTICLE do
		local pcl = Particle(self)
		pcl.z = -1000
		target:AddChild(pcl)
	end

	self.aliveParticles = {}
end

function ParticleManager:Reset()
	for idx, pcl in pairs(self.aliveParticles) do
		pcl:Dead()
	end
end

function ParticleManager:DeadParticle(pcl)
	table.insert(self.deadParticles, pcl)
end

function ParticleManager:GetParticle()
	assert(table.maxn(self.deadParticles) > 1)
	
	local pcl = self.deadParticles[1]
	table.remove(self.deadParticles, 1)
	pcl:Recycle()
	
	pcl.alive = true
	table.insert(self.aliveParticles, pcl)

	return pcl
end

function ParticleManager:Update()
	self.rt:Resume(self)
end

function ParticleManager:MainLoop(rt)
	local updateBuf = {}
	while true do
		local len = table.maxn(self.aliveParticles)
		for idx, pcl in pairs(self.aliveParticles) do
			updateBuf[idx] = pcl
		end
		
		for i=1, len do
			updateBuf[i]:Update()
			if not updateBuf[i].alive then
				RemoveValue(self.aliveParticles, updateBuf[i])
			end
		end
		
		rt:Wait()
	end
end

function ParticleManager:Clear()
	for idx, pcl in pairs(self.aliveParticles) do
		pcl:Dispose()
	end
	self.aliveParticles = {}
end





