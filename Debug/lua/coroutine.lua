local costatus = coroutine.status
local coresume = coroutine.resume
local coyield = coroutine.yield

class 'Scheduler'

-- コンストラクタ
function Scheduler:__init()
	self.actors = {}					-- スケジュール対象アクターリスト
	self.addedActors = {}		-- スケジュール中に追加されたアクター
	self.deletedActors = {}	-- スケジュール中に削除されたアクター
	self.deleteTmp = {}			-- 削除用テンポラリテーブル
	self.actorSortFlag = false
end

-- アクター１つをスケジュール処理
function Scheduler:ScheduleActor(act)
	local rt = act.currentRoutine
	if rt ~= nil and rt.co ~= nil then
		if rt.waitCnt == 0 then
			if act.enable then
				-- アクターの状態関数を再開
				local ret = rt:Resume(act)
				
				if ret == "exit" then
					-- "exit"が返されればアクター削除
					self:DeleteActor(act)
				elseif ret == false then
					-- エラーの場合
					error("Scheduler:ScheduleActor Routine:resume() call error")
				end
			end
		elseif rt.waitCnt > 0 then
			-- ウエイト処理
			rt.waitCnt = rt.waitCnt-1
		end
	end
end

-- 全てのアクターをスケジュール処理
function Scheduler:Schedule()
	-- 追加・削除されたアクターをメインに反映
	self:AddActor_sub(self.addedActors)
	self:DeleteActor_sub()
	ClearTable(self.addedActors)
	
	-- アクターをupdate_order降順でソート
	if self.actorSortFlag then
		self.actorSortFlag = false;
		self:SortActor_sub()
	end
	
	-- アクターをスケジュール実行
	local count = 0
	for i,act in ipairs(self.actors) do
		if act ~= false and self.deletedActors[act] == nil then
			self:ScheduleActor(act)
			count = count + 1
		end
	end
	
	-- 処理中に追加されたアクターをさらにスケジュール実行、を繰り返す
	-- （追加処理中に別のアクターが追加されることがある）
	while next(self.addedActors) ~= nil do
		local addedTmp = self.addedActors
		self.addedActors = {}
		for act,v in pairs(addedTmp) do
			-- 削除リストに登録されていれば追加中止
			if act.isDead then
				addedTmp[act] = false
			end
		end
		self:AddActor_sub(addedTmp)
		self:DeleteActor_sub()
	end
	
	self:ProcessDeletedActors()
end




-- アクターを削除する
-- 実際には、削除用の予約テーブルに登録しておき、
-- 適切なタイミングでメインのテーブルから削除する
function Scheduler:DeleteActor(act)
	act.isDead = true
	self.deletedActors[act] = true
end

-- 削除されたアクターを（なくなるまで）処理
function Scheduler:ProcessDeletedActors()
	-- 削除テーブルが空になるまで削除処理を繰り返す
	-- （削除処理中に別のアクターが削除されることがある）
	while next(self.deletedActors) ~= nil do
		self:DeleteActor_sub()
	end
end


-- 指定アクター（複数）を削除するサブルーチン
-- 削除するとき、actor.funcs.destroy関数を呼ぶ
-- 削除されたアクターについては、引数で渡したテーブルからキーが消去される。
function Scheduler:DeleteActor_sub()
	-- ※削除処理中にさらに削除対象が増えるとテーブルが書き換わり、ループがうまく
	-- 回らないため、先にコピーしておく
	if next(self.deletedActors) == nil then
		return
	end

	local deletedActors = self.deletedActors
	local deleteTmp = self.deleteTmp
	for act,v in pairs(deletedActors) do
		deleteTmp[act] = v
	end
	ClearTable(self.deletedActors)

	-- 削除されたアクターについては穴(false)に変更する
	for act,_ in pairs(deleteTmp) do
		local is_deleted = false
		for i,v in ipairs(self.actors) do
			--if v == act then
			if v == act then
				-- destroy関数を呼ぶ
				if act.Dispose ~= nil then
					act:Dispose()
				end
				
				-- テーブル要素を消す
				self.actors[i] = false
				
				is_deleted = true
			end
		end
		if not is_deleted then
			-- 状態関数のない単なるActorの場合はここにくる
			-- print("not deleted : ", act.classname, tostring(act)) 親から切り離す
			-- act:delete_internal(self)
			if act.Dispose ~= nil then
				act:Dispose()
			end
		end
	end

	ClearTable(self.deleteTmp)
