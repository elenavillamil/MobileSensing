debug:
	g++ -g -I ../lib -std=c++11 *.cpp ../src/*.cpp -pthread -lopencv_imgproc -lopencv_highgui -lopencv_objdetect -lopencv_core -lopencv_contrib
release:
	g++ -std=c++11 -I ../lib -O3 *.cpp ../src/*.cpp -pthread -lopencv_imgproc -lopencv_highgui -lopencv_objdetect -lopencv_core -lopencv_contrib
