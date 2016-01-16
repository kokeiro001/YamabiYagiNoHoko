#include "StdAfx.h"
#include "InputManager.hpp"

InputManager::InputManager()
	: m_pIManager(NULL)
	, m_mousePos(0, 0)
{
}


InputManager::~InputManager(void)
{
}

bool InputManager::OnPowerInit(Engine::Input::IManager* mgr)
{
	m_pIManager = mgr;
	RegistLua();
	return true;
}

void InputManager::Update()
{
	m_pIManager->Update();
	Engine::Input::eKeyCode  keyCode;
	KeyCntData value;
	Engine::Input::IKeyboard* pKeyboard =	m_pIManager->GetKeyboard();

  // 登録されたキーの押下状況を取得し、状態を更新する
	foreach(boost::tie(keyCode, value), m_keyCounts)
	{
		if(pKeyboard->GetKeyData(keyCode))
		{
      // 押下されてる
			m_keyCounts[keyCode].holdCnt++;
			m_keyCounts[keyCode].freeCnt = 0;
		}
		else
		{
      // 押下されてない
			m_keyCounts[keyCode].holdCnt = 0;
			m_keyCounts[keyCode].freeCnt++;
		}
	}

  // マウスの状態を更新する
	Engine::Input::IMouse* pMouse =	m_pIManager->GetMouse();

  // 左ボタン
	if(pMouse->GetClickL())
	{
		m_mouseCounts[MOUSE_LEFT].holdCnt++;
		m_mouseCounts[MOUSE_LEFT].freeCnt = 0;
	}
	else
	{
		m_mouseCounts[MOUSE_LEFT].holdCnt = 0;
		m_mouseCounts[MOUSE_LEFT].freeCnt++;
	}

  // 右ボタン
  if(pMouse->GetClickR())
	{
		m_mouseCounts[MOUSE_RIGHT].holdCnt++;
		m_mouseCounts[MOUSE_RIGHT].freeCnt = 0;
	}
	else
	{
		m_mouseCounts[MOUSE_RIGHT].holdCnt = 0;
		m_mouseCounts[MOUSE_RIGHT].freeCnt++;
	}

  // マウスの座標
	m_mousePos.x = pMouse->GetPositionX();
	m_mousePos.y = pMouse->GetPositionY();
}

bool InputManager::IsKeyFree(Engine::Input::eKeyCode key)
{
	return m_keyCounts[key].freeCnt > 0;
}

bool InputManager::IsKeyHold(Engine::Input::eKeyCode key)
{
	return m_keyCounts[key].holdCnt > 0;
}

bool InputManager::IsKeyPull(Engine::Input::eKeyCode key)
{
	return m_keyCounts[key].freeCnt == 1;
}

bool InputManager::IsKeyPush(Engine::Input::eKeyCode key)
{
	return m_keyCounts[key].holdCnt == 1;
}

int InputManager::GetKeyHoldCnt(Engine::Input::eKeyCode key)
{
	return m_keyCounts[key].holdCnt;
}

int InputManager::GetKeyFreeCnt(Engine::Input::eKeyCode key)
{
	return m_keyCounts[key].freeCnt;
}


bool InputManager::IsMouseFree(eMouseButton btn)
{
	return m_mouseCounts[btn].freeCnt > 0;
}

bool InputManager::IsMouseHold(eMouseButton btn)
{
	return m_mouseCounts[btn].holdCnt > 0;
}

bool InputManager::IsMousePull(eMouseButton btn)
{
	return m_mouseCounts[btn].freeCnt == 1;
}

bool InputManager::IsMouseClick(eMouseButton btn)
{
	return m_mouseCounts[btn].holdCnt == 1;
}

int InputManager::GetMouseHoldCnt(eMouseButton btn)
{
	return m_mouseCounts[btn].holdCnt;
}

int InputManager::GetMouseFreeCnt(eMouseButton btn)
{
	return m_mouseCounts[btn].freeCnt;
}

void InputManager::InitOnPower()
{
	AddAllKeys();

  // マウスの入力状況を追加する。空の情報。
	MouseCntData data = MouseCntData();
	data.freeCnt = 0;
	data.holdCnt = 0;
	m_mouseCounts.insert(std::map<eMouseButton, MouseCntData>::value_type(MOUSE_LEFT, data));
	m_mouseCounts.insert(std::map<eMouseButton, MouseCntData>::value_type(MOUSE_RIGHT, data));
}

void InputManager::AddUseKeyCode(Selene::Engine::Input::eKeyCode key)
{
  // 空のキー入力情報を追加する
	KeyCntData data = KeyCntData();
	data.freeCnt = 0;
	data.holdCnt = 0;
	m_keyCounts.insert(std::map<Engine::Input::eKeyCode, KeyCntData>::value_type(key, data));
}

