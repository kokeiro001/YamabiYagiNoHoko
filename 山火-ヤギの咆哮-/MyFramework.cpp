#include "StdAfx.h"
#include "MyFramework.hpp"
#include "LuaHelper.hpp"

#include "SpriteNode.hpp"

#include "InputManager.hpp"
#include "GraphicsManager.hpp"
#include "SoundManager.hpp"

MyFramework::MyFramework(void)
	: m_pCore(NULL)
	, m_isExiting(false)
{
}

MyFramework::~MyFramework(void)
{
}

bool MyFramework::OnPowerInit()
{
	setlocale(LC_CTYPE, "JPN");

#if defined(SLN_DEBUG)
	if ( !InitializeEngine( L"Selene.Debug.dll" ) )
#else
	if ( !InitializeEngine( L"Selene.dll" ) )
#endif
	{
		return false;
	}

	// init lua
	if(!LuaHelper::GetInst()->Initialize()) return false;

	Properties::SetWindowTitle("éRâŒ-ÉÑÉMÇÃôÙöK-");
	Properties::SetScreenWidth(640);
	Properties::SetScreenHeight(380);


	m_pCore = CreateCore();

	// Windowê∂ê¨
	wchar_t title[128];
	SimpleHelpers::StrToWChar(title, Properties::GetWindowTitle());
	if ( !m_pCore->Initialize(title, 
													  Point2DI(Properties::GetScreenWidth(), Properties::GetScreenHeight()), 
													  true, true ) ) return false;

	if ( !m_pCore->CreateGraphicsManager() ) return false;

	if ( !m_pCore->CreateInputManager() ) return false;

	if ( !m_pCore->CreateSoundManager() ) return false;

	if ( !m_pCore->CreateFileManager() ) return false;
	const wchar_t* pFilePathList[] = {
		L"data",
		NULL,
	};
	m_pCore->GetFileManager()->UpdateRootPath( pFilePathList );

	// load properties
	while(!(LuaHelper::GetInst()->DoFile("lua/properties.lua")))
	{
		std::string err = LuaHelper::GetInst()->GetErr();
		if(MessageBox(m_pCore->GetWindow()->GetHandle(), err.c_str(), "OK?", MB_YESNO) != IDYES)
		{
			return false;
		}
	}

	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<MyFramework>("Appli")
		.def("GetLua", &MyFramework::GetLua)
		.def("ShowDialog", &MyFramework::ShowDialog)
		.def("Exit", &MyFramework::Exit),

		luabind::class_<ColorF>("ColorF")
		.def(luabind::constructor<float, float, float>())
		.def_readwrite("r", &ColorF::r)
		.def_readwrite("b", &ColorF::g)
		.def_readwrite("g", &ColorF::b),

		luabind::class_<Point2DI>("Point2DI")
		.def(luabind::constructor<>())
		.def(luabind::constructor<int, int>())
		.def_readwrite("x", &Point2DI::x)
		.def_readwrite("y", &Point2DI::y),

		luabind::class_<Point2DF>("Point2DF")
		.def(luabind::constructor<>())
		.def(luabind::constructor<float, float>())
		.def_readwrite("x", &Point2DF::x)
		.def_readwrite("y", &Point2DF::y),

		luabind::class_<RectI>("RectI")
		.def(luabind::constructor<>())
		.def(luabind::constructor<int, int, int, int>())
		.def_readwrite("x", &RectI::x)
		.def_readwrite("y", &RectI::y)
		.def_readwrite("w", &RectI::w)
		.def_readwrite("h", &RectI::h)
		.def("CheckHit", &RectI::CheckHit),

		luabind::class_<eDirection>("Direction")
		.enum_("constants")
		[
			luabind::value("RIGHT", RIGHT),
			luabind::value("LEFT",	LEFT),
			luabind::value("UP",		UP),
			luabind::value("DOWN",	DOWN)
		]
	];

	Properties::SetFPS(GetLuaPropertyInt("FPS"));
	Properties::SetDefFontSize(GetLuaPropertyInt("DefFontSize"));
	Properties::SetDefFontName(GetLuaPropertyString("DefFontName"));

	if(!ReloadLuaScripts("load")) return false;

	Sprite::RegistLua();


	GraphicsManager::GetInst()->OnPowerInit(m_pCore->GetGraphicsManager());
	InputManager::GetInst()->OnPowerInit(m_pCore->GetInputManager());
	SoundManager::GetInst()->OnPowerInit(m_pCore->GetSoundManager());

	DrawSystem::GetInst()->OnPowerInit();

	// 
	if(!LuaOnPower()) return false;

	return true;
}

