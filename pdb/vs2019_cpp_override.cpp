// Project1.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>

class __declspec(novtable) ITest
{
public:
    virtual int Foo() const = 0;
};

class CTest1 : public ITest
{
public:
    virtual int Foo() const
    {
        std::cout << "hello from " << __FUNCTION__ << std::endl;
        return 0;
    }

    virtual int Bar() const = 0;
};

class CTest2 : public CTest1
{
public:
    virtual int Bar() const
    {
        std::cout << "hello from " << __FUNCTION__ << std::endl;
        return 1;
    }
};

int main()
{
    const auto inst = std::make_unique<CTest2>();
    inst->Foo();
    inst->Bar();
    return 0;
}


