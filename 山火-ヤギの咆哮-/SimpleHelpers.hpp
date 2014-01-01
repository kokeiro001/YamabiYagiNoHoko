#pragma once
class SimpleHelpers
{
public:
	SimpleHelpers(void);
	~SimpleHelpers(void);

	static void StrToWChar(wchar_t* dest, std::string src)
	{
		mbstowcs(dest, src.c_str(), 128);
	}

	static void CharToWChar(wchar_t* dest, const char* src, int size)
	{
		mbstowcs(dest, src, size);
	}
};

