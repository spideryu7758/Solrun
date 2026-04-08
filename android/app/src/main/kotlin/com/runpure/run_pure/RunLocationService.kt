package com.runpure.run_pure

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*
import com.google.android.gms.tasks.CancellationTokenSource
import kotlinx.coroutines.*

/**
 * 原生前台 GPS 定位服务
 *
 * 独立于 Flutter 引擎生命周期，在荣耀/华为等国产 ROM 上
 * 不会因息屏/后台被系统杀死。通过静态回调将 GPS 数据传回 Flutter。
 *
 * 参考：newpatrol 项目的 PatrolLocationService
 */
class RunLocationService : Service() {

    companion object {
        private const val TAG = "RunLocationService"

        const val ACTION_START = "com.runpure.run_pure.action.START_TRACKING"
        const val ACTION_STOP = "com.runpure.run_pure.action.STOP_TRACKING"
        const val NOTIFICATION_ID = 2001
        const val CHANNEL_ID = "runpure_gps"

        // GPS 配置
        private const val LOCATION_INTERVAL_MS = 3000L
        private const val FASTEST_INTERVAL_MS = 2000L

        // GPS 过滤阈值
        private const val MAX_ACCURACY_M = 15f
        private const val MAX_AGE_MS = 30_000L
        private const val MAX_SPEED_MS = 33f       // ~120km/h
        private const val JUMP_DIST_M = 500f
        private const val JUMP_TIME_MS = 15_000L

        @Volatile
        private var instance: RunLocationService? = null

        /** GPS 点回调（由 MainActivity EventChannel 注册） */
        @Volatile
        var onLocationPoint: ((Map<String, Any?>) -> Unit)? = null

        fun isRunning(): Boolean = instance != null
    }

    // GPS 双栈
    private lateinit var fusedClient: FusedLocationProviderClient
    private lateinit var locationRequest: LocationRequest
    private lateinit var locationCallback: LocationCallback
    private var nativeLocationManager: android.location.LocationManager? = null
    private var nativeListener: android.location.LocationListener? = null

    // 状态
    @Volatile
    private var lastLocation: Location? = null
    private var startTimeMs: Long = 0L
    private var accumulatedDistanceM: Double = 0.0

