package com.talevra.talevra;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.FrameLayout;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.widget.SeekBar;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.bytedance.sdk.shortplay.api.EpisodeData;
import com.bytedance.sdk.shortplay.api.PSSDK;
import com.bytedance.sdk.shortplay.api.ShortPlay;
import com.bytedance.sdk.shortplay.api.ShortPlayFragment;

import java.util.ArrayList;
import java.util.List;

public final class DramaversePlayActivity extends FragmentActivity implements PSSDK.FeedListResultListener {
    private static final String TAG = "DramaversePlay";
    private static final int WATCH_REWARD_COINS = 50;
    private static final int WATCH_REWARD_INTERVAL_SECONDS = 30;
    public static final String EXTRA_SHORT_PLAY_ID = "short_play_id";
    public static final String EXTRA_SHORT_PLAY = "short_play";
    public static final String EXTRA_LIKED = "liked";
    public static final String EXTRA_EPISODE = "episode";
    public static final String EXTRA_LANGUAGE = "language";
    public static final String RESULT_LIKED = "result_liked";
    public static final String RESULT_EPISODE = "result_episode";
    public static final String RESULT_POSITION_MS = "result_position_ms";
    public static final String RESULT_ACTION = "result_action";
    private FrameLayout container;
    private boolean liked;
    private int currentEpisode = 1;
    private int currentPositionMs = 0;
    private String resultAction = "back";
    private ProgressBar earningsProgress;
    private int lastProgressEpisode = -1;
    private TextView rewardBalance;
    private TextView rewardNext;
    private int coinBalance;
    private int lastRewardBucket;
    private String playerLanguage = "en";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN,
                android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                        | View.SYSTEM_UI_FLAG_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        container = new FrameLayout(this);
        container.setId(R.id.dramaverse_container);
        setContentView(container);
        liked = getIntent().getBooleanExtra(EXTRA_LIKED, false);
        playerLanguage = normalizeLanguage(getIntent().getStringExtra(EXTRA_LANGUAGE));
        coinBalance = getSharedPreferences("talevra_rewards", MODE_PRIVATE)
                .getInt("coin_balance", 0);
        currentEpisode = Math.max(1, getIntent().getIntExtra(EXTRA_EPISODE, 1));
        showMessage(text("loading"), true);
        if (!PSSDK.hasInitialized()) {
            finishWithError(text("sdkUnavailable"));
            return;
        }
        ShortPlay selectedDrama = getIntent().getParcelableExtra(EXTRA_SHORT_PLAY);
        if (selectedDrama != null) {
            showDrama(selectedDrama);
            return;
        }
        long selectedId = getIntent().getLongExtra(EXTRA_SHORT_PLAY_ID, -1L);
        PSSDK.QueryRequestParameters query = new PSSDK.QueryRequestParameters();
        query.setIndex(1);
        query.setCount(1);
        if (selectedId > 0) {
            ArrayList<Long> ids = new ArrayList<>();
            ids.add(selectedId);
            query.setShortPlayIds(ids);
            PSSDK.requestFeedList(query, this);
        } else {
            PSSDK.requestPopularDrama(query, this);
        }
    }

    @Override
    public void onFail(PSSDK.ErrorInfo errorInfo) {
        Log.e(TAG, "feed failed: " + errorInfo);
        finishWithError(text("feedFailed"));
    }

    @Override
    public void onSuccess(PSSDK.FeedListLoadResult<ShortPlay> result) {
        if (result == null || result.dataList == null || result.dataList.isEmpty()) {
            finishWithError(text("noDrama"));
            return;
        }
        ShortPlay shortPlay = result.dataList.get(0);
        showDrama(shortPlay);
    }

    private void showDrama(ShortPlay shortPlay) {
        PSSDK.DetailPageConfig config = new PSSDK.DetailPageConfig.Builder()
                .startPlayIndex(currentEpisode)
                .displayProgressBar(false)
                .displayBottomExtraView(false)
                .displayTextVisibility(PSSDK.DetailPageConfig.TEXT_POS_BOTTOM_TITLE, false)
                .displayTextVisibility(PSSDK.DetailPageConfig.TEXT_POS_BOTTOM_DESC, false)
                .hideLeftTopCloseAndTitle(true, () -> {
                    finish();
                    return true;
                })
                .build();
        ShortPlayFragment fragment = PSSDK.createDetailFragment(shortPlay, config,
                new PSSDK.ShortPlayDetailPageListener() {
                    @Override public void onOverScroll(int direction) { }
                    @Override public void onProgressChange(ShortPlay p, int i, int c, int d) {
                        currentEpisode = Math.max(1, i);
                        currentPositionMs = Math.max(0, c);
                        updatePlaybackChrome(p, c, d);
                    }
                    @Override public boolean onPlayFailed(PSSDK.ErrorInfo e) {
                        Log.e(TAG, "play failed: " + e);
                        showSdkError(text("playFailed"), e);
                        return true;
                    }
                    @Override public void onShortPlayPlayed(ShortPlay p, int i, EpisodeData e) {
                        currentEpisode = Math.max(1, i);
                        updatePlaybackChrome(p, 0, 0);
                    }
                    @Override public void onItemSelected(int p, ItemType t, int i) { }
                    @Override public void onVideoPlayStateChanged(ShortPlay p, int i, int s) { }
                    @Override public void onVideoPlayCompleted(ShortPlay p, int i) { }
                    @Override public void onEnterImmersiveMode() { }
                    @Override public void onExitImmersiveMode() { }
                    @Override public boolean isNeedBlock(ShortPlay p, int i) { return false; }
                    // Ads are intentionally disabled for this phase. The SDK callback is
                    // acknowledged directly so playback remains available without an ad SDK.
                    @Override public void showAdIfNeed(ShortPlay p, int i, PSSDK.ShortPlayBlockResultListener l) { l.onShortPlayUnlocked(); }
                    @Override public void onVideoInfoFetched(ShortPlay p, int i, PSSDK.VideoPlayInfo info) { }
                    @Override public List<android.view.View> onObtainPlayerControlViews() {
                        return createMixPlayerControls(shortPlay);
                    }
                });
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.dramaverse_container, fragment)
                .runOnCommit(() -> { })
                .commit();
    }

    private List<View> createMixPlayerControls(ShortPlay shortPlay) {
        ArrayList<View> views = new ArrayList<>();

        MixOverlayView overlay = new MixOverlayView(this);
        overlay.setLayoutParams(new FrameLayout.LayoutParams(-1, -1));
        views.add(overlay);

        RewardTaskView rewardTask = new RewardTaskView(this);
        FrameLayout.LayoutParams rewardTaskParams = new FrameLayout.LayoutParams(dp(52), dp(58));
        rewardTaskParams.gravity = Gravity.RIGHT | Gravity.BOTTOM;
        rewardTaskParams.rightMargin = dp(7);
        rewardTaskParams.bottomMargin = dp(294);
        rewardTask.setLayoutParams(rewardTaskParams);
        rewardTask.setOnClickListener(v -> Toast.makeText(
                this, text("watchToEarn"), Toast.LENGTH_SHORT).show());
        views.add(rewardTask);

        ShareControlView share = new ShareControlView(this);
        share.setImageResource(R.drawable.share);
        share.setContentDescription(text("share"));
        share.setPadding(dp(6), dp(6), dp(6), dp(6));
        FrameLayout.LayoutParams shareParams = new FrameLayout.LayoutParams(dp(48), dp(48));
        shareParams.gravity = Gravity.RIGHT | Gravity.BOTTOM;
        shareParams.rightMargin = dp(10);
        shareParams.bottomMargin = dp(100);
        share.setLayoutParams(shareParams);
        share.setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("text/plain");
            intent.putExtra(Intent.EXTRA_SUBJECT, shortPlay.title);
            intent.putExtra(Intent.EXTRA_TEXT, shortPlay.desc);
            startActivity(Intent.createChooser(intent, text("shareDrama")));
        });
        views.add(share);

        MixLikeView like = new MixLikeView(this, false);
        FrameLayout.LayoutParams likeParams = new FrameLayout.LayoutParams(-2, -2);
        likeParams.gravity = Gravity.RIGHT | Gravity.BOTTOM;
        likeParams.rightMargin = dp(10);
        likeParams.bottomMargin = dp(228);
        like.setLayoutParams(likeParams);
        views.add(like);

        MixLikeView collect = new MixLikeView(this, true);
        FrameLayout.LayoutParams collectParams = new FrameLayout.LayoutParams(-2, -2);
        collectParams.gravity = Gravity.RIGHT | Gravity.BOTTOM;
        collectParams.rightMargin = dp(10);
        collectParams.bottomMargin = dp(164);
        collect.setLayoutParams(collectParams);
        views.add(collect);

        MixProgressBar progress = new MixProgressBar(this);
        FrameLayout.LayoutParams progressParams = new FrameLayout.LayoutParams(-1, dp(16));
        progressParams.gravity = Gravity.BOTTOM;
        progressParams.leftMargin = dp(10);
        progressParams.rightMargin = dp(10);
        progressParams.bottomMargin = dp(4);
        progress.setLayoutParams(progressParams);
        views.add(progress);
        return views;
    }

    private static final class ShareControlView extends androidx.appcompat.widget.AppCompatImageView
            implements PSSDK.IControlView {
        ShareControlView(android.content.Context context) { super(context); }
        @Override public PSSDK.ControlViewType getControlViewType() { return PSSDK.ControlViewType.Share; }
        @Override public void bindItemData(ShortPlayFragment fragment, ShortPlay shortPlay, int index) { }
    }

    private final class RewardTaskView extends androidx.appcompat.widget.AppCompatTextView
            implements PSSDK.IControlView {
        RewardTaskView(android.content.Context context) {
            super(context);
            Drawable icon = getResources().getDrawable(R.drawable.player_cash);
            icon.setBounds(0, 0, dp(34), dp(30));
            setCompoundDrawables(null, icon, null, null);
            setCompoundDrawablePadding(dp(1));
            setText(text("earn"));
            setTextColor(Color.WHITE);
            setTextSize(9);
            setGravity(Gravity.CENTER);
            setBackgroundResource(R.drawable.player_task_bg);
            setContentDescription(text("watchToEarn"));
        }

        @Override public PSSDK.ControlViewType getControlViewType() {
            return PSSDK.ControlViewType.CUSTOM;
        }

        @Override public void bindItemData(ShortPlayFragment fragment, ShortPlay play, int index) { }
    }

    private final class MixLikeView extends androidx.appcompat.widget.AppCompatTextView
            implements PSSDK.IControlStatusView {
        private final boolean collect;
        private final Drawable normal;
        private final Drawable selected;
        private PSSDK.ControlStatus status = PSSDK.ControlStatus.Normal;

        MixLikeView(android.content.Context context, boolean collect) {
            super(context);
            this.collect = collect;
            normal = getResources().getDrawable(collect ? R.drawable.collect : R.drawable.like);
            selected = getResources().getDrawable(collect ? R.drawable.collected : R.drawable.liked);
            normal.setBounds(0, 0, dp(30), dp(30));
            selected.setBounds(0, 0, dp(30), dp(30));
            setGravity(Gravity.CENTER_HORIZONTAL);
            setTextColor(Color.WHITE);
            setTextSize(10);
            setMinWidth(dp(48));
            setMinHeight(dp(52));
            setCompoundDrawablePadding(dp(2));
            setShadowLayer(dp(3), 0, dp(1), Color.BLACK);
            setContentDescription(text(collect ? "collect" : "like"));
            setCompoundDrawables(null, normal, null, null);
        }

        @Override public void setCurrentStatus(ShortPlay p, int index, PSSDK.ControlStatus status, PSSDK.StatusExtraInfo extra) {
            this.status = status;
            setCompoundDrawables(null, status == PSSDK.ControlStatus.Normal ? normal : selected, null, null);
            setText(String.valueOf(collect ? extra.totalCollectCount : extra.totalLikeCount));
        }
        @Override public PSSDK.ControlStatus getCurrentStatus(ShortPlay p, int index) { return status; }
        @Override public PSSDK.ControlStatus onClicked(ShortPlay p, int index, PSSDK.ControlStatus current) {
            PSSDK.ControlStatus next = current == PSSDK.ControlStatus.Normal
                    ? PSSDK.ControlStatus.Selected : PSSDK.ControlStatus.Normal;
            if (!collect) liked = next == PSSDK.ControlStatus.Selected;
            return next;
        }
        @Override public PSSDK.ControlViewType getControlViewType() {
            return collect ? PSSDK.ControlViewType.Collect : PSSDK.ControlViewType.Like;
        }
        @Override public void bindItemData(ShortPlayFragment fragment, ShortPlay p, int index) { }
    }

    private static final class MixProgressBar extends SeekBar
            implements PSSDK.IControlProgressBar, SeekBar.OnSeekBarChangeListener {
        private ShortPlayFragment fragment;
        private int index;
        MixProgressBar(android.content.Context context) {
            super(context);
            setProgressDrawable(getResources().getDrawable(R.drawable.player_seek_progress));
            setThumb(new ColorDrawable(Color.TRANSPARENT));
            int verticalPadding = Math.round(7 * getResources().getDisplayMetrics().density);
            setPadding(0, verticalPadding, 0, verticalPadding);
            setOnSeekBarChangeListener(this);
        }
        @Override public void onProgressChanged(int progress, int duration) {
            if (getMax() != duration) setMax(duration);
            setProgress(progress);
        }
        @Override public PSSDK.ControlViewType getControlViewType() { return PSSDK.ControlViewType.PROGRESS_BAR; }
        @Override public void bindItemData(ShortPlayFragment fragment, ShortPlay p, int index) {
            this.fragment = fragment;
            this.index = index;
        }
        @Override public void onProgressChanged(SeekBar bar, int progress, boolean fromUser) { }
        @Override public void onStartTrackingTouch(SeekBar bar) { }
        @Override public void onStopTrackingTouch(SeekBar bar) {
            if (fragment != null) fragment.startPlayIndexAndTimeSeconds(index, getProgress());
        }
        @Override public void onVideoPlayStateChanged(ShortPlay shortPlay, int index, int playbackState) { }
    }

    private final class MixOverlayView extends FrameLayout implements PSSDK.IControlView {
        private TextView title;
        private TextView desc;
        private TextView choose;
        private TextView select;
        private ShortPlay boundPlay;
        private ShortPlayFragment boundFragment;

        MixOverlayView(android.content.Context context) {
            super(context);
            LayoutInflater.from(context).inflate(R.layout.player_overlay, this, true);
            title = findViewById(R.id.tv_overlay_drama_name);
            desc = findViewById(R.id.tv_overlay_drama_desc);
            choose = findViewById(R.id.tv_overlay_choose_index_title);
            select = findViewById(R.id.tv_overlay_select);
            earningsProgress = findViewById(R.id.pb_watch_reward);
            rewardBalance = findViewById(R.id.tv_reward_balance);
            rewardNext = findViewById(R.id.tv_reward_next);
            rewardBalance.setText(formatCoins(coinBalance));
            rewardNext.setText("+" + WATCH_REWARD_COINS + " · " + WATCH_REWARD_INTERVAL_SECONDS + "s");
            select.setText(text("select") + " ›");
            findViewById(R.id.btn_player_back).setContentDescription(text("back"));
            findViewById(R.id.btn_player_back).setOnClickListener(v -> finish());
            findViewById(R.id.ll_choose_index).setOnClickListener(v -> showEpisodePicker());
        }
        @Override public PSSDK.ControlViewType getControlViewType() { return PSSDK.ControlViewType.CUSTOM; }
        @Override public void bindItemData(ShortPlayFragment fragment, ShortPlay play, int index) {
            boundFragment = fragment;
            boundPlay = play;
            title.setText(play.title);
            desc.setVisibility(View.GONE);
            choose.setText(formatEpisode(index));
        }
        private void showEpisodePicker() {
            if (boundPlay == null || boundFragment == null) return;
            int total = Math.max(1, boundPlay.total);
            String[] episodes = new String[total];
            for (int i = 0; i < total; i++) episodes[i] = formatEpisode(i + 1);
            new AlertDialog.Builder(DramaversePlayActivity.this)
                    .setTitle(text("selectEpisode"))
                    .setItems(episodes, (dialog, which) -> boundFragment.startPlayIndex(which + 1))
                    .show();
        }
    }

    private void updatePlaybackChrome(ShortPlay shortPlay, int current, int duration) {
        if (lastProgressEpisode != currentEpisode) {
            lastProgressEpisode = currentEpisode;
            lastRewardBucket = 0;
        }
        if (earningsProgress == null) return;
        int elapsedSeconds = Math.max(0, current);
        int bucket = elapsedSeconds / WATCH_REWARD_INTERVAL_SECONDS;
        int cycleSeconds = elapsedSeconds % WATCH_REWARD_INTERVAL_SECONDS;
        earningsProgress.setProgress((cycleSeconds * 100) / WATCH_REWARD_INTERVAL_SECONDS);
        if (rewardNext != null) {
            int remaining = WATCH_REWARD_INTERVAL_SECONDS - cycleSeconds;
            rewardNext.setText("+" + WATCH_REWARD_COINS + " · " + remaining + "s");
        }
        if (bucket > lastRewardBucket) {
            lastRewardBucket = bucket;
            coinBalance += WATCH_REWARD_COINS;
            getSharedPreferences("talevra_rewards", MODE_PRIVATE)
                    .edit().putInt("coin_balance", coinBalance).apply();
            if (rewardBalance != null) rewardBalance.setText(formatCoins(coinBalance));
            showRewardAnimation();
            earningsProgress.setProgress(0);
        }
    }

    private void showRewardAnimation() {
        LinearLayout reward = new LinearLayout(this);
        reward.setOrientation(LinearLayout.HORIZONTAL);
        reward.setGravity(Gravity.CENTER);
        reward.setBackgroundResource(R.drawable.player_reward_toast_bg);
        ImageView cash = new ImageView(this);
        cash.setImageResource(R.drawable.player_cash);
        reward.addView(cash, new LinearLayout.LayoutParams(dp(36), dp(32)));
        TextView label = new TextView(this);
        label.setText(text("rewardEarned", WATCH_REWARD_COINS));
        label.setTextColor(Color.rgb(255, 219, 62));
        label.setTextSize(18);
        label.setTypeface(null, android.graphics.Typeface.BOLD);
        LinearLayout.LayoutParams labelParams = new LinearLayout.LayoutParams(-2, -2);
        labelParams.leftMargin = dp(5);
        reward.addView(label, labelParams);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(-2, dp(52), Gravity.TOP | Gravity.CENTER_HORIZONTAL);
        params.topMargin = dp(68);
        container.addView(reward, params);
        reward.setScaleX(.82f);
        reward.setScaleY(.82f);
        reward.setAlpha(0f);
        reward.animate().alpha(1f).scaleX(1f).scaleY(1f).setDuration(180)
                .withEndAction(() -> reward.animate().alpha(0f).translationY(-dp(34))
                        .setStartDelay(650).setDuration(280)
                        .withEndAction(() -> container.removeView(reward)).start()).start();
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }

    private static String normalizeLanguage(String value) {
        if (value == null) return "en";
        String language = value.toLowerCase(java.util.Locale.ROOT);
        int separator = language.indexOf('-');
        if (separator > 0) language = language.substring(0, separator);
        if (language.equals("pt") || language.equals("es") || language.equals("id")
                || language.equals("ja") || language.equals("ko")) return language;
        return "en";
    }

    private String localized(String en, String pt, String es, String id, String ja, String ko) {
        if (playerLanguage.equals("pt")) return pt;
        if (playerLanguage.equals("es")) return es;
        if (playerLanguage.equals("id")) return id;
        if (playerLanguage.equals("ja")) return ja;
        if (playerLanguage.equals("ko")) return ko;
        return en;
    }

    private String text(String key) {
        switch (key) {
            case "loading": return localized("Loading series...", "Carregando série...", "Cargando serie...", "Memuat serial...", "シリーズを読み込んでいます...", "시리즈를 불러오는 중...");
            case "sdkUnavailable": return localized("The player is not ready. Try again.", "O player não está pronto. Tente novamente.", "El reproductor no está listo. Inténtalo de nuevo.", "Pemutar belum siap. Coba lagi.", "プレーヤーを準備できませんでした。もう一度お試しください。", "플레이어를 준비하지 못했습니다. 다시 시도해 주세요.");
            case "feedFailed": return localized("We couldn't load this series. Try again.", "Não foi possível carregar esta série. Tente novamente.", "No se pudo cargar esta serie. Inténtalo de nuevo.", "Serial ini tidak dapat dimuat. Coba lagi.", "作品を読み込めませんでした。もう一度お試しください。", "작품을 불러오지 못했습니다. 다시 시도해 주세요.");
            case "noDrama": return localized("This series is unavailable.", "Esta série não está disponível.", "Esta serie no está disponible.", "Serial ini tidak tersedia.", "この作品は現在視聴できません。", "현재 이 작품을 시청할 수 없습니다.");
            case "playFailed": return localized("Playback unavailable", "Não foi possível reproduzir", "No se pudo reproducir", "Pemutaran tidak tersedia", "再生できません", "재생할 수 없음");
            case "share": return localized("Share", "Compartilhar", "Compartir", "Bagikan", "シェア", "공유");
            case "shareDrama": return localized("Share series", "Compartilhar série", "Compartir serie", "Bagikan serial", "作品をシェア", "작품 공유");
            case "like": return localized("Like", "Curtir", "Me gusta", "Suka", "いいね", "좋아요");
            case "collect": return localized("Save", "Salvar", "Guardar", "Simpan", "お気に入り", "즐겨찾기");
            case "selectEpisode": return localized("Episodes", "Episódios", "Episodios", "Episode", "エピソード", "회차");
            case "select": return localized("Choose", "Escolher", "Elegir", "Pilih", "選択", "선택");
            case "back": return localized("Back", "Voltar", "Volver", "Kembali", "戻る", "뒤로");
            case "confirm": return localized("OK", "OK", "Aceptar", "OK", "OK", "확인");
            case "earn": return localized("Earn", "Ganhar", "Ganar", "Dapatkan", "獲得", "적립");
            case "watchToEarn": return localized("Keep watching to earn coins", "Continue assistindo para ganhar moedas", "Sigue viendo para ganar monedas", "Terus tonton untuk mendapatkan koin", "視聴を続けてコインを獲得", "계속 시청하고 코인을 받으세요");
            default: return key;
        }
    }

    private String text(String key, int value) {
        if (key.equals("rewardEarned")) {
            return localized("+" + value + " coins", "+" + value + " moedas", "+" + value + " monedas",
                    "+" + value + " koin", "+" + value + "コイン", "+" + value + " 코인");
        }
        return text(key);
    }

    private String formatCoins(int value) {
        return localized(value + " coins", value + " moedas", value + " monedas", value + " koin",
                value + "コイン", value + " 코인");
    }

    private String formatEpisodeCount(int value) {
        return localized(value + " episodes", value + " episódios", value + " episodios", value + " episode",
                value + "話", value + "화");
    }

    private String formatEpisode(int value) {
        return localized("Episode " + value, "Episódio " + value, "Episodio " + value, "Episode " + value,
                "第" + value + "話", value + "화");
    }

    @Override
    public void finish() {
        Intent data = new Intent();
        data.putExtra(RESULT_LIKED, liked);
        data.putExtra(RESULT_EPISODE, currentEpisode);
        data.putExtra(RESULT_POSITION_MS, currentPositionMs);
        data.putExtra(RESULT_ACTION, resultAction);
        setResult(Activity.RESULT_OK, data);
        super.finish();
    }

    private void finishWithError(String message) {
        Log.e(TAG, message);
        showMessage(message, false);
    }

    private void showSdkError(String title, PSSDK.ErrorInfo errorInfo) {
        String detail = String.valueOf(errorInfo);
        new AlertDialog.Builder(this)
                .setTitle(title)
                .setMessage(detail)
                .setPositiveButton(text("confirm"), null)
                .show();
    }

    private void showMessage(String message, boolean loading) {
        if (container == null) return;
        container.removeAllViews();
        if (loading) {
            ImageView poster = new ImageView(this);
            poster.setImageResource(com.talevra.talevra.R.mipmap.ic_launcher);
            poster.setScaleType(ImageView.ScaleType.CENTER_CROP);
            FrameLayout.LayoutParams posterParams = new FrameLayout.LayoutParams(420, 620, Gravity.CENTER);
            posterParams.bottomMargin = 220;
            container.addView(poster, posterParams);
            AnimationSet posterAnimation = new AnimationSet(true);
            posterAnimation.addAnimation(new ScaleAnimation(0.88f, 1f, 0.88f, 1f,
                    android.view.animation.Animation.RELATIVE_TO_SELF, 0.5f,
                    android.view.animation.Animation.RELATIVE_TO_SELF, 0.5f));
            posterAnimation.addAnimation(new AlphaAnimation(0.25f, 1f));
            posterAnimation.setDuration(900);
            posterAnimation.setRepeatMode(android.view.animation.Animation.REVERSE);
            posterAnimation.setRepeatCount(android.view.animation.Animation.INFINITE);
            poster.startAnimation(posterAnimation);

            ProgressBar progress = new ProgressBar(this);
            FrameLayout.LayoutParams progressParams = new FrameLayout.LayoutParams(120, 120, Gravity.CENTER);
            progressParams.topMargin = 260;
            container.addView(progress, progressParams);
        }
        TextView text = new TextView(this);
        text.setText(message);
        text.setTextColor(Color.WHITE);
        text.setTextSize(16);
        text.setGravity(Gravity.CENTER);
        FrameLayout.LayoutParams textParams = new FrameLayout.LayoutParams(-1, -2, Gravity.CENTER);
        textParams.topMargin = loading ? 420 : 0;
        container.addView(text, textParams);
        container.setBackgroundColor(Color.rgb(15, 16, 20));
    }
}
