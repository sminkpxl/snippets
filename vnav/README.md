Base example that runs under Windows

Build this way (works under command prompt and powershell):
$ g++.exe -o vnt -g -Wall  -I . -lpthread  vnav-test.cpp src/*.cpp

Prerequisites:
- mingw installed somewhere and the bin directory in the path

Note: takes a single optional cli arg which is the COM port that the vnav is connected to
$ ./vnt COM5

TODO:
- pare it down