    // 协程
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var notificationJob: Job? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        setupLocationRequest()
        setupLocationCallback()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startTracking()
            ACTION_STOP -> stopTracking()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopLocationUpdates()
        notificationJob?.cancel()
        serviceScope.cancel()
        instance = null
    }

    // ==================== 通知渠道 ====================

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "RunPure 跑步记录",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "跑步时的 GPS 定位服务通知"
                setShowBadge(false)
            }
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(duration: String, distance: String): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("RunPure 正在记录跑步")
            .setContentText("$duration | $distance")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .setShowWhen(false)
            .build()
    }

    // ==================== GPS 配置 ====================

    private fun setupLocationRequest() {
        locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            LOCATION_INTERVAL_MS
        ).apply {
            setMinUpdateIntervalMillis(FASTEST_INTERVAL_MS)
            setMinUpdateDistanceMeters(0f)
            setWaitForAccurateLocation(false)
        }.build()
    }

    private fun setupLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (loc in result.locations) {
                    onNewLocation(loc)
                }
            }
        }
    }

    // ==================== 服务生命周期 ====================

    private fun startTracking() {
        lastLocation = null
        accumulatedDistanceM = 0.0
        startTimeMs = System.currentTimeMillis()

        val notification = buildNotification("00:00", "0.00 km")
        ServiceCompat.startForeground(
            this, NOTIFICATION_ID, notification,
            ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
        )

        startLocationUpdates()
        startNotificationUpdater()

        instance = this
        Log.i(TAG, "跑步 GPS 服务已启动")
    }

    private fun stopTracking() {
        Log.i(TAG, "跑步 GPS 服务停止")
        stopLocationUpdates()
        notificationJob?.cancel()
        instance = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    // ==================== GPS 双栈定位 ====================

    private fun startLocationUpdates() {
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(TAG, "缺少定位权限")
            return
        }

        try {
            // Fused: 获取最后已知位置
            fusedClient.lastLocation.addOnSuccessListener { loc ->
                if (loc != null) onNewLocation(loc)
                else tryNativeLastKnown()
            }
            // Fused: 单次高精度定位
            try {
                val cts = CancellationTokenSource()
                fusedClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, cts.token)
                    .addOnSuccessListener { loc -> if (loc != null) onNewLocation(loc) }
            } catch (e: Exception) {
                Log.w(TAG, "getCurrentLocation 异常: ${e.message}")
            }
            // Fused: 持续定位
            fusedClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
            // 原生 LocationManager 作为补充
            startNativeUpdates()
        } catch (e: SecurityException) {
            Log.e(TAG, "定位权限异常: ${e.message}")
        }
    }

    private fun tryNativeLastKnown() {
        try {
            val lm = getSystemService(Context.LOCATION_SERVICE) as android.location.LocationManager
            for (provider in listOf(
                android.location.LocationManager.GPS_PROVIDER,
                android.location.LocationManager.NETWORK_PROVIDER,
                android.location.LocationManager.PASSIVE_PROVIDER
            )) {
                if (lm.isProviderEnabled(provider)) {
                    @Suppress("MissingPermission")
                    val loc = lm.getLastKnownLocation(provider)
                    if (loc != null) { onNewLocation(loc); return }
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "原生 lastKnown 异常: ${e.message}")
        }
    }

    private fun startNativeUpdates() {
        try {
            val lm = getSystemService(Context.LOCATION_SERVICE) as android.location.LocationManager
            nativeLocationManager = lm
            nativeListener = object : android.location.LocationListener {
                override fun onLocationChanged(loc: Location) = onNewLocation(loc)
                override fun onProviderEnabled(p: String) {}
                override fun onProviderDisabled(p: String) {}
            }
            for (provider in listOf(
                android.location.LocationManager.GPS_PROVIDER,
                android.location.LocationManager.NETWORK_PROVIDER
            )) {
                if (lm.isProviderEnabled(provider)) {
                    @Suppress("MissingPermission")
                    lm.requestLocationUpdates(
                        provider, LOCATION_INTERVAL_MS, 0f,
                        nativeListener!!, Looper.getMainLooper()
                    )
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "原生定位启动异常: ${e.message}")
        }
    }

    private fun stopLocationUpdates() {
        try { fusedClient.removeLocationUpdates(locationCallback) } catch (_: Exception) {}
        try {
            nativeListener?.let { nativeLocationManager?.removeUpdates(it) }
            nativeLocationManager = null
            nativeListener = null
        } catch (_: Exception) {}
    }

    // ==================== GPS 多层过滤 ====================

    private fun onNewLocation(location: Location) {
        // 坐标有效性
        if (location.latitude !in -90.0..90.0 || location.longitude !in -180.0..180.0) return

        // Layer 0: 过期点（GPS 时间戳 > 30 秒前）
        val age = System.currentTimeMillis() - location.time
        if (age > MAX_AGE_MS) return

        // Layer 1: 精度过滤
        if (location.hasAccuracy() && location.accuracy > MAX_ACCURACY_M) return

        // Layer 2: 速度异常（> 120km/h）
        if (location.hasSpeed() && location.speed > MAX_SPEED_MS) return

        // Layer 3: GPS 跳变（500m/15s）
        lastLocation?.let { prev ->
            val dist = prev.distanceTo(location)
            val timeDelta = location.time - prev.time
            if (dist > JUMP_DIST_M && timeDelta in 1..JUMP_TIME_MS.toLong()) {
                Log.w(TAG, "GPS 跳变: ${dist}m/${timeDelta}ms, 重置基准点")
                lastLocation = location
                return
            }
            // 累计距离
            if (dist > 0.5f) {
                accumulatedDistanceM += dist
            }
        }

        lastLocation = location

        // 构建数据 Map，发送到 Flutter
        val pointMap = HashMap<String, Any?>().apply {
            put("latitude", location.latitude)
            put("longitude", location.longitude)
            put("altitude", if (location.hasAltitude()) location.altitude else null)
            put("accuracy", if (location.hasAccuracy()) location.accuracy.toDouble() else 15.0)
            put("speed", if (location.hasSpeed() && location.speed >= 0) location.speed.toDouble() else 0.0)
            put("timestamp", location.time)
        }

        onLocationPoint?.invoke(pointMap)
    }

    // ==================== 通知更新 ====================

    private fun startNotificationUpdater() {
        notificationJob?.cancel()
        notificationJob = serviceScope.launch {
            while (isActive) {
                delay(1000)
                val elapsed = (System.currentTimeMillis() - startTimeMs) / 1000
                val min = elapsed / 60
                val sec = elapsed % 60
                val duration = "%02d:%02d".format(min, sec)
                val distKm = accumulatedDistanceM / 1000
                val distance = "%.2f km".format(distKm)

                val notification = buildNotification(duration, distance)
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                nm.notify(NOTIFICATION_ID, notification)
            }
        }
    }
}