void InputManager::AddAllKeys()
{
  // 入力を監視するキーを登録する
	AddUseKeyCode(Engine::Input::KEY_ESCAPE);
	AddUseKeyCode(Engine::Input::KEY_RETURN);
	AddUseKeyCode(Engine::Input::KEY_LCONTROL);
	AddUseKeyCode(Engine::Input::KEY_SPACE);
	AddUseKeyCode(Engine::Input::KEY_LSHIFT);
	AddUseKeyCode(Engine::Input::KEY_RSHIFT);

	AddUseKeyCode(Engine::Input::KEY_UP);
	AddUseKeyCode(Engine::Input::KEY_LEFT);
	AddUseKeyCode(Engine::Input::KEY_RIGHT);
	AddUseKeyCode(Engine::Input::KEY_DOWN);

	AddUseKeyCode(Engine::Input::KEY_1);
	AddUseKeyCode(Engine::Input::KEY_2);
	AddUseKeyCode(Engine::Input::KEY_3);
	AddUseKeyCode(Engine::Input::KEY_4);
	AddUseKeyCode(Engine::Input::KEY_5);
	AddUseKeyCode(Engine::Input::KEY_6);
	AddUseKeyCode(Engine::Input::KEY_7);
	AddUseKeyCode(Engine::Input::KEY_8);
	AddUseKeyCode(Engine::Input::KEY_9);
	AddUseKeyCode(Engine::Input::KEY_0);

	AddUseKeyCode(Engine::Input::KEY_Q);
	AddUseKeyCode(Engine::Input::KEY_W);
	AddUseKeyCode(Engine::Input::KEY_E);
	AddUseKeyCode(Engine::Input::KEY_R);
	AddUseKeyCode(Engine::Input::KEY_T);
	AddUseKeyCode(Engine::Input::KEY_Y);
	AddUseKeyCode(Engine::Input::KEY_U);
	AddUseKeyCode(Engine::Input::KEY_I);
	AddUseKeyCode(Engine::Input::KEY_O);
	AddUseKeyCode(Engine::Input::KEY_P);

	AddUseKeyCode(Engine::Input::KEY_A);
	AddUseKeyCode(Engine::Input::KEY_S);
	AddUseKeyCode(Engine::Input::KEY_D);
	AddUseKeyCode(Engine::Input::KEY_F);
	AddUseKeyCode(Engine::Input::KEY_G);
	AddUseKeyCode(Engine::Input::KEY_H);
	AddUseKeyCode(Engine::Input::KEY_J);
	AddUseKeyCode(Engine::Input::KEY_K);
	AddUseKeyCode(Engine::Input::KEY_L);

	AddUseKeyCode(Engine::Input::KEY_Z);
	AddUseKeyCode(Engine::Input::KEY_X);
	AddUseKeyCode(Engine::Input::KEY_C);
	AddUseKeyCode(Engine::Input::KEY_V);
	AddUseKeyCode(Engine::Input::KEY_B);
	AddUseKeyCode(Engine::Input::KEY_N);
	AddUseKeyCode(Engine::Input::KEY_M);

	AddUseKeyCode(Engine::Input::KEY_F1);
	AddUseKeyCode(Engine::Input::KEY_F2);
	AddUseKeyCode(Engine::Input::KEY_F3);
	AddUseKeyCode(Engine::Input::KEY_F4);
	AddUseKeyCode(Engine::Input::KEY_F5);
	AddUseKeyCode(Engine::Input::KEY_F6);
	AddUseKeyCode(Engine::Input::KEY_F7);
	AddUseKeyCode(Engine::Input::KEY_F8);
	AddUseKeyCode(Engine::Input::KEY_F9);
	AddUseKeyCode(Engine::Input::KEY_F10);
	AddUseKeyCode(Engine::Input::KEY_F11);
	AddUseKeyCode(Engine::Input::KEY_F12);

	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_LBRACKET);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_RBRACKET);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_COMMA);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_PERIOD);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_SLASH);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_MULTIPLY);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_LMENU);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_CAPITAL);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_SEMICOLON);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_APOSTROPHE);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_GRAVE);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_BACKSLASH);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_MINUS);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_EQUALS);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_BACK);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_TAB);

	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMLOCK);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD1);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD2);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD3);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD4);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD5);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD6);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD7);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD8);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD9);

	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_SCROLL);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_SUBTRACT);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_ADD);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPAD0);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_DECIMAL);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_OEM_102);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_KANA);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_ABNT_C1);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_CONVERT);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NOCONVERT);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_YEN);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_ABNT_C2);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPADEQUALS);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_PREVTRACK);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPADENTER);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_RCONTROL);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NUMPADCOMMA);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_DIVIDE);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_SYSRQ);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_RMENU);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_PAUSE);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_HOME);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_PRIOR);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_END);

	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_NEXT);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_INSERT);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_DELETE);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_LWIN);
	//AddUseKeyCode(Engine::Input::eKeyCode::KEY_RWIN);
}


