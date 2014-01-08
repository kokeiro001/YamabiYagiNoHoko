#pragma once

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

#include "atlbase.h"
#include "atlstr.h"
#include "comutil.h"


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


#ifdef _DEBUG
   #ifndef DBG_NEW
      #define DBG_NEW new ( _NORMAL_BLOCK , __FILE__ , __LINE__ )
      #define new DBG_NEW
   #endif
#endif  // _DEBUG

#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
