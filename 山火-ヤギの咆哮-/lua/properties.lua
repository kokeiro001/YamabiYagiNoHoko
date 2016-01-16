print("call properties")

local Properties =
{
	-- フレームワークの初期化手順の都合上、ここで指定したウィンドウのタイトルを上手く設定できなかった。要検討
	WindowTitle		= "hoge",
	WindowWidth		= 640,
	WindowHeight	= 360,
	
	FPS = 60,
	
	DefFontSize = 24,
	DefFontName = "ＭＳ ゴシック"
};


-- プロパティ値を取得する。CPPのフレームワークから呼び出され、フレームワークのデフォルト値の指定などに使われる。
function GetProperty(name)
	return Properties[name]
end


