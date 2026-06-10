package com.hermes.djfy;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.ConsoleMessage;
import android.view.WindowManager;
import android.view.View;
import android.util.Log;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i("DJFY", "MainActivity.onCreate()");
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

        WebView webView = new WebView(this);
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                Log.i("DJFY", "onPageFinished: " + url);
            }
            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                Log.e("DJFY", "onReceivedError: " + description + " url=" + failingUrl);
            }
        });

        // Capture console.log → Android logcat
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage cm) {
                Log.i("DJFY_JS", cm.message() + " (line " + cm.lineNumber() + ")");
                return true;
            }
        });

        // Force software rendering — avoids GPU tile memory OOM on old tablets
        webView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setAllowContentAccess(true);
        settings.setMediaPlaybackRequiresUserGesture(false);

        // Enable remote debugging
        if (android.os.Build.VERSION.SDK_INT >= 19) {
            android.webkit.WebView.setWebContentsDebuggingEnabled(true);
        }

        Log.i("DJFY", "Loading index.html...");
        webView.loadUrl("file:///android_asset/index.html");
        setContentView(webView);
    }
}
