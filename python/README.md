# docs.pytest.org

# Parameterizing a test without fixtures.
# This runs "is_prime" func 3 times. 
@pytest.mark.parameterize('n',[2,3,5])
def test_parameterized_without_fixture(n):
    print 'n =', n
    assert is_prime(n)

# Testing expected exceptions.
# Code supposed to raise a run time error. 
def test_pytest_rasies():
    user = User('python', 'bogus')
    with pytest.raises(RunTimeError):
        prime_factors(user, 2)

# validate the result as 30.
assert result == 30

# functions name starts with test_

# Skip certain tests. 
# conditional skip also available. (skipif)
import pytest

@pytest.mark.skip(reason "some reason")
def test_func_name():

# how to display the skip reasons. 
pytest -v -rsx

# run all the test which has a certain word. 
pytest -k multiply

# Group tests based on tags. (e.g: "windows" as the tag)
@pytest.mark.windows

# execute all test which has a specific tag. 
pytest -m windows -v
pytest -m "not windows" -v

# print output in pytest. 
pytest -s -v test/test_<>.py

## Beyond basics
#1. Built-in types 
Int, float, str, list, dict, set

