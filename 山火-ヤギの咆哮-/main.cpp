#include "StdAfx.h"
#include "MyFramework.hpp"


int WINAPI WinMain( HINSTANCE a, HINSTANCE b, LPSTR c, int d)
{
	boost::shared_ptr<MyFramework> appli = boost::shared_ptr<MyFramework>(new MyFramework());
	appli->Run();
	return 0;
}

