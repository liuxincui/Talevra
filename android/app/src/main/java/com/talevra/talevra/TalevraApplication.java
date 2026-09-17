package com.talevra.talevra;

import android.app.Application;
import android.util.Log;

import com.bytedance.sdk.shortplay.api.PSSDK;

public final class TalevraApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        PSSDK.Config.Builder builder = new PSSDK.Config.Builder();
        builder.appId(DramaverseConfig.APP_ID)
                .vodAppId(DramaverseConfig.VOD_APP_ID)
                .securityKey(DramaverseConfig.SECURITY_KEY)
                .licenseAssertPath(DramaverseConfig.LICENSE_ASSET_PATH)
                .debug(DramaverseConfig.DEBUG);
        PSSDK.init(this, builder.build(), (success, errorInfo) ->
                Log.d("TalevraPSSDK", "init success=" + success + ", error=" + errorInfo));
        PSSDK.setEligibleAudience(true);
    }
}
