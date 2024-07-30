#ifndef TESTCASE_H
#define TESTCASE_H

#include <string>
#include <vector>

struct TestCase {
    std::string name;
    std::vector<int> inputs;
    std::vector<int> expectedOrderBook;
    std::vector<int> expectedOutputs;
};

#endif 