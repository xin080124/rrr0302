//using namespace std

#include "stdafx.h"

#include <iostream>
#include <string>
using namespace std;

class withCC
{
public:
	withCC() {}
	withCC(const withCC&)
	{
    	cout << "withCC(withCC&)" << endl;
	}

	//virtual void showCallOrder();
	void showCallOrder();
};

class subCC:public withCC
{
public:
	//virtual void showCallOrder();
	void showCallOrder();
};