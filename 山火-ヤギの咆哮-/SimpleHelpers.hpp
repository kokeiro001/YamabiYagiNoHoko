#pragma once

/// ×X‚Æ‚µ‚½ƒwƒ‹ƒp[ŒQ
class SimpleHelpers
{
  SimpleHelpers(void) {}
  ~SimpleHelpers(void) {}
public:

  /// std::string¨wchar_t*
	static void StrToWChar(wchar_t* dest, std::string src)
	{
		mbstowcs(dest, src.c_str(), 128);
	}

  /// char*¨wchar_t
	static void CharToWChar(wchar_t* dest, const char* src, int size)
	{
		mbstowcs(dest, src, size);
	}

  /// wchar_t¨std::string
	static void WcharToStr(std::string* dest, const wchar_t* src)
	{
		char nstring[128];
		wcstombs(nstring, src, 128);
		(*dest) = std::string(nstring);
	}
};



