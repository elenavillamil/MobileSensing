////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// 
// Author: Jarret Shook
// 
// Timeperiod: 
// 
// 17-Apr-15: Version 1.0: Created 
// 17-Apr-15: Version 1.0: Last Updated 
// 
// Notes: 
// 
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#ifndef __FACE_RECOGNITION_HPP__
#define __FACE_RECOGNITION_HPP__

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#include "opencv2/contrib/contrib.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/objdetect/objdetect.hpp"

#include <vector>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

namespace ev10 {

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class face_recognition
{
   private:  // Constructor | Destructor
      
      face_recognition() { _ctor(); }
      ~face_recognition() { _dtor(); }

   public:  // Private Member Functions

      std::pair<int, double> decision(cv::Mat& picture) { return _decision(picture); }
      static face_recognition* get_instance() { return *_get_instance(); }
      void reset() { _reset(); }
      void set_image_size(std::size_t width, std::size_t height) { _set_image_size(width, height); }
      void train(std::vector<cv::Mat>& images, std::vector<int>& labels) { _train(images, labels); }

   private: // Private Member Functions

      void _ctor()
      {
         _m_model = cv::createLBPHFaceRecognizer();
      }

      void _dtor()
      {

      }

      std::pair<int, double> _decision(cv::Mat& picture)
      {
         cv::Mat image;

         cv::resize(picture, image, cv::Size(_m_width, _m_height), 1.0, cv::INTER_CUBIC);

         int predicted_label = -1;
         double prediction_confidence = 0.0;

         _m_model->predict(image, predicted_label, prediction_confidence);

         std::pair<int, double> pair(predicted_label, prediction_confidence);

         return pair;
      }

      static face_recognition** _get_instance()
      {
         static face_recognition* s_instance = nullptr;

         return &s_instance;
         
      }

      void _reset()
      {
         *_get_instance() = nullptr;
      }

      void _set_image_size(std::size_t width, std::size_t height)
      {
         face_recognition** instance = _get_instance();

         *instance = new face_recognition();

         (*instance)->_m_width = width;
         (*instance)->_m_height = height;
      }

      void _train(std::vector<cv::Mat>& images, std::vector<int>& labels)
      {
         face_recognition** instance = _get_instance();

         (*instance)->_m_model->train(images, labels);
      }

   private: // Member Variables

      std::size_t _m_height;
      std::size_t _m_width;

      cv::Ptr<cv::FaceRecognizer> _m_model;
   
}; // End of class(face_recognition)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

} // end of namespace(ev10)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#endif // __FACE_RECOGNITION_HPP__

////////////////////////////////////////////////////////////////////////////////
// End of file face_recognition.hpp
////////////////////////////////////////////////////////////////////////////////