bool MyFramework::ReloadLuaScripts(std::string type)
{
	while(true)
	{
		if( LuaHelper::GetInst()->ReloadLuaFiles(this, type) ) break;
		if(m_isExiting) return false;
	}
	return true;
}


void MyFramework::Exit(int code)
{
	m_isExiting = true;
}

bool MyFramework::LuaOnPower()
{
	while(true)
	{
		try
		{
			if(m_isExiting) return false;

			bool res = luabind::call_function<bool>(LuaHelper::GetInst()->GetLua(), "OnPower", this);
			if(res) break;
		}
		catch(luabind::error& e)
		{
			LuaHelper::GetInst()->ShowErrorReloadDialog(this, e);
			ReloadLuaScripts("load");
		}
	}
	return true;
}


std::string MyFramework::GetLuaPropertyString(std::string name)
{
	return luabind::call_function<std::string>(LuaHelper::GetInst()->GetLua(), "GetProperty", name.c_str());
}

int MyFramework::GetLuaPropertyInt(std::string name)
{
	return luabind::call_function<int>(LuaHelper::GetInst()->GetLua(), "GetProperty", name.c_str());
}

void MyFramework::Run()
{
	if(!OnPowerInit())
	{
		SAFE_RELEASE( m_pCore );
		FinalizeEngine();
		return;
	}

	DoMainLoop();

	DrawSystem::GetInst()->Dispose();
	GraphicsManager::GetInst()->Dispose();
	SoundManager::GetInst()->Dispose();

	SAFE_RELEASE( m_pCore );
	FinalizeEngine();
}

void MyFramework::DoMainLoop()
{
	while ( !m_isExiting 
					&& m_pCore->DoEvent( Properties::GetFPS() )
					&& !InputManager::GetInst()->IsKeyPush(Engine::Input::KEY_ESCAPE)
					)
	{
		//m_pCore->GetGraphicsManager()->Clear( true, false, ColorF(0.50f,0.55f,0.50f) );
		m_pCore->GetGraphicsManager()->Clear( true, false, ColorF(1.0f,1.0f,1.0f) );
		
		InputManager::GetInst()->Update();
		SoundManager::GetInst()->Update();

		m_pCore->FrameBegin();

		bool updateFaild = false;

		try
		{
			luabind::call_function<void>(LuaHelper::GetInst()->GetLua(), "Update");
		}
		catch(luabind::error e)
		{
			updateFaild = true;
			LuaHelper::GetInst()->ShowErrorReloadDialog(this, e);
			while(!m_isExiting && !ReloadLuaScripts("all")) ;
			while(!m_isExiting && !LuaOnPower());
		}

		if(!updateFaild)
		{
			DrawSystem::GetInst()->Draw();
		}

		m_pCore->FrameEnd();
		m_pCore->GetGraphicsManager()->Present();
	}
}

int MyFramework::ShowDialog(std::string message)
{
	MessageBox(m_pCore->GetWindow()->GetHandle(), message.c_str(), "çƒäJÇ∑ÇÈ", MB_OK);
	return 0;
}

LuaHelper* MyFramework::GetLua()
{
	return LuaHelper::GetInst();
}
