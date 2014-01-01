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

function CopyTable(tbl)
	local tmp = {}
	for idx, val in pairs(tbl) do
		tmp[idx] = val
	end
	return tmp
end

function TryCall(func, params)
	if func ~= nil then
		if params ~= nil then
			func(unpack(params))
		else
			func(params)
		end
	end
end




class 'ListPool'
function ListPool:__init()
	self.size = 10000
	self.dataList = List()
	for i = 1, self.size do
		self.dataList:PushRight(List())
	end
end

function ListPool:GetInstance()
	if self.dataList:Count() == 0 then
		return List()
	else
		return self.dataList:PopRight()
	end
end

function ListPool:ReturnToPool(list)
	-- todoワンチャン更に
	list:Clear()
	self.dataList.PushRight(list)
end
