cmake_minimum_required(VERSION 3.10)
project(clang_rt_builtins C)

add_library(clang_rt_builtins STATIC udivti3.c)
