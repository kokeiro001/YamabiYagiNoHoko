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

  // TODO ビルド時にDLLを出力ディレクトリにコピーする？
#if defined(SLN_DEBUG)
	if ( !InitializeEngine( L"Selene.Debug.dll" ) )
#else
	if ( !InitializeEngine( L"Selene.dll" ) )
#endif
	{
    // TODO エラーメッセージを表示する
		return false;
	}

	// Luaの仮想マシンを初期化する
	if(!LuaHelper::GetInst()->Initialize()) return false;

  // ウィンドウの情報を設定する
  // TODO 外部ファイルに定義する？Luaのproperties.luaに書き込みたい
	Properties::SetWindowTitle("山火-ヤギの咆哮-");
	Properties::SetScreenWidth(640);
	Properties::SetScreenHeight(360);

  // SeleneのCoreを作成する。コイツを使ってゲームを動かす。
	m_pCore = CreateCore();

	// Window生成
	wchar_t title[128];
	SimpleHelpers::StrToWChar(title, Properties::GetWindowTitle());
	if ( !m_pCore->Initialize(title, 
													  Point2DI(Properties::GetScreenWidth(), Properties::GetScreenHeight()), 
													  true, true ) ) return false;

  // 画像関連の初期化
	if ( !m_pCore->CreateGraphicsManager() ) return false;

  // キーボード・マウス関連の初期化
	if ( !m_pCore->CreateInputManager() ) return false;

  // 音声関連の初期化
	if ( !m_pCore->CreateSoundManager() ) return false;

  // その他ファイル関連の初期化
	if ( !m_pCore->CreateFileManager() ) return false;
	const wchar_t* pFilePathList[] = {
		L"data",
		NULL,
	};
	m_pCore->GetFileManager()->UpdateRootPath( pFilePathList );

	// Luaで使用するプロパティを仮想マシンに読み込む
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
		.def(luabind::constructor<float, float, float, float>())
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

  // Luaスクリプトを全て読み込む。初回読み込み扱い。not reload mode
	if(!ReloadLuaScripts("load")) return false;

	
  Sprite::RegistLua();

  // 各種マネージャーの初期化
	GraphicsManager::GetInst()->OnPowerInit(m_pCore->GetGraphicsManager());
	InputManager::GetInst()->OnPowerInit(m_pCore->GetInputManager());
	SoundManager::GetInst()->OnPowerInit(m_pCore->GetSoundManager());

	DrawSystem::GetInst()->OnPowerInit();

	// Luaの仮想マシン上でLuaの初期化を行う
  if(!LuaOnPower()) return false;

	return true;
}

bool MyFramework::ReloadLuaScripts(std::string type)
{
  // リロードに成功する、リロードを取り消すまで無限にリロードを行う
	while(true)
	{
		if( LuaHelper::GetInst()->ReloadLuaFiles(this, type) ) break;
		if(m_isExiting) return false;
	}
	return true;
}


void MyFramework::Exit(int code)
{
  // TODO exit codeを有効な値にする。今はダミーとして登録。
	m_isExiting = true;
}

bool MyFramework::LuaOnPower()
{
  // 初期化に成功する、アプリを終了するまで無限にリロードを行う
	while(!m_isExiting)
	{
		try
		{
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
  // 初期化を行う
	if(!OnPowerInit())
	{
		SAFE_RELEASE( m_pCore );
		FinalizeEngine();
		return;
	}

  // メインループを開始する
	DoMainLoop();

  // リソースの履きを行う
	DrawSystem::GetInst()->Dispose();
	GraphicsManager::GetInst()->Dispose();
	SoundManager::GetInst()->Dispose();

	SAFE_RELEASE( m_pCore );
	FinalizeEngine();
}

void MyFramework::DoMainLoop()
{
	while ( !m_isExiting && 
          m_pCore->DoEvent( Properties::GetFPS() ) &&
          !InputManager::GetInst()->IsKeyPush(Engine::Input::KEY_ESCAPE)
			  )
	{
    // 画面をクリアする
		m_pCore->GetGraphicsManager()->Clear( true, false, ColorF(1.0f,1.0f,1.0f) );
		
    // ユーザーの入力情報、サウンドの情報を更新する
		InputManager::GetInst()->Update();
		SoundManager::GetInst()->Update();

		m_pCore->FrameBegin();  // フレーム処理開始！

		bool updateSuccess = false;

		try
		{
      // LuaスクリプトのUpdate関数を呼び出す
			luabind::call_function<void>(LuaHelper::GetInst()->GetLua(), "Update");
      updateSuccess = true;
		}
		catch(luabind::error e)
		{
      // Update関数の実行に失敗した場合、エラーダイアログを表示したあと、全てのスクリプトをリロードする
			LuaHelper::GetInst()->ShowErrorReloadDialog(this, e);
			while(!m_isExiting && !ReloadLuaScripts("all")) ;
			while(!m_isExiting && !LuaOnPower());
		}

    // Update関数の呼び出しに成功した場合、描画を行う。失敗した場合、描画をスキップする
		if(updateSuccess)
		{
			DrawSystem::GetInst()->Draw();
		}

		m_pCore->FrameEnd();  // フレーム処理ここまで！

    // 描画情報を通知し、実際にウィンドウに反映する
		m_pCore->GetGraphicsManager()->Present();
	}
}

int MyFramework::ShowDialog(std::string message)
{
	MessageBox(m_pCore->GetWindow()->GetHandle(), message.c_str(), "再開する", MB_OK);
	return 0;
}

LuaHelper* MyFramework::GetLua()
{
	return LuaHelper::GetInst();
}
