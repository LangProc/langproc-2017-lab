#ifndef ast_expression_hpp
#define ast_expression_hpp

#include <string>
#include <iostream>
#include <map>

#include <memory>

class Expression;

// We will use "smart pointers". These will automatically
// free the pointed to object when there are no longer any
// pointers to that object.
typedef const Expression *ExpressionPtr;

class Expression
{
public:
    virtual ~Expression()
    {}

    //! Tell and expression to print itself to the given stream
    virtual void print(std::ostream &dst) const =0;

    //! Evaluate the tree using the given mapping of variables to numbers
    virtual double evaluate(
        const std::map<std::string,double> &bindings
    ) const
    { throw std::runtime_error("Not implemented."); }
};


#endif
