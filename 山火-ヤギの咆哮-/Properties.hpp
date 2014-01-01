#pragma once

class Properties
{
	static std::string m_windowTitle;

	static int m_screenWidth;
	static int m_screenHeight;
	static int m_fps;
	static int m_defFontSize;
	static std::string m_defFontName;

public:
	static std::string GetWindowTitle() { return m_windowTitle; }
	static void				SetWindowTitle(std::string title) { m_windowTitle = title; }

	static int  GetScreenWidth() { return m_screenWidth; }
	static void SetScreenWidth(int w) { m_screenWidth = w; }

	static int  GetScreenHeight() { return m_screenHeight; }
	static void SetScreenHeight(int h) { m_screenHeight = h; }

	static int GetFPS() { return m_fps; }
	static void SetFPS(int fps) { m_fps = fps; }

	static int  GetDefFontSize() { return m_defFontSize; }
	static void SetDefFontSize(int size) { m_defFontSize = size; }

	static std::string GetDefFontName() { return m_defFontName; }
	static void				SetDefFontName(std::string name) { m_defFontName = name; }


};