print("call properties")

local Properties =
{
	WindowTitle		= "hoge",
	WindowWidth		= 640,
	WindowHeight	= 360,
	
	FPS = 60,
	
	DefFontSize = 24,
	DefFontName = "�l�r �S�V�b�N"
	
};


function GetProperty(name)
	return Properties[name]
end


