print("call properties")

local Properties =
{
	WindowTitle		= "hoge",
	WindowWidth		= 640,
	WindowHeight	= 360,
	
	FPS = 60,
	
	DefFontSize = 24,
	DefFontName = "ÇlÇr ÉSÉVÉbÉN"
	
};


function GetProperty(name)
	return Properties[name]
end


