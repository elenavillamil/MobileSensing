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

#include <cassert>
#include <chrono>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <mutex>
#include <thread>
#include <vector>

#include "ar_drone.hpp"
#include "face_recognition.hpp"
#include "server.hpp"
#include "timing_helper.hpp"
#include "video_capture.hpp"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define CROP 100

#define TEST 1

#define CENTER_WIDTH 340
#define CENTER_HEIGHT 240

#define MIN_OBJ_DIV_SIZE 8
#define MIN_FACE_COLS 125

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Load Face cascade (.xml file)
cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eye_cascade;

std::mutex g_recognition_lock;

ar_drone drone;
std::size_t height = 2000; // 2000 mm (2m)

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

inline void train_images(std::string& path)
{
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

      cv::Mat first_image = cv::imread(paths[0].c_str(), CV_LOAD_IMAGE_GRAYSCALE);

      std::size_t original_width = CROP;
      std::size_t original_height = CROP;

      auto push_and_crop = [original_width, original_height](std::vector<cv::Mat>& images, std::vector<int>& labels, const std::string& path, int label, bool crop_face = false)
      {
         cv::Mat vanilla_image = cv::imread(path.c_str(), CV_LOAD_IMAGE_GRAYSCALE);

         assert(vanilla_image.channels() == 1);

         if (crop_face)
         {
            // Dynamically scale min object size by the width of the image (hueristically determined to be img_width / 4)
            int min_object_size = vanilla_image.cols / MIN_OBJ_DIV_SIZE;

            std::vector<cv::Rect>* faces = get_faces(vanilla_image, min_object_size);

            if (faces != nullptr)
            {
               cv::Mat face(vanilla_image, faces->at(0));

               cv::Mat resized_image;
               cv::resize(face, resized_image, cv::Size(original_width, original_height), 1.0, 1.0, cv::INTER_CUBIC);

               images.push_back(face);

               labels.push_back(label);

            }

            delete faces;

         }

         else
         {
            cv::Mat resized_image;
            cv::resize(vanilla_image, resized_image, cv::Size(original_width, original_height), 1.0, 1.0, cv::INTER_CUBIC);

            images.push_back(vanilla_image);

            labels.push_back(label);

         }

      };

      for (std::size_t index = 1; index < paths.size(); ++index)
      {
         push_and_crop(images, labels, paths[index], 0, true);

      }

      std::vector<std::string*> picture_names;

      std::ifstream picture_names_stream("cropped_faces/pictures.txt");

      std::stringstream picture_lines;

      picture_lines << picture_names_stream.rdbuf();

      picture_names_stream.close();

      std::string picture_line;
      
      while (picture_lines >> picture_line)
      {
         picture_line = "cropped_faces/" + picture_line;

         picture_names.push_back(new std::string(picture_line));
      }

      int label_number = 1;
      int count = 1;

      for (std::string* picture : picture_names)
      {
         push_and_crop(images, labels, picture->c_str(), label_number);

         if (count++ == 15)
         {
            ++label_number;
         }
         
         delete picture;

      }

      #if TEST

         for (std::size_t index = 0; index < images.size(); ++index)
         {
            assert(images[index].channels() == 1);
            
         }

      #endif

      {
         // Prevent race condition.
         std::lock_guard<std::mutex> lock(g_recognition_lock);

         ev10::face_recognition::get_instance()->set_image_size(original_width, original_height);
         ev10::face_recognition::get_instance()->train(images, labels);

      }

   }

}

inline void save_face(cv::Mat& image)
{
   static int count = 0;

   std::string filename = "jashook" + std::to_string(count++) + ".png";

   std::vector<int> compression_params;
   compression_params.push_back(CV_IMWRITE_PNG_COMPRESSION);
   compression_params.push_back(9);

   cv::imwrite(filename.c_str(), image, compression_params);

}

