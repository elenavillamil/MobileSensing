////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// Author: Jarret Shook
//
// Module: main.cpp
//
// Timeperiod:
//
// 29-Oct-14: Version 1.0: Created
// 29-Oct-14: Version 1.0: Last updated
//
// Notes:
//
// Uses opencv
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#if _WIN32

// Windows

#include <opencv2\objdetect\objdetect.hpp>
#include <opencv2\highgui\highgui.hpp>
#include <opencv2\highgui\highgui_c.h>
#include <opencv2\imgproc\imgproc_c.h>
#include <opencv2\imgproc\imgproc.hpp>

#else

// Unix Based System

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/imgproc/imgproc.hpp>

#endif

#include <chrono>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <mutex>
#include <thread>
#include <vector>

#include "face_recognition.hpp"
#include "server.hpp"
#include "timing_helper.hpp"
#include "video_capture.hpp"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Load Face cascade (.xml file)
cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eye_cascade;

std::mutex g_recognition_lock;

inline std::vector<cv::Rect>* get_faces(cv::Mat& current_image, int min_object_size)
{
   // Detect faces
   std::vector<cv::Rect>* faces = new std::vector<cv::Rect>();

   face_cascade.detectMultiScale(current_image, *faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE , cv::Size(min_object_size, min_object_size));

   // Check to see that faces were found - if not, return
   if (faces->size() < 1)
   {
      delete faces;

      return nullptr;
   }

   return faces;
}

inline void face_detection(cv::Mat& image)
{
   cv::Mat mat_gray = image;

   // Convert to gray scale
   cvtColor(image, mat_gray, CV_BGR2GRAY);

   // Dynamically scale min object size by the width of the image (hueristically determined to be img_width / 4)
   int min_object_size = image.cols / 4;

   std::vector<cv::Rect>* faces = get_faces(mat_gray, min_object_size);

   if (!faces) return;

   {
      // Prevent race condition on the recognizer
      std::lock_guard<std::mutex> lock(g_recognition_lock);

      auto instance = ev10::face_recognition::get_instance();

      for (std::size_t index = 0; index < faces->size(); ++index)
      {
         cv::Mat face_roi_gray = mat_gray((*faces)[index]);

         // Print all the objects detected
         cv::rectangle(image, faces->at(index), cv::Scalar(255, 0, 0));

         if (instance)
         {
            bool found = instance->decision(face_roi_gray);

            std::cout << found << std::endl;

         }
      }

   }

   delete faces;

}

inline bool process_frame(cv::Mat& frame)
{
   double time = ev10::eIIe::timing_helper<ev10::eIIe::SECOND>::time(face_detection, frame);

   #ifdef FPS_TIMING
      std::cout << "Operations/sec: " << 1 / time << "\t" << std::flush;
   #else
      std::cout << "Operations/sec: " << 1 / time << "\r" << std::flush;
   #endif

   return false;
}

int main()
{
   new std::thread([] ()
   {
      auto thread = new ev9::server<false>(8000, [](std::vector<char>& input, std::vector<char>& output)
      {
         // Input should be a path to a list of
         // path to use to train.
         // Code is heavily on File I/O and blocks the socket loop.
         // Permissible because socket I/O should be rare.

         std::string path(input.begin(), input.end());

         std::ifstream input_file(path);
      
         static std::string line;
         std::vector<std::string> paths;

         if (input_file.is_open())
         {
            std::stringstream lines;

            lines << input_file.rdbuf();
            input_file.close();

            while (lines >> line)
            {
               paths.push_back(line);

            }

            std::vector<cv::Mat> images;
            std::vector<int> labels;

            for (std::size_t index = 0; index < paths.size(); ++index)
            {
               images.push_back(cv::imread(paths[index].c_str(), 0));
               labels.push_back(0);

            }

            {
               // Prevent race condition.
               std::lock_guard<std::mutex> lock(g_recognition_lock);

               ev10::face_recognition::get_instance()->train(images, labels);

            }

         }

         // End servicing the socket transmission.

      });

      thread->start();

   });

   // Absolute Paths for now

   #ifdef _WIN32
      face_cascade.load("C:\\opencv\\sources\\data\\haarcascades\\haarcascade_frontalface_alt.xml");

   #else
      face_cascade.load("haarcascade/haarcascade_frontalface_alt.xml");

   #endif

   video_capture<process_frame, true> input;

   input.capture_sync();

   return 0;

}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
