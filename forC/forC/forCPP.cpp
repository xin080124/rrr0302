#include "stdafx.h"

#include <iostream>
#include <string>
using namespace std;

#include "forCPP.h"


void withCC::showCallOrder()
{
	cout << "base function" << endl;
}


void subCC::showCallOrder()
{
	cout << "sub function" << endl;
}