inline void face_detection(cv::Mat& image)
{
   cv::Mat mat_gray = image;

   // Convert to gray scale
   cvtColor(image, mat_gray, CV_BGR2GRAY);

   // Dynamically scale min object size by the width of the image (hueristically determined to be img_width / 4)
   int min_object_size = image.cols / MIN_OBJ_DIV_SIZE;

   std::vector<cv::Rect>* faces = get_faces(mat_gray, min_object_size);

   if (!faces) return;

   {
      // Prevent race condition on the recognizer
      std::lock_guard<std::mutex> lock(g_recognition_lock);

      auto instance = ev10::face_recognition::get_instance();

      for (std::size_t index = 0; index < faces->size(); ++index)
      {
         cv::Rect current_roi = (*faces)[index];
         cv::Mat face_roi_gray = mat_gray(current_roi);

         // Print all the objects detected
         cv::rectangle(image, faces->at(index), cv::Scalar(255, 0, 0));

         cv::Mat resized_image;

         cv::resize(face_roi_gray, resized_image, cv::Size(CROP, CROP), 1.0, 1.0, cv::INTER_CUBIC);

         if (instance)
         {
            auto found = instance->decision(face_roi_gray);

            //std::cout << "Label: " << found.first << " Confidence: " << found.second << ". " << std::endl;

            cv::Point offset;
            cv::Size size;
            
            face_roi_gray.locateROI(size, offset);

            // Get the center of the rectangle
            std::size_t center_found_face_width = (face_roi_gray.cols / 2) + offset.x;
            std::size_t center_found_face_height = (face_roi_gray.rows / 2) + offset.y;

            const std::size_t margen_width = 25;
            const std::size_t margen_height = 15;
            const std::size_t margin_depth = 10;
            
            std::cout << center_found_face_width << " " << center_found_face_height << std::endl;
            
            std::cout << "Columns " << face_roi_gray.cols;
            std::cout << "Rows" << face_roi_gray.rows << std::endl;
            
            drone.speed_change(5);

            if (center_found_face_width < CENTER_WIDTH - margen_width)
            {
               // The face is to the left of the center

               std::cout << "<Left>";
               drone.rotate_left();

            }

            else if (center_found_face_width > CENTER_WIDTH + margen_width)
            {
               // The face is to the right of the center

               std::cout << "<Right>";
               drone.rotate_right();

            }
            
            if (center_found_face_height < CENTER_HEIGHT - margen_height)
            {
               // The Face is below the center

               std::cout << "<Below>";
               drone.go_down();

            }

            else if (center_found_face_height > CENTER_HEIGHT + margen_height)
            {
               // The Face is above the center

               std::cout << "<Above>";
               drone.go_up();

            }
            
            drone.speed_change(1);
   
            // Check size of face
            // ~150 is about the distance we want
            
            if (face_roi_gray.cols < MIN_FACE_COLS - margin_depth)
            {
               // The face is too far away

               std::cout << "<Forward>";
               drone.go_forward();
            }
            
            else if (face_roi_gray.cols > MIN_FACE_COLS + margin_depth)
            {
               //The Face is too close
               
               std::cout << "<Backwards>";
               drone.go_backwards();
            }
            

         }
      }

      delete faces;

   }

}

inline bool process_frame(cv::Mat& frame)
{
   double time = ev10::eIIe::timing_helper<ev10::eIIe::SECOND>::time(face_detection, frame);

   //save_face(frame);

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

         train_images(path);

         drone.take_off();
         drone.hover();



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

   #if TEST

      std::string path = "/Users/jarret/msd/database_contents.txt";

      std::cout << "Training Images" << std::endl;

      drone.reset();

      drone.speed_change(5);

      train_images(path);   

      drone.take_off();
      drone.hover();

   #endif

   auto predict_from_file = [](const std::string& path)
	{
      cv::Mat vanilla_image = cv::imread(path.c_str(), CV_LOAD_IMAGE_GRAYSCALE);

      assert(vanilla_image.channels() == 1);

         // Dynamically scale min object size by the width of the image (hueristically determined to be img_width / 4)
         int min_object_size = vanilla_image.cols / MIN_OBJ_DIV_SIZE;

         std::vector<cv::Rect>* faces = get_faces(vanilla_image, min_object_size);

         if (faces)
         {
            cv::Mat face(vanilla_image, faces->at(0));

            cv::Mat resized_image;
            cv::resize(face, resized_image, cv::Size(CROP, CROP), 1.0, 1.0, cv::INTER_CUBIC);
            auto instance = ev10::face_recognition::get_instance();

            return instance->decision(resized_image);

         }

         delete faces;

      std::pair<int, double> default_return(-1, 0.0);

      return default_return;

   };
 
   //train_images("/home/ubuntu/Documents/repos/mobile_sensing/final_project/face_tracking/pictures/");
  
   /*auto found = predict_from_file("/home/ubuntu/msd/pictures/jashook10.png");

   std::cout << "Label: " << found.first << " Confidence: " << found.second << ". " << std::endl;

   found = predict_from_file("/home/ubuntu/msd/pictures/jashook20.png");

   std::cout << "Label: " << found.first << " Confidence: " << found.second << ". " << std::endl;
   */   

   input.capture_sync();

   return 0;

}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
