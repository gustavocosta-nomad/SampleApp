package com.sampleapp

import android.app.Application
import co.ujet.android.Ujet
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactInstanceEventListener
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.load
import com.facebook.react.defaults.DefaultReactHost.getDefaultReactHost
import com.facebook.react.ReactNativeApplicationEntryPoint.loadReactNative
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.react.flipper.ReactNativeFlipper
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.soloader.SoLoader

class MainApplication : Application(), ReactApplication, ReactInstanceEventListener {
  private var reactContext: ReactContext? = null

  override val reactNativeHost: ReactNativeHost =
          object : DefaultReactNativeHost(this) {
            override fun getPackages(): List<ReactPackage> {
              return PackageList(this).packages.apply { add(MyAppPackage()) }
            }

            override fun getJSMainModuleName(): String = "index"

            override fun getUseDeveloperSupport(): Boolean = BuildConfig.DEBUG

            override val isNewArchEnabled: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
            override val isHermesEnabled: Boolean = BuildConfig.IS_HERMES_ENABLED
          }

  override val reactHost: ReactHost
    get() = getDefaultReactHost(applicationContext, reactNativeHost)

  override fun onCreate() {
    super.onCreate()

    Ujet.init(this)

    loadReactNative(this)
    reactNativeHost.reactInstanceManager.addReactInstanceEventListener(this)
  }

  override fun onReactContextInitialized(reactContext: ReactContext?) {
    this.reactContext = reactContext
  }

  //  override fun onSignPayloadRequest(
  //          payload: MutableMap<String, Any?>,
  //          ujetPayloadType: UjetPayloadType,
  //          callback: UjetTokenCallback
  //  ) {
  //    if (reactContext == null) {
  //      callback.onError()
  //      return
  //    }
  //
  //    when (ujetPayloadType) {
  //      UjetPayloadType.AuthToken -> {
  //        UJETModule.authTokenCallback = callback
  //        createMapAndSendEvent("authToken", payload)
  //      }
  //      UjetPayloadType.CustomData -> {
  //        UJETModule.customDataCallback = callback
  //        createMapAndSendEvent("customData", payload)
  //      }
  //      else -> callback.onError()
  //    }
  //  }

  //  override fun onRequestPushToken(): String? {
  //    /* send an event instead if you are managing push notification in React Native.
  //     *  if (reactContext == null) {
  //     *    Log.i("onRequestPushToken", "context is null")
  //     *  } else {
  //     *    sendEvent(reactContext, "onRequestAndroidPushToken", null)
  //     *  }
  //     */
  //    return null
  //  }

  private fun sendEvent(reactContext: ReactContext, eventName: String, params: WritableMap?) {
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(eventName, params)
  }

  private fun createMapAndSendEvent(typeName: String, payload: Map<String, Any?>) {
    val writableMap = Arguments.createMap()
    for ((key, value) in payload) {
      writableMap.putString(key, value.toString())
    }

    val params = Arguments.createMap()
    params.putString("type", typeName)
    params.putMap("data", writableMap)
    sendEvent(reactContext ?: return, "onSignPayloadRequest", params)
  }
}
