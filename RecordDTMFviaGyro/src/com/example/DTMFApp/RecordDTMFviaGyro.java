
package com.example.DTMFApp;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import android.app.Activity;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.telephony.TelephonyManager;
import android.util.Log;

public class RecordDTMFviaGyro extends Activity {
    private boolean alreadyStarted = false;
		MediaPlayer mediaPlayer = new MediaPlayer();
    private final float gyroVector[][] = new float[1000][4];
    private SensorManager mSensorManager;
    private Sensor mGyro;
    private int g_rindex;
    private int recording_length = 2500; //in msec

    Handler handler = new Handler();

    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sensor_mic);
        getWindow().addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
     }

    @Override protected void onResume() {
        super.onResume();

        if (alreadyStarted) return;
        alreadyStarted = true;

        // Use a new tread as this can take a while
        (new Thread() {
                public void run() {
                	mediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
                		public boolean onError(MediaPlayer mp, int what, int extra) {
                			Log.d("SensorMic", "Media Player Error! what= " + what + " extra= " + extra);
                			return true;
                        }
                    });
                    android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_URGENT_AUDIO);
                    mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
                    mGyro = mSensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
                    
                    final TelephonyManager tm = (TelephonyManager) getBaseContext().getSystemService(Context.TELEPHONY_SERVICE);
                    String myID = "" + tm.getDeviceId();

                    String wavpath = Environment.getExternalStorageDirectory().toString()+"/DTMFWav";
                    String outpath = wavpath + "/GyroRec/" + myID;
                    File outputDirectory = new File(outpath);
                    outputDirectory.mkdirs(); //create the output directory
                    File f = new File(wavpath);        
                    File files[] = f.listFiles(new FileFilter() {
                        public boolean accept(File f) {
                            return f.getName().endsWith(".wav");
                        }
                    });
                    Log.d("SensorMic", "Found " + files.length + " wav files.");
                    for (int i=0; i < files.length; i++)
                    {
                    	String filename = files[i].getName(); 
                        Log.d("SensorMic", "FileName:" + filename);
                        g_rindex = 0;
                        mSensorManager.registerListener(onSensorChange, mGyro, SensorManager.SENSOR_DELAY_FASTEST);
                        try {
                            Thread.sleep(200);
                        } catch (InterruptedException ie) {
                            // Do nothing.
                        }
                        ThreadAndPlay(files[i]);
                        // Record Gyro reading for 2.1 sec.
                        try {
                            Thread.sleep(recording_length);
                        } catch (InterruptedException ie) {
                            // Do nothing.
                        }
                        mSensorManager.unregisterListener(onSensorChange, mGyro);
                        Log.d("SensorMic", String.format("Read %d readings.", g_rindex));

                        // Dump the whole buffer too.
                        try {
                        	String filenameNoext = filename.substring(0, filename.lastIndexOf('.'));
													String DumpFile= outpath +"/" + filenameNoext + ".gyr";
													Log.d("SensorMic", DumpFile);
                            PrintWriter out =
                                new PrintWriter(
                                new BufferedWriter(
                                new FileWriter(DumpFile,
                                               false)));
                            for (int ix=0; ix<1000; ix++) {
                            	String str =
                                        String.format("%f\t%f\t%f\t%f", gyroVector[ix][0], gyroVector[ix][1], gyroVector[ix][2], gyroVector[ix][3]);
                            	out.println(str);
                            	gyroVector[ix][0] = gyroVector[ix][1] = gyroVector[ix][2] = gyroVector[ix][3] = 0;
                            }
                            out.close();
                        } catch (IOException e) {
                            // oh well
                        }
                        // Wait some before we start the next one.
                        try {
                            Thread.sleep(200);
                        } catch (InterruptedException ie) {
                            // Ignore...
                        }
                    }
                }
            }).start();
    }

    void ThreadAndPlay(File wav) {
        final File finalwav = wav;
        (new Thread() {
                public void run() {
                    playSound(finalwav);
                }
            }).start();
    }

    void playSound(File wav) {
    	mediaPlayer.reset();
    	mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
    	Uri myUri = Uri.fromFile(wav);
    	try {
			mediaPlayer.setDataSource(getApplicationContext(), myUri);
			mediaPlayer.prepare();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalStateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
    	mediaPlayer.start();
    	boolean isPlaying=mediaPlayer.isPlaying();
    	if 	(isPlaying == false)
    	{
    		Log.d("SensorMic", "Media Player is not playing!");
    	}
    }
    
	private SensorEventListener onSensorChange = new SensorEventListener() {

	    @Override
	    synchronized public void onSensorChanged(SensorEvent event) {
		    Sensor sensor = event.sensor;
		    if (sensor.getType() == Sensor.TYPE_GYROSCOPE) {
	            if (g_rindex > 1000)
	        		return;
	    	    gyroVector[g_rindex][0] = event.timestamp;
	    	    gyroVector[g_rindex][1] = event.values[0];
	    	    gyroVector[g_rindex][2] = event.values[1];
	    	    gyroVector[g_rindex][3] = event.values[2];
	    	    g_rindex++;
	        }
	    }

		@Override
		public void onAccuracyChanged(Sensor sensor, int accuracy) {
			// TODO Auto-generated method stub
			
		}
	};

}