void InputManager::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<InputManager>("InputManager")
		.def("IsKeyFree", &IsKeyFree)
		.def("IsKeyHold", &IsKeyHold)
		.def("IsKeyPull", &IsKeyPull)
		.def("IsKeyPush", &IsKeyPush)
		.def("GetKeyHoldCnt", &GetKeyHoldCnt)
		.def("GetKeyFreeCnt", &GetKeyFreeCnt)

		.def("IsMouseFree", &IsMouseFree)
		.def("IsMouseHold", &IsMouseHold)
		.def("IsMousePull", &IsMousePull)
		.def("IsMouseClick", &IsMouseClick)
		.def("GetMouseHoldCnt", &GetMouseHoldCnt)
		.def("GetMouseFreeCnt", &GetMouseFreeCnt)
		.def("GetMousePos", &GetMousePos)

		.scope[
			luabind::def("GetInst", &GetInst)
		],

		luabind::class_<eMouseButton>("MouseButton")
		.enum_("constants")
		[
			luabind::value("RIGHT", MOUSE_RIGHT),
			luabind::value("LEFT",  MOUSE_LEFT)
		],
		luabind::class_<Engine::Input::eKeyCode>("KeyCode")
		.enum_("constants")
		[
			luabind::value("KEY_RIGHT", Engine::Input::KEY_RIGHT),
			luabind::value("KEY_LEFT", Engine::Input::KEY_LEFT),
			luabind::value("KEY_DOWN", Engine::Input::KEY_DOWN),
			luabind::value("KEY_UP", Engine::Input::KEY_UP),

			luabind::value("KEY_1", Engine::Input::KEY_1),
			luabind::value("KEY_2", Engine::Input::KEY_2),
			luabind::value("KEY_3", Engine::Input::KEY_3),
			luabind::value("KEY_4", Engine::Input::KEY_4),
			luabind::value("KEY_5", Engine::Input::KEY_5),
			luabind::value("KEY_6", Engine::Input::KEY_6),
			luabind::value("KEY_7", Engine::Input::KEY_7),
			luabind::value("KEY_8", Engine::Input::KEY_8),
			luabind::value("KEY_9", Engine::Input::KEY_9),
			luabind::value("KEY_0", Engine::Input::KEY_0),

			luabind::value("KEY_F1", Engine::Input::KEY_F1),
			luabind::value("KEY_F2", Engine::Input::KEY_F2),
			luabind::value("KEY_F3", Engine::Input::KEY_F3),
			luabind::value("KEY_F4", Engine::Input::KEY_F4),
			luabind::value("KEY_F5", Engine::Input::KEY_F5),
			luabind::value("KEY_F6", Engine::Input::KEY_F6),
			luabind::value("KEY_F7", Engine::Input::KEY_F7),
			luabind::value("KEY_F8", Engine::Input::KEY_F8),
			luabind::value("KEY_F9", Engine::Input::KEY_F9),
			luabind::value("KEY_F10", Engine::Input::KEY_F10),
			luabind::value("KEY_F11", Engine::Input::KEY_F11),
			luabind::value("KEY_F12", Engine::Input::KEY_F12),

			luabind::value("KEY_Q", Engine::Input::KEY_Q),
			luabind::value("KEY_W", Engine::Input::KEY_W),
			luabind::value("KEY_E", Engine::Input::KEY_E),
			luabind::value("KEY_R", Engine::Input::KEY_R),
			luabind::value("KEY_T", Engine::Input::KEY_T),
			luabind::value("KEY_Y", Engine::Input::KEY_Y),
			luabind::value("KEY_U", Engine::Input::KEY_U),
			luabind::value("KEY_I", Engine::Input::KEY_I),
			luabind::value("KEY_O", Engine::Input::KEY_O),
			luabind::value("KEY_P", Engine::Input::KEY_P),
			luabind::value("KEY_A", Engine::Input::KEY_A),
			luabind::value("KEY_S", Engine::Input::KEY_S),
			luabind::value("KEY_D", Engine::Input::KEY_D),
			luabind::value("KEY_F", Engine::Input::KEY_F),
			luabind::value("KEY_G", Engine::Input::KEY_G),
			luabind::value("KEY_H", Engine::Input::KEY_H),
			luabind::value("KEY_J", Engine::Input::KEY_J),
			luabind::value("KEY_K", Engine::Input::KEY_K),
			luabind::value("KEY_L", Engine::Input::KEY_L),
			luabind::value("KEY_Z", Engine::Input::KEY_Z),
			luabind::value("KEY_X", Engine::Input::KEY_X),
			luabind::value("KEY_C", Engine::Input::KEY_C),
			luabind::value("KEY_V", Engine::Input::KEY_V),
			luabind::value("KEY_B", Engine::Input::KEY_B),
			luabind::value("KEY_N", Engine::Input::KEY_N),
			luabind::value("KEY_M", Engine::Input::KEY_M)
		]
	];
}