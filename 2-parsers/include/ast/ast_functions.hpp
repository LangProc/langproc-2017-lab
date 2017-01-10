#ifndef ast_functions_hpp
#define ast_functions_hpp

#include "ast_expression.hpp"

#include <cmath>

class Function
    : public Expression
{
private:
    const Expression *arg;
protected:
    Function(const Expression *_arg)
        : arg(_arg)
    {}
public:

    virtual ~Function()
    {
        delete arg;
    }

    virtual const char * getFunction() const =0;

    const Expression *getArg() const
    { return arg; }

    virtual void print() const override
    {
        std::cout<<getFunction()<<"( ";
        arg->print();
        std::cout<<" )";
    }
};

class LogFunction
    : public Function
{
public:
    LogFunction(const Expression *_arg)
        : Function(_arg)
    {}

    virtual const char *getFunction() const
    { return "log"; }
};

class ExpFunction
    : public Function
{
public:
    ExpFunction(const Expression *_arg)
        : Function(_arg)
    {}

    virtual const char *getFunction() const
    { return "exp"; }
};

class SqrtFunction
    : public Function
{
public:
    SqrtFunction(const Expression *_arg)
        : Function(_arg)
    {}

    virtual const char *getFunction() const
    { return "sqrt"; }
};


#endif