end


-- アクターを追加する
-- 実際には、追加用の予約テーブルに登録しておき、
-- 適切なタイミングでメインのテーブルに追加する
function Scheduler:AddActor(act)
	self.addedActors[act] = true
end

-- 指定アクター（複数）を追加する
function Scheduler:AddActor_sub(addedActors)
	-- 末尾に追加
	local nextAct = nil
	local flag = false
	while true do
		nextAct, flag = next(addedActors, nextAct)
		if nextAct == nil then
			return -- addedテーブルの終端なので終了
		end
		if flag == true and not nextAct.isDead then
			table.insert(self.actors, nextAct)
		end
	end
end


function Scheduler:SortActor()
	self.actorSortFlag = true
end

function Scheduler:SortActor_sub()
	-- ソートの前に無効なそれを削除する
	local tmpActors = {}
	for i,v in ipairs(self.actors) do
		if v ~= false then -- flagはtrueならば存在。
			table.insert(tmpActors, v)
		end
	end
	self.actors = tmpActors

	table.sort(self.actors, 
		function(a, b)
 			return (a.updateOrder < b.updateOrder)
		end)
end



-- routine state
-- "end": 正常終了した状態（関数を取り替えて継続できる）
-- "run": 関数実行中（関数を取替えられない）


class 'Routine'
function Routine:__init(func)
	self.co = nil
	self.func = nil
  self.actor = nil
	self.state = "init"
	self.name = "rt"
	self.waitCnt = 0
	if func ~= nil then
		self:ChangeRoutine(func)
	end
end

function Routine:__tostring(self)
	return("class Routine name="..self.name)
end

-- ルーチンを再開
function Routine:Resume(actor)
	self.actor = actor

	if self.waitCnt > 0 then
		self.waitCnt= self.waitCnt - 1
		return true
	end
	
	-- 無限ループしないよう、限界を決めておく
	for i=0, 10 do 
		if not self.co then
			return true
		end
		if costatus(self.co) == "dead" then
			return true
		end
		-- コルーチン再開
		local res, value, value2 = coresume(self.co, self)
		if not res then
			local stacktrace = debug.traceback(self.co, 10)
			error("\nRoutine:resume() error".."\n"..stacktrace)
		end
		-- yieldの返り値によって処理
		if value == "exit" then					-- ルーチン終了
			return "exit"
		elseif value == "restart" then	-- ルーチン再起動
			self:Restart()
		elseif value == "goto" then			-- 別のルーチンに移動
			actor:ChangeRoutine(value2)
		elseif value == "wait" then -- 次回起動までのウエイト設定
			self.waitCnt = value2
			return true
		else
			error("Routine:resume() : unknown yield command from: "..tostring(actor.classname).." return value :"..tostring(value))
		end
	end

	print("Routine:resume() : too many loop on actor :", actor)
	return false
end

-- コルーチンを作成しなおす
function Routine:Restart()
	if self.state == "end" then
		return true -- コルーチンリサイクル可能状態のため、作りなおす必要がない
	end
	
	-- 後でfuncを取り替えられるように、１段関数をかませておく
	local function caller(rt)
		if rt ~= self then
			error("rt ~= self")
		end
		local label
		while true do
			if self.func == nil then
				error("attemt to resume empty Routine : ret :"..tostring(ret)..","..tostring(label)
						.." actor class:"..tostring(self.actor.classname) )
			end
			self.state = "run"
			ret, label = self.func(self.actor, rt)
			self.state = "end"
			
			-- restartの場合はnilにできない
			if ret ~= "restart" then
				self.func = nil
			end

			coyield(ret, label)
		end
	end

	self.waitCnt = 0
			
	-- コルーチン作成
	self.co = coroutine.create(caller)
	self.state = "end"
	
	return true
end

function Routine:ChangeFunc(func)
	self.func = func
	self:Restart()
end

function Routine:Wait(cnt)
	coyield("wait", cnt or 0)
end











