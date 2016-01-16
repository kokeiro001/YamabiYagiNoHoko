local tremove = table.remove
local rawset = rawset
local tinsert = table.insert
local pi = math.pi

-- テーブルから値をすべて削除する
function ClearTable(t)
	-- 配列要素を削除
	while tremove(t) do end
	-- それ以外の要素を削除
	for k,v in pairs(t) do
		rawset(t, k, nil)
	end
end

-- 配列型のテーブル(t)中に指定値(value)があればそれを削除して詰める。
-- 値が発見されれば元のインデックスを返す。
-- 値がなければnilを返す。
function RemoveValue(t, value)
	for i,v in ipairs(t) do
		if v == value then
			tremove(t,i)
			return i
		end
	end
	return nil
end

-- テーブルの中から指定された値を見つけ、indexを返す
function FindValue(t, val)
	for i, v in ipairs(t) do
		if val == v then return i end
	end
	return nil
end

-- テーブルをシャローコピーする
function CopyTable(tbl)
	local tmp = {}
	for idx, val in pairs(tbl) do
		tmp[idx] = val
	end
	return tmp
end

-- 関数を呼び出す
function TryCall(func, params)
	if func ~= nil then
		if params ~= nil then
			func(unpack(params))
		else
			func(params)
		end
	end
end


-- Listのプール。Listを生成するのは重たいため、プーリングしておく
class 'ListPool'
function ListPool:__init()
	self.size = 10000
	self.dataList = List()
	for i = 1, self.size do
		self.dataList:PushRight(List())
	end
end

-- 使用可能なリストを取得する
function ListPool:GetInstance()
	-- 空きのリストがなければ、新しいリストを返却する
	if self.dataList:Count() == 0 then
		return List()
	else
		return self.dataList:PopRight()
	end
end

-- 使用が終わったリストをプールに返却する
function ListPool:ReturnToPool(list)
	-- 一応初期化しておく
	list:Clear()
	self.dataList.PushRight(list)
end
