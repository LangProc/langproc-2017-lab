#ifndef ast_expression_hpp
#define ast_expression_hpp

#include <string>
#include <iostream>
#include <map>

class Expression
{
public:
    virtual ~Expression()
    {}

    virtual void print() const =0;

    //! Evaluate the tree using the given mapping of variables to numbers
    virtual double evaluate(
        const std::map<std::string,double> &bindings
    ) const
    { throw std::runtime_error("Not implemented."); }

    //! Return a new tree which is the derivative w.r.t. given variable
    virtual const Expression *differentiate(
        const std::string &variable
    ) const
    { throw std::runtime_error("Not implemented."); }
};


#endif
