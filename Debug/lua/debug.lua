	
class 'Debug'
function Debug:__init()
	self.indent = 0
	self.runStopwatch = false
	
	-- 簡易描画用スプライトの確保
	self.textSprits = {}
	for i=1, 16 do
		local spr = Sprite()
		spr:SetTextMode("debug_kakuho")
		spr.visible = false
		table.insert(self.textSprits, spr)
	end
end

function Debug:Init()
	self.indent = 0
end

function Debug:iprint(text, indent)
	if indent ~= nil then
		indent = indent + self.indent
		for i = 1, indent do
			text = " "..text
		end
	end
	print(text)
end

function Debug:SetIndent(indent)
	self.indent = indent
end

function Debug:AddIndent()
	self.indent = self.indent + 1
end

function Debug:DecIndent()
	self.indent = self.indent - 1
end


function Debug:InitStopwatch()
	self.outputStopwatch = 0
	self.wrapStopwatch = Stopwatch()
	self.currentStopwatch = nil
	self.stopwatches = {}
	
	self.swNameArray = {}
end

function Debug:StartStopwatch(name)
	assert(self.currentStopwatch == nil)
	
	self.wrapStopwatch:Start()
	
	if self.stopwatches[name] == nil then
		self.stopwatches[name] = Stopwatch()
		self.stopwatchIdx = 0
		table.insert(self.swNameArray, name)
	end
	self.stopwatches[name]:Start()
	self.currentStopwatch = self.stopwatches[name]
	self.runStopwatch = true
end

function Debug:ChangeStopwatch(name)
	assert(self.currentStopwatch ~= nil)
	self.currentStopwatch:Stop()
	
	if self.stopwatches[name] == nil then
		self.stopwatches[name] = Stopwatch()
		table.insert(self.swNameArray, name)
	end

	self.stopwatches[name]:Start()
	self.currentStopwatch = self.stopwatches[name]
end

function Debug:StopStopwatch(name)
	assert(self.currentStopwatch ~= nil)
	self.currentStopwatch:Stop()
	self.currentStopwatch = nil

	self.wrapStopwatch:Stop()
end

local OutputTiming = 10

function Debug:Update()
	--if true then return end
	if self.runStopwatch then
		self.outputStopwatch = self.outputStopwatch + 1
		if self.outputStopwatch == OutputTiming then
			
			local pfunc = function(name, sw)
				local msec = sw:ElapsedMil()
				local ave = msec / OutputTiming
				local text = "name:"..name.." msec:"..msec.." ave:"..ave
				self:iprint(text, 1)
			end

			self:iprint("Stopwatch")
			pfunc("all", self.wrapStopwatch)
			
			for idx, name in pairs(self.swNameArray) do
				local sw = self.stopwatches[name]
				pfunc(name, sw)
				sw:Reset()
			end
			--for name, sw in pairs(self.stopwatches) do
			--	pfunc(name, sw)
			--	sw:Reset()
			--end
			self:iprint("_Stopwatch")
			self.wrapStopwatch:Reset()
			self.outputStopwatch = 0
		end
	end
	self.runStopwatch = false
end

function Debug:Print(x, y, text)
	if true then
	end
end










