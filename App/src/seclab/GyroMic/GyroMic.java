package seclab.GyroMic;

import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.widget.TextView;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.location.Location;
// import android.location.LocationManager;
import android.location.LocationListener;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import java.io.FileNotFoundException;
import java.io.PrintWriter;

public class GyroMic extends Activity {

	final private String TAG = "GyroMic";
	private TextView m_status;
	// private LocationManager m_locMgr;
	private SensorManager m_sensorMgr;
	private Sensor m_gyroscope;
	private int m_numGyroUpdates;
	private long m_startTime;

	private PrintWriter m_printWriter;

	private final String GYRO_SAMPLES_FILE = 
			Environment.getExternalStorageDirectory().getPath() + "/gyro_samples.txt";

	@Override public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		m_status = (TextView)findViewById(R.id.status);
		getWindow().addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

		try {
			Log.d(TAG, "Output file: " + GYRO_SAMPLES_FILE);
			m_printWriter = new PrintWriter(GYRO_SAMPLES_FILE);
		}
		catch (FileNotFoundException e) {
			Log.e(TAG, "File not found exception");
		}

		// Get Location Provider
		/*
		m_locMgr = (LocationManager) getSystemService(LOCATION_SERVICE);
		Log.i(TAG, "Started location service");
		*/

		m_sensorMgr = (SensorManager) getSystemService(SENSOR_SERVICE);
		m_gyroscope = m_sensorMgr.getDefaultSensor(Sensor.TYPE_GYROSCOPE); // Sensor.TYPE_ALL

		// register a shutdown intent handler
		BroadcastReceiver receiver = new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				finish();
			}
		};

		registerReceiver(receiver, new IntentFilter("seclab.GyroMic.intent.action.SHUTDOWN"));
	} // end of onCreate

	@Override protected void onResume() {
		super.onResume();

		// m_locMgr.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 10000.0f, onLocationChange);

		m_startTime = System.currentTimeMillis();
		m_numGyroUpdates = 0;
		m_sensorMgr.registerListener(onSensorChange, m_gyroscope, SensorManager.SENSOR_DELAY_FASTEST);
	}

	@Override protected void onPause() {
		super.onPause();
		// m_locMgr.removeUpdates(onLocationChange);
		m_sensorMgr.unregisterListener(onSensorChange);
		long currentTime = System.currentTimeMillis();
		long elapsedTime = currentTime - m_startTime;
		Log.i(TAG, "Number of Gyroscope events: " + m_numGyroUpdates + ", Elapsed time: " + elapsedTime);
		m_printWriter.flush();
	}
	
	@SuppressWarnings("unused")
	private LocationListener onLocationChange = new LocationListener() {
		public void onLocationChanged(Location loc) {
			Log.d(TAG, "Received location update");
			String gpsTime = "GPS time: " + loc.getTime();
			Log.i(TAG, gpsTime);
			m_status.setText(gpsTime);
		}

		@Override
			public void onProviderDisabled(String arg0) {
				// TODO Auto-generated method stub
			}

		@Override
			public void onProviderEnabled(String arg0) {
				// TODO Auto-generated method stub
			}

		@Override
			public void onStatusChanged(String arg0, int arg1, Bundle arg2) {
				// TODO Auto-generated method stub
			}
	};

	private SensorEventListener onSensorChange = new SensorEventListener() {

		@Override
			public void onAccuracyChanged(Sensor arg0, int arg1) {
			// TODO Auto-generated method stub

			}

		@Override
			synchronized public void onSensorChanged(SensorEvent event) {
				++m_numGyroUpdates;
				// Log.d(TAG, "Gyroscope update");
				m_printWriter.println(event.timestamp + " " + event.values[0] + " " + event.values[1] + " " + event.values[2]);
			}
	};

} // end of GyroMic class
