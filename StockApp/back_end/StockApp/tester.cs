/////////////////////////////////////////////////////////////////////////////////
// Module: testing_main.cs
//
// Versions:
//
// 13-Aug-14: Version 1.0: Created
// 13-Aug-14: Version 1.0: Last Updated
//
// Notes:
//
// To add a test:
// 
// 1: extend the test class
// 2: implement the testing as private member functions
// 3: call RunTest(delegate TestFunction) inside the contructor for each test
/////////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.IO;

namespace ev9
{
   /////////////////////////////////////////////////////////////////////////////////

   public delegate void Test();

   /////////////////////////////////////////////////////////////////////////////////

   class Error
   {
      private string m_error_string;

      public Error(string error)
      {
         m_error_string = error;
      }

      public void Print()
      {
         Console.WriteLine(m_error_string);
      }
   }

   public class Tester
   {
      private int m_total_tests;
      private int m_thread_count;

      private TestTask[] m_tasks;
      private static Tester m_test_object;

      private List<Error> m_error_list;
      private List<Tuple<Test, string>> m_task_list;

      public Tester(int threads = 0)
      {
         if (m_test_object == null)
         {
            // One thread

            m_test_object = new Tester(threads, null);
         }

      }

      private Tester(int threads, Object c)
      {
         if (threads == 0)
         {
            threads = System.Environment.ProcessorCount;
         }

         m_thread_count = threads;
         m_total_tests = 0;

         m_tasks = new TestTask[threads];
         m_error_list = new List<Error>();
         m_task_list = new List<Tuple<Test, string>>();

         for (int i = 0; i < threads; ++i)
         {
            m_tasks[i] = new TestTask();
         }
      }

      private void CollectResults()
      {
         foreach (TestTask task in m_test_object.m_tasks)
         {
            task.Finish();

            foreach (Error error in task.m_error_list) m_test_object.m_error_list.Add(error);

         }
      }

      private void OutputResults()
      {
         foreach (Error error in m_test_object.m_error_list)
         {
            error.Print();
         }

         int errors = m_error_list.Count;

         Console.WriteLine();

         Console.WriteLine(String.Format("--- Total Tests: {0}, Passed: {1}, Failed: {2}\nTested with {3} Threads", m_total_tests, m_total_tests - errors, errors, m_thread_count));
      }

      protected void Run(Action test)
      {
         ++m_test_object.m_total_tests;

         Test test_delegate = new Test(test);

         m_test_object.m_task_list.Add(new Tuple<Test, string>(test_delegate, test.Method.Name));
      }

      public static void RunTests()
      {
         m_test_object.StartTests();
         m_test_object.CollectResults();
         m_test_object.OutputResults();
      }

      private void StartTests()
      {
         int offset = (m_test_object.m_task_list.Count / m_test_object.m_tasks.Length) + 1;

         for (int i = 0; i < m_test_object.m_tasks.Length && i < m_test_object.m_task_list.Count; ++i)
         {
            m_test_object.m_tasks[i].m_task_list = m_task_list;
            m_test_object.m_tasks[i].m_start = i * offset;

            int end = (i * offset) + offset;

            if (end >= m_test_object.m_task_list.Count)
            {
               end = m_test_object.m_task_list.Count;
            }

            m_test_object.m_tasks[i].m_end = end;

            m_test_object.m_tasks[i].Start();
         }

      }
         
      private class TestTask
      {
         public List<Tuple<Test, string>> m_task_list { get; set; }
         public int m_start { get; set; }
         public int m_end { get; set; }

         public List<Error> m_error_list;
         public Thread m_thread;

         public TestTask()
         {
            m_task_list = null;
            m_error_list = new List<Error>();
            m_start = 0;
            m_end = 0;
         }

         public void Finish()
         {
            if (m_thread != null) m_thread.Join();
         }

         private void Run()
         {
            for (int i = m_start; i < m_end; ++i)
            {
               try
               {
                  m_task_list[i].Item1();

                  Console.WriteLine(String.Format(" PASSED -- {0}", m_task_list[i].Item2));
               }

               catch (Exception exception)
               {
                  // Get stack trace for the exception with source file information
                  var st = new StackTrace(exception, true);

                  // Get the top stack frame
                  var frame = st.GetFrame(0);

                  var filename = frame.GetFileName();

                  filename = Path.GetFileName(filename);

                  // Get the line number from the stack frame
                  var line = frame.GetFileLineNumber();

                  m_error_list.Add(new Error(String.Format(" FAILED -- {0}:{1}, {2}: {3}", filename, line, m_task_list[i].Item2, exception.Message)));
               }
            }
         }

         public void Start()
         {
            m_thread = new Thread(new ThreadStart(this.Run));
            m_thread.Start();
         }

      }

   } // End of class test 

}