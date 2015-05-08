debug:
	g++ -g -I ../lib -std=c++11 *.cpp
release:
	g++ -std=c++11 -I ../lib -O3 *.cpp
lib:
	g++ -std=c++11 -I ../lib -O3 *.cpp -fPIC -shared -o drone_control.so
	rm *.o
