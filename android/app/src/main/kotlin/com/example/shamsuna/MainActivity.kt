package com.example.shamsuna

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // طلب أعلى معدل تحديث متاح، دون إجبار الجهاز إذا لم يدعمه.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.attributes = window.attributes.apply {
                preferredRefreshRate = 120f
            }
        }
    }
}
