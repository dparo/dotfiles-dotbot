#!/usr/bin/env python3
# -*- coding: utf-8 -*-


def main():
    for a in range(0, 300):
        b = a + 1 - 1
        # NOTE: Inconsistent results for `a is b` depending on the value of a.
        #            Very nice language design boys
        #   The reason of such weird behaviour is the following:
        #       The `is` operator essentialy test whether two python objects points to the same memory address
        #       Now for some weird reason, python has a prestored table of integers in the [-5, 255] range.
        #       When a new object of type int with a value within such a range is created, it essentialy points
        #       to the integer instance inside that table. Hence Two different integer instances of the same value
        #       could potentially compare to different objects using the `is` operator depending if the value
        #       is within this range or not.
        print(f"a = {a}, b = {b}, (a == b): {a == b}, (a is b): {a is b}")


# NOTE: A similar weird behaviour happens with string types due to weird string interning behaviour of the interpreter
def main2():
    str1 = "Hello world"
    str2 = "Hello world"
    print(f"str1 = {str1}, str2 = {str2}, (str1 is str2): {str1 is str2}")
    str1 = "Hello world"
    str2 = "Hello "
    str2 += "world"
    print(f"str1 = {str1}, str2 = {str2}, (str1 is str2): {str1 is str2}")
    str1 = "Hello world"
    str2 = "Hello" + " " + "world"
    print(f"str1 = {str1}, str2 = {str2}, (str1 is str2): {str1 is str2}")


if __name__ == "__main__":
    main()
    main2()
