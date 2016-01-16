#pragma once

#define _CRT_SECURE_NO_WARNINGS

#include <stdlib.h>

#include <iostream>
#include <list>
#include <sstream>
#include <string>

#include <Selene.h>

#include <lua.hpp>
#include <luabind\luabind.hpp>

#include <boost\ptr_container\ptr_map.hpp>
#include <boost\shared_ptr.hpp>
#include <boost\foreach.hpp>
#include <boost\shared_ptr.hpp>
#include <boost\enable_shared_from_this.hpp>


using namespace Selene;
using namespace Selene::Engine;
using namespace Selene::Engine::Input;


#include "LuaHelper.hpp"
#include "Properties.hpp"
#include "SimpleHelpers.hpp"

#define foreach BOOST_FOREACH


enum eDirection
{
	RIGHT = 0,
	LEFT = 1,
	UP = 2,
	DOWN = 3
};

// メモリリークを検出するためのマクロ
// https://msdn.microsoft.com/ja-jp/library/x98tx3cf(v=vs.100).aspxhttps://msdn.microsoft.com/ja-jp/library/x98tx3cf(v=vs.100).aspx
#ifdef _DEBUG
   #ifndef DBG_NEW
      #define DBG_NEW new ( _NORMAL_BLOCK , __FILE__ , __LINE__ )
      #define new DBG_NEW
   #endif
#endif  // _DEBUG

#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
