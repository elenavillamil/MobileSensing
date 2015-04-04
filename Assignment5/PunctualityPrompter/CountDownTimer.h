/* Count Down Timer */
#ifndef CountDownTimer_h
#define CountDownTimer_h

#include<Arduino.h>

class CountDownTimer
{
  private:
    unsigned long Watch;
    unsigned long _micro;
    unsigned long time;
    unsigned int Clock;
    unsigned int R_clock;
    boolean Reset;
    boolean Stop;
    boolean Paused;
    volatile boolean timeFlag;
    
  public:
    CountDownTimer() {
        time = micros();
        Clock = 0;
        Reset = false;
        Stop = false;
        Paused = false;
        timeFlag = false;
    }
	
	boolean Timer()
	{
          //Serial.println("     * Starting Timer Function.");
	  static unsigned long duration = 1000000; // 1 second
	  timeFlag = false;
	  if (!Stop && !Paused) // if not Stopped or Paused, run timer
	  {
                //Serial.print("Clock:  "); Serial.print(Clock);
		if ((_micro = micros()) - time > duration ) // check the time difference and see if 1 second has elapsed
		{
		  Clock--;
		  timeFlag = true;

		  if (Clock == 0) // check to see if the clock is 0
			Stop = true; // If so, stop the timer
			
		  _micro < time ? time = _micro : time += duration; // check to see if micros() has rolled over, if not, then increment "time" by duration
		}
	  }
	  return !Stop; // return the state of the timer
	}

	void ResetTimer()
	{
          //Serial.println("     * Reset Timer.");
	  SetTimer(R_clock);
	  Stop = false;
	}

	void StartTimer()
	{
          //Serial.println("     * Initializing Timer.");
	  Watch = micros();
	  Stop = false;
	  Paused = false;
	}

	void StopTimer()
	{
          //Serial.println("     * Stopping Timer.");
	  Stop = true;
	}

	void StopTimerAt(unsigned int hours, unsigned int minutes, unsigned int seconds)
	{
          //Serial.println("     * Stopping Timer At...");
	  if (TimeCheck(hours, minutes, seconds) )
		Stop = true;
	}

	void PauseTimer()
	{
          //Serial.println("     * Paused Timer.");
	  Paused = true;
	}

	void ResumeTimer() // You can resume the timer if you ever stop it.
	{
          //Serial.println("     * Resumed Timer.");
	  Paused = false;
	}

	void SetTimer(unsigned int hours, unsigned int minutes, unsigned int seconds)
	{
          //Serial.println("     * Set Timer (int, int, int).");
	  // This handles invalid time overflow ie 1(H), 0(M), 120(S) -> 1, 2, 0
	  unsigned int _S = (seconds / 60), _M = (minutes / 60);
	  if(_S) minutes += _S;
	  if(_M) hours += _M;
	  
	  Clock = (hours * 3600) + (minutes * 60) + (seconds % 60);
	  R_clock = Clock;
	  Stop = false;
	}

	void SetTimer(unsigned int seconds)
	{
          //Serial.print("     * Set Timer for ");  Serial.print(seconds); Serial.println(" seconds.");
          //delay(7000);
	 // StartTimer(seconds / 3600, (seconds / 3600) / 60, seconds % 60);
	  Clock = seconds;
	  R_clock = Clock;
	  Stop = false;
	}

	int ShowHours()
	{
          //Serial.println("     * Show Hours.");
	  return Clock / 3600;
	}

	int ShowMinutes()
	{
          //Serial.println("     * Show Minutes.");
	  return (Clock / 60) % 60;
	}

	int ShowSeconds()
	{
          //Serial.println("     * Show Seconds.");
	  return Clock % 60;
	}

	unsigned long ShowMilliSeconds()
	{
	  return (_micro - Watch)/ 1000.0;
	}

	unsigned long ShowMicroSeconds()
	{
	  return _micro - Watch;
	}

	boolean TimeHasChanged()
	{
          
	  return timeFlag;
	}

	boolean TimeCheck(int hours, int minutes, int seconds) // output true if timer equals requested time
	{
          //Serial.println("     * Time Check.");
	  return (hours == ShowHours() && minutes == ShowMinutes() && seconds == ShowSeconds());
	}
	
};

#endif

