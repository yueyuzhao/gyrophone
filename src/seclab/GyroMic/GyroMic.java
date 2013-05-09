package seclab.GyroMic;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.location.Location;
import android.location.LocationManager;
import android.location.LocationListener;

public class GyroMic extends Activity {

	final private String TAG = "GyroMic";
	private TextView m_status;
	private LocationManager m_locMgr;
	private SensorManager m_sensorMgr;
	private Sensor m_gyroscope;
	private int m_numGyroUpdates;

    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        m_status = (TextView)findViewById(R.id.status);
        getWindow().addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

		// Get Location Provider
		m_locMgr = (LocationManager) getSystemService(LOCATION_SERVICE);
		Log.i(TAG, "Started location service");
		
		m_sensorMgr = (SensorManager) getSystemService(SENSOR_SERVICE);
		m_gyroscope = m_sensorMgr.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
    }

	@Override protected void onResume() {
        super.onResume();
        m_locMgr.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 10000.0f, onLocationChange);
        
        m_numGyroUpdates = 0;
        m_sensorMgr.registerListener(onSensorChange, m_gyroscope, SensorManager.SENSOR_DELAY_FASTEST);
    }
    
    @Override protected void onPause() {
    	super.onPause();
    	m_locMgr.removeUpdates(onLocationChange);
    	m_sensorMgr.unregisterListener(onSensorChange);
    	Log.i(TAG, "Number of Gyroscope events: " + m_numGyroUpdates);
    }
    
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
		synchronized public void onSensorChanged(SensorEvent arg0) {
			++m_numGyroUpdates;
		}
    };

} // end of GyroMic class
