package com.example.day35

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URLEncoder

class MainActivity : FlutterActivity() {
    private val channelName = "online_thekedaar/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "sendWhatsAppMessage") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val phone = call.argument<String>("phone").orEmpty()
                val message = call.argument<String>("message").orEmpty()
                result.success(openWhatsApp(phone, message))
            }
    }

    private fun openWhatsApp(phone: String, message: String): Boolean {
        val encodedMessage = URLEncoder.encode(message, "UTF-8")
        val whatsappUri = Uri.parse("whatsapp://send?phone=$phone&text=$encodedMessage")
        val webUri = Uri.parse("https://wa.me/$phone?text=$encodedMessage")

        val whatsappPackages = listOf("com.whatsapp", "com.whatsapp.w4b")
        for (packageName in whatsappPackages) {
            val intent = Intent(Intent.ACTION_VIEW, whatsappUri).apply {
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                return true
            }
        }

        return try {
            startActivity(
                Intent(Intent.ACTION_VIEW, webUri).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }
}
