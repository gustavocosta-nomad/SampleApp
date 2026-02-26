package com.sampleapp

import android.app.Application
import android.util.Log
import co.ujet.android.Ujet
import co.ujet.android.UjetCustomData
import co.ujet.android.UjetErrorListener
import co.ujet.android.UjetEventListener
import co.ujet.android.UjetEventType
import co.ujet.android.UjetOption
import co.ujet.android.UjetPayloadType
import co.ujet.android.UjetPreferredChannel
import co.ujet.android.UjetRequestListener
import co.ujet.android.UjetStartOptions
import co.ujet.android.UjetStatus
import co.ujet.android.UjetTokenCallback
import co.ujet.android.modulemanager.ConfigurationParameters
import co.ujet.android.modulemanager.ModuleManager
import co.ujet.android.modulemanager.common.ui.UjetStylesOptions
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule


class UJETModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext),
  UjetEventListener, UjetErrorListener, UjetRequestListener {
  override fun getName() = "UJETModule"

  private var listenerCount = 0
  private var optionBuilder = UjetOption.Builder()
  private val startOptionsBuilder = UjetStartOptions.Builder()

  companion object {
    var authTokenCallback: UjetTokenCallback? = null
    var customDataCallback: UjetTokenCallback? = null
  }

  @ReactMethod
  fun initialize(options: ReadableMap) {
    Ujet.setUjetEventNotificationListener(this)
    Ujet.setUjetErrorListener(this)
  }

  private fun setStartOptions (startOptions: ReadableMap) {
    with(startOptionsBuilder) {
      startOptions.getNonEmptyString("menuKey")?.let { setMenuKey(it) }
      startOptions.getNonEmptyString("ivrNumber")?.let { setIvrMode(true).setIvrPhoneNumber(it) }
      startOptions.getMap("unsignedCustomData")?.let { setUnsignedCustomData(getCustomData(it)) }
      startOptions.getNonEmptyString("ticketId")?.let { setTicketId(it) }
      if (startOptions.hasKey("skipSplashScreen")) {
        setSkipSplashEnabled(startOptions.getBoolean("skipSplashScreen"))
      }
      startOptions.getNonEmptyString("preferredChannel")?.lowercase()?.let {
        setPreferredChannel(
          when (it) {
            "call" -> UjetPreferredChannel.UjetPreferredChannelCall
            "chat" -> UjetPreferredChannel.UjetPreferredChannelChat
            else -> null
          }
        )
      }
    }
  }

  private fun setLogLevel(level: String) {
    val logLevel = when (level.lowercase()) {
      "all", "verbose" -> Log.VERBOSE
      "debug" -> Log.DEBUG
      "info" -> Log.INFO
      "warn" -> Log.WARN
      "error" -> Log.ERROR
      else -> Log.INFO
    }

    optionBuilder.setLogLevel(logLevel)
  }

  private fun setGlobalTheme(options: ReadableMap) {
    val stylesOptionsBuilder = UjetStylesOptions.Builder()

    if (options.hasKey("staticFontSizeInSupportPickerView")) {
      optionBuilder.setStaticFontSizeInPickerView(options.getBoolean("staticFontSizeInSupportPickerView"))
    }

    options.getNonEmptyString("customChatThemeJSON")?.let { stylesOptionsBuilder.setChatStyles(it) }

    optionBuilder.setUjetStylesOptions(stylesOptionsBuilder.build())
  }

  private fun setGlobalOptions(options: ReadableMap) {
    with(optionBuilder) {
      options.getNonEmptyString("fallbackPhoneNumber")?.let { setFallbackPhoneNumber(it) }
      options.getNonEmptyString("preferredLanguage")?.let { setDefaultLanguage(it) }

      if (options.hasKey("pstnFallbackSensitivity")) {
        setNetworkSensitivity(options.getDouble("pstnFallbackSensitivity"))
      }
      if (options.hasKey("showSingleChannel")) {
        setShowSingleChannelEnabled(options.getBoolean("showSingleChannel"))
      }
      if (options.hasKey("ignoreDarkMode")) {
        setDarkModeEnabled(!options.getBoolean("ignoreDarkMode"))
      }
      if (options.hasKey("autoMinimizeCallWaiting")) {
        setAutoMinimizeCallView(options.getBoolean("autoMinimizeCallWaiting"))
      }
      if (options.hasKey("agentImageWithoutBorderAndRounding")) {
        setShowAgentIconBorderEnabled(options.getBoolean("agentImageWithoutBorderAndRounding"))
      }
      if (options.hasKey("hideMediaAttachmentInChat")) {
        setHideMediaAttachmentInChat(options.getBoolean("hideMediaAttachmentInChat"))
      }
      if (options.hasKey("blockChatTerminationByEndUser")) {
        setBlockChatTerminationByEndUser(options.getBoolean("blockChatTerminationByEndUser"))
      }
      if (options.hasKey("hideStatusBar")) {
        setHideStatusBar(options.getBoolean("hideStatusBar"))
      }
      if (options.hasKey("enableUncaughtExceptionHandler")) {
        setUncaughtExceptionHandlerEnabled(options.getBoolean("enableUncaughtExceptionHandler"))
      }
      if (options.hasKey("ignoreReadPhoneStatePermission")) {
        setIgnoreReadPhoneStatePermission(options.getBoolean("ignoreReadPhoneStatePermission"))
      }

      options.getNonEmptyString("loadingSpinnerDrawableResName")?.let {
        val context = reactApplicationContext.applicationContext
        val id = context.resources.getIdentifier(it, "drawable", context.packageName)
        setLoadingSpinnerDrawableRes(id)
      }

      val configurationsMap: MutableMap<String, String?> = HashMap()
      options.getNonEmptyString("cobrowseKey")?.let {
        setCobrowseLicenseKey(it)
        configurationsMap[ConfigurationParameters.COBROWSE_API_KEY.name] = it
      }
      options.getNonEmptyString("cobrowseApi")?.let {
        setCobrowseURL(it)
        configurationsMap[ConfigurationParameters.COBROWSE_CUSTOM_URL.name] = it
      }
      ModuleManager.configure(configurationsMap)
    }
  }

  @ReactMethod
  fun start(options: ReadableMap) {
    options.getMap("start")?.let { setStartOptions(it) }
    options.getMap("global")?.let { setGlobalOptions(it) }
    options.getMap("theme")?.let { setGlobalTheme(it) }
    options.getNonEmptyString("logLevel")?.let { setLogLevel(it) }

    Ujet.setOptions(optionBuilder.build())
    Ujet.start(startOptionsBuilder.build())
  }

  @ReactMethod
  fun clearUserData() {
    Ujet.clearUserData()
  }

  @ReactMethod
  fun notifySignPayloadResult(result: ReadableMap) {
    val error = result.getString("error")
    val token = result.getString("token")

    when(result.getString("type")) {
      "authToken" -> handleData(error, token, authTokenCallback)
      "customData" -> handleData(error, token, customDataCallback)
      else -> { }
    }
  }

  @ReactMethod
  fun getStatus(promise: Promise) {
    val status = when (Ujet.getStatus()) {
      UjetStatus.None -> "none"
      UjetStatus.InChat -> "chat"
      UjetStatus.InPstnCall -> "pstn-call"
      UjetStatus.InVoiceCall -> "voip-call"
      else -> "none"
    }
    promise.resolve(status)
  }

  @ReactMethod
  fun disconnect(promise: Promise) {
    if (Ujet.getStatus() == UjetStatus.None) {
      promise.resolve(null)
    }

    Ujet.disconnect {
      promise.resolve(null)
    }
  }

  @ReactMethod
  fun handlePushNotification(payload: ReadableMap, promise: Promise) {
    val data = mutableMapOf<String, String>()
    val iterator = payload.keySetIterator()
    while (iterator.hasNextKey()) {
      val key = iterator.nextKey()
      val value = payload.getString(key)
      if (value != null) {
        data[key] = value
      }
    }

    promise.resolve(Ujet.canHandlePush(data))
  }

  @ReactMethod
  fun addListener(eventName: String) {
    if (listenerCount == 0) {
      // Set up any upstream listeners or background tasks as necessary
    }

    listenerCount += 1
  }

  @ReactMethod
  fun removeListeners(count: Int) {
    listenerCount -= count
    if (listenerCount == 0) {
      // Remove upstream listeners, stop unnecessary background tasks
    }
  }

  private fun ReadableMap.getNonEmptyString(key: String): String? =
    this.getString(key)?.takeIf { it.isNotEmpty() }

  private fun handleData(error: String?, token: String?, callback: UjetTokenCallback?) {
    if (error.isNullOrEmpty()) {
      callback?.onToken(token)
    } else {
      callback?.onError()
    }
  }

  private fun getCustomData(map: ReadableMap): UjetCustomData {
    val customData = UjetCustomData()
    val iterator = map.keySetIterator()
    while (iterator.hasNextKey()) {
      val key = iterator.nextKey()
      map.getMap(key)?.let { data ->
        val label = data.getString("label") ?: ""
        val type = data.getString("type") ?: "string"
        val value: Any = when (type) {
          "number" -> data.getString("value")?.toInt() ?: 0
          "Date" -> data.getString("value")?.toLong() ?: 0L
          else -> data.getString("value") ?: ""
        }
        customData.putObject(key, hashMapOf("label" to label, "type" to type, "value" to value))
      }
    }
    return customData
  }

  private fun sendEvent(eventName: String, params: WritableMap) {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  override fun onEvent(eventType: UjetEventType?, eventData: HashMap<String, Any>?) {
    val writableMap = convertHashMapToWritableMap(eventData)
    sendEvent("onSdkEvent", writableMap)
  }

  private fun convertHashMapToWritableMap(hashMap: HashMap<String, Any>?): WritableMap {
    val writableMap = Arguments.createMap()
    hashMap?.forEach { (key, value) ->
      when (value) {
        is Boolean -> writableMap.putBoolean(key, value)
        is Int -> writableMap.putInt(key, value)
        is Double -> writableMap.putDouble(key, value)
        is String -> writableMap.putString(key, value)
        else -> {}
      }
    }
    return writableMap
  }

  override fun onError(code: Int): Boolean {
    val writableMap = Arguments.createMap()
    writableMap.putInt("errorCode", code)
    sendEvent("onAndroidError", writableMap)

    // Return false if you want the SDK to handle this error (by redirecting to the dialer).
    // Return true if you have handled this error, or do not want the SDK to handle it.
    return false;
  }

  override fun onSignPayloadRequest(
    p0: MutableMap<String, Any>,
    p1: UjetPayloadType,
    p2: UjetTokenCallback
  ) {
    TODO("Not yet implemented")
  }

  override fun onRequestPushToken(): String? {
    return null;
  }
}
