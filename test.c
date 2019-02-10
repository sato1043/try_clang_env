#include "CUnit/Basic.h"
#include "CUnit/CUnit.h"

#include "functions.h"

void test_say_hello(void);

int main(void) {
  CU_pSuite testSuite;

  CU_initialize_registry();

  testSuite = CU_add_suite("ATestSuite", NULL, NULL);

  CU_add_test(testSuite, "test_say_hello", test_say_hello);

  CU_basic_set_mode(CU_BRM_VERBOSE);
  CU_basic_run_tests();

  CU_cleanup_registry();

  return 0;
}

void test_say_hello(void) { CU_ASSERT(say_hello() == 0); }
