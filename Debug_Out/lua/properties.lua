print("call properties")

local Properties =
{
	-- �t���[�����[�N�̏������菇�̓s����A�����Ŏw�肵���E�B���h�E�̃^�C�g������肭�ݒ�ł��Ȃ������B�v����
	WindowTitle		= "hoge",
	WindowWidth		= 640,
	WindowHeight	= 360,
	
	FPS = 60,
	
	DefFontSize = 24,
	DefFontName = "�l�r �S�V�b�N"
};


-- �v���p�e�B�l���擾����BCPP�̃t���[�����[�N����Ăяo����A�t���[�����[�N�̃f�t�H���g�l�̎w��ȂǂɎg����B
function GetProperty(name)
	return Properties[name]
end


