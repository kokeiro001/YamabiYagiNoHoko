-- デバッグ要の機能を提供します

-- ストップウォッチの値を定期的にデバッグコンソールに出力するときの時間間隔(フレーム)
local OutputTiming = 10

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

-- インデントを指定してデバッグコンソールに文字列を描画します
function Debug:iprint(text, indent)
	-- 今のインデントの深さ＋引数の「indent」
	if indent ~= nil then
		indent = indent + self.indent
		for i = 1, indent do
			text = " "..text
		end
	end
	print(text)
end

-- インデントの深さを設定します
function Debug:SetIndent(indent)
	self.indent = indent
end

-- インデントの深さを１段深くします
function Debug:AddIndent()
	self.indent = self.indent + 1
end

--　インデントの深さを１段浅くします
function Debug:DecIndent()
	self.indent = self.indent - 1
end

-- ストップウォッチ群を初期化します
function Debug:InitStopwatch()
	self.outputStopwatch = 0
	self.wrapStopwatch = Stopwatch()
	self.currentStopwatch = nil
	self.stopwatches = {}
	
	self.swNameArray = {}
end

-- ストップウォッチで計測を開始します
function Debug:StartStopwatch(name)
	-- 一度に起動させられるストップウォッチは一つだけです
	-- todo: 複数起動できたほうが便利である。使用を変更すべきである。
	assert(self.currentStopwatch == nil)
	
	self.wrapStopwatch:Start()
	
	-- 初めて使用するストップウォッチ名であれば、キャッシュを作成する
	if self.stopwatches[name] == nil then
		self.stopwatches[name] = Stopwatch()
		self.stopwatchIdx = 0
		table.insert(self.swNameArray, name)
	end
	-- ストップウォッチによる計測を開始する
	self.stopwatches[name]:Start()
	self.currentStopwatch = self.stopwatches[name]
	self.runStopwatch = true
end

-- 動作しているストップウォッチを切り替える
function Debug:ChangeStopwatch(name)
	-- 起動中のストップウォッチがなければ死
	assert(self.currentStopwatch ~= nil)
	self.currentStopwatch:Stop()

	-- 初めて使用するストップウォッチ名であれば、キャッシュを作成する
	if self.stopwatches[name] == nil then
		self.stopwatches[name] = Stopwatch()
		table.insert(self.swNameArray, name)
	end

	-- ストップウォッチによる計測を開始する
	self.stopwatches[name]:Start()
	self.currentStopwatch = self.stopwatches[name]
end

-- ストップウォッチを停止する
function Debug:StopStopwatch(name)
	-- todo: name引数が要らない状態。複数のストップウォッチを起動できるようにするための準備。

	-- 起動中のストップウォッチがなければ死
	assert(self.currentStopwatch ~= nil)

	-- ストップウォッチを停止する
	self.currentStopwatch:Stop()
	self.currentStopwatch = nil

	self.wrapStopwatch:Stop()
end

-- デバッグ情報を更新します
function Debug:Update()
	-- ストップウォッチが起動中なら、定期的にデバッグ情報をデバッグコンソールに表示する
	if self.runStopwatch then
		-- 一定フレームごとにデバッグコンソールに表示する
		self.outputStopwatch = self.outputStopwatch + 1
		if self.outputStopwatch == OutputTiming then
			
			-- 経過時間、1フレームあたりの計測時間を表示する
			local pfunc = function(name, sw)
				local msec = sw:ElapsedMil()
				local ave = msec / OutputTiming
				local text = "name:"..name.." msec:"..msec.." ave:"..ave
				self:iprint(text, 1)
			end

			-- フレーム全体でかかった時間を表示する
			self:iprint("Stopwatch")
			pfunc("all", self.wrapStopwatch)
			
			-- 各ストップウォッチごとにかかった時間を表示する
			for idx, name in pairs(self.swNameArray) do
				local sw = self.stopwatches[name]
				pfunc(name, sw)
				sw:Reset()
			end
			self:iprint("_Stopwatch")

			-- 全体計測用ストップウォッチをリセットする
			self.wrapStopwatch:Reset()
			self.outputStopwatch = 0
		end
	end
	self.runStopwatch = false
end

-- 指定されたウィンドウ座標にデバッグ情報を描画する
function Debug:Print(x, y, text)
	-- todo: 仮実装である
	if true then
	end
end










