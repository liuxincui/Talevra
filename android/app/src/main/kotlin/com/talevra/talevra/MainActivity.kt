package com.talevra.talevra

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.bytedance.sdk.shortplay.api.PSSDK
import com.bytedance.sdk.shortplay.api.ShortPlay
import java.util.ArrayList

class MainActivity : FlutterActivity() {
    companion object {
        private const val PLAYER_REQUEST_CODE = 7201
        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 7202
    }

    private val dramaCache = mutableMapOf<Long, ShortPlay>()
    private var pendingPlayerResult: MethodChannel.Result? = null
    private var pendingNotificationResult: MethodChannel.Result? = null
    private var activeContentLanguage = "en"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "talevra/dramaverse")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openPlayer" -> {
                        if (pendingPlayerResult != null) {
                            result.error("PLAYER_ALREADY_OPEN", "Player is already open", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, DramaversePlayActivity::class.java)
                        val mode = call.argument<String>("mode") ?: DramaversePlayActivity.MODE_DETAIL
                        intent.putExtra(DramaversePlayActivity.EXTRA_MODE, mode)
                        if (mode != DramaversePlayActivity.MODE_FEED) {
                            call.argument<String>("dramaId")?.toLongOrNull()?.let {
                                intent.putExtra(DramaversePlayActivity.EXTRA_SHORT_PLAY_ID, it)
                                dramaCache[it]?.let { drama ->
                                    intent.putExtra(DramaversePlayActivity.EXTRA_SHORT_PLAY, drama)
                                }
                            }
                        }
                        intent.putExtra(
                            DramaversePlayActivity.EXTRA_LIKED,
                            call.argument<Boolean>("liked") ?: false,
                        )
                        intent.putExtra(
                            DramaversePlayActivity.EXTRA_EPISODE,
                            call.argument<Number>("episode")?.toInt() ?: 1,
                        )
                        intent.putExtra(
                            DramaversePlayActivity.EXTRA_LANGUAGE,
                            call.argument<String>("language") ?: "en",
                        )
                        pendingPlayerResult = result
                        startActivityForResult(intent, PLAYER_REQUEST_CODE)
                    }
                    "getDramaverseCategories" -> loadCategories(result)
                    "getDramaverseDramas" -> loadDramas(call.argument<Number>("categoryId")?.toLong() ?: -2L, result)
                    "setDramaverseLanguage" -> {
                        val language = call.argument<String>("language").orEmpty()
                        if (language.isBlank()) {
                            result.error("INVALID_LANGUAGE", "language is required", null)
                        } else {
                            activeContentLanguage = sdkLanguage(language)
                            dramaCache.clear()
                            PSSDK.setContentLanguage(activeContentLanguage)
                            result.success(null)
                        }
                    }
                    "requestNotificationPermission" -> requestNotificationPermission(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (pendingNotificationResult != null) {
            result.error("PERMISSION_IN_PROGRESS", "Notification permission request is already active", null)
            return
        }
        pendingNotificationResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST_CODE,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) return
        val result = pendingNotificationResult ?: return
        pendingNotificationResult = null
        result.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PLAYER_REQUEST_CODE) return
        val result = pendingPlayerResult ?: return
        pendingPlayerResult = null
        result.success(
            mapOf(
                "liked" to (data?.getBooleanExtra(DramaversePlayActivity.RESULT_LIKED, false) ?: false),
                "episode" to (data?.getIntExtra(DramaversePlayActivity.RESULT_EPISODE, 1) ?: 1),
                "positionMs" to (data?.getIntExtra(DramaversePlayActivity.RESULT_POSITION_MS, 0) ?: 0),
                "action" to (data?.getStringExtra(DramaversePlayActivity.RESULT_ACTION) ?: "back"),
                "dramaId" to (data?.getLongExtra(DramaversePlayActivity.RESULT_DRAMA_ID, -1L)?.toString() ?: ""),
                "completedEpisodes" to (data?.getStringArrayListExtra(
                    DramaversePlayActivity.RESULT_COMPLETED_EPISODES,
                ) ?: emptyList<String>()),
            ),
        )
    }

    private fun loadCategories(result: MethodChannel.Result) {
        PSSDK.requestCategoryList(activeContentLanguage, object : PSSDK.CategoryListResultListener {
            override fun onFail(errorInfo: PSSDK.ErrorInfo) = runOnUiThread {
                result.error(errorInfo.code.toString(), errorInfo.msg, null)
            }

            override fun onSuccess(value: PSSDK.FeedListLoadResult<ShortPlay.ShortPlayCategory>) = runOnUiThread {
                val categories = ArrayList<Map<String, Any>>()
                categories.add(mapOf("id" to -2L, "name" to "Recommend", "count" to 0))
                categories.add(mapOf("id" to -1L, "name" to "New", "count" to 0))
                value.dataList.orEmpty().forEach { category ->
                    categories.add(mapOf("id" to category.id, "name" to category.name, "count" to category.count))
                }
                result.success(categories)
            }
        })
    }

    private fun sdkLanguage(language: String): String {
        val normalized = language.lowercase().substringBefore('-').substringBefore('_')
        return when (normalized) {
            "pt", "es", "ja", "ko", "en" -> normalized
            "id" -> "in"
            else -> "en"
        }
    }

    private fun loadDramas(categoryId: Long, result: MethodChannel.Result) {
        val query = PSSDK.QueryRequestParameters().apply {
            setIndex(1)
            setCount(30)
            if (categoryId > 0) setCategoryIds(arrayListOf(categoryId))
        }
        val listener = object : PSSDK.FeedListResultListener {
            override fun onFail(errorInfo: PSSDK.ErrorInfo) = runOnUiThread {
                if (errorInfo.code == 10013) {
                    result.success(emptyList<Map<String, Any>>())
                } else {
                    result.error(errorInfo.code.toString(), errorInfo.msg, null)
                }
            }

            override fun onSuccess(value: PSSDK.FeedListLoadResult<ShortPlay>) = runOnUiThread {
                value.dataList.orEmpty().forEach { dramaCache[it.id] = it }
                result.success(value.dataList.orEmpty().map { drama ->
                    mapOf(
                        "id" to drama.id.toString(),
                        "title" to (drama.title ?: ""),
                        "description" to (drama.desc ?: ""),
                        "coverImage" to (drama.coverImage ?: ""),
                        "episodes" to drama.total,
                        "category" to (drama.categories?.firstOrNull()?.name ?: ""),
                        "tags" to drama.tags.orEmpty().mapNotNull { it.name },
                    )
                })
            }
        }
        if (categoryId == -1L) {
            val latest = PSSDK.LatestDramaRequestParameters().apply {
                setIndex(1)
                setCount(30)
            }
            PSSDK.requestNewDrama(latest, listener)
        } else if (categoryId == -2L) {
            PSSDK.requestFeedList(query, listener)
        } else {
            PSSDK.requestFeedListByCategoryIds(query, listener)
        }
    }
}
