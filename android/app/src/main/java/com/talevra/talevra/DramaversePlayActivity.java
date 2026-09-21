package com.talevra.talevra;

import android.app.Activity;
import android.os.Bundle;
import android.os.Looper;
import android.util.Log;
import android.util.SparseArray;
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
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.ViewConfiguration;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.SeekBar;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.core.content.IntentCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;

import com.bytedance.sdk.shortplay.api.EpisodeData;
import com.bytedance.sdk.shortplay.api.PSSDK;
import com.bytedance.sdk.shortplay.api.ShortPlay;
import com.bytedance.sdk.shortplay.api.ShortPlayFragment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

public final class DramaversePlayActivity extends FragmentActivity {
    private static final String TAG = "DramaversePlay";
    public static final String EXTRA_SHORT_PLAY_ID = "short_play_id";
    public static final String EXTRA_SHORT_PLAY = "short_play";
    public static final String EXTRA_LIKED = "liked";
    public static final String EXTRA_EPISODE = "episode";
    public static final String EXTRA_LANGUAGE = "language";
    public static final String EXTRA_MODE = "mode";
    public static final String MODE_FEED = "feed";
    public static final String MODE_DETAIL = "detail";
    public static final String RESULT_LIKED = "result_liked";
    public static final String RESULT_EPISODE = "result_episode";
    public static final String RESULT_POSITION_MS = "result_position_ms";
    public static final String RESULT_ACTION = "result_action";
    public static final String RESULT_DRAMA_ID = "result_drama_id";
    public static final String RESULT_COMPLETED_EPISODES = "result_completed_episodes";
    private static final int RANDOM_POOL_SIZE = 30;
    private static final int HORIZONTAL_SWIPE_THRESHOLD_DP = 56;
    private static final int VERTICAL_SWIPE_THRESHOLD_DP = 72;
    private static final int VERTICAL_FLING_MIN_DISTANCE_DP = 24;
    private static final int VERTICAL_FLING_VELOCITY_DP = 900;
    private static final int FEED_CACHE_REPETITIONS = 5;
    private FrameLayout rootContainer;
    private FrameLayout container;
    @Nullable private ViewPager2 feedPager;
    @Nullable private FeedPagerAdapter feedAdapter;
    @Nullable private FrameLayout preloadedDetailContainer;
    @Nullable private ShortPlayFragment preloadedDetailFragment;
    @Nullable private ShortPlayFragment activePlayerFragment;
    private long preloadedDetailDramaId = -1L;
    private MixOverlayView fixedOverlay;
    private boolean liked;
    private int currentEpisode = 1;
    private int currentPositionSeconds = 0;
    private String resultAction = "back";
    private boolean feedMode;
    private boolean fragmentTransitionInProgress;
    private boolean randomPoolLoading;
    private boolean switchWhenPoolLoads;
    private float gestureDownX;
    private float gestureDownY;
    private boolean verticalDragActive;
    private boolean horizontalDragActive;
    private int touchSlop;
    private int pendingSwitchDirection;
    @Nullable private VelocityTracker gestureVelocityTracker;
    private ShortPlay currentDrama;
    private final ArrayList<ShortPlay> randomDramaPool = new ArrayList<>();
    private final ArrayList<ShortPlay> feedDramas = new ArrayList<>();
    private final Random random = new Random();
    private final Set<String> completedEpisodeKeys = new HashSet<>();
    private String playerLanguage = "en";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        WindowInsetsControllerCompat insetsController =
                WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        if (insetsController != null) {
            insetsController.hide(WindowInsetsCompat.Type.systemBars());
            insetsController.setSystemBarsBehavior(
                    WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        }
        liked = getIntent().getBooleanExtra(EXTRA_LIKED, false);
        feedMode = MODE_FEED.equals(getIntent().getStringExtra(EXTRA_MODE));
        playerLanguage = normalizeLanguage(getIntent().getStringExtra(EXTRA_LANGUAGE));
        currentEpisode = Math.max(1, getIntent().getIntExtra(EXTRA_EPISODE, 1));
        rootContainer = new FrameLayout(this);
        rootContainer.setBackgroundColor(Color.BLACK);
        container = new FrameLayout(this);
        container.setId(R.id.dramaverse_container);
        rootContainer.addView(container, new FrameLayout.LayoutParams(-1, -1));
        fixedOverlay = new MixOverlayView(this);
        fixedOverlay.setVisibility(View.GONE);
        rootContainer.addView(fixedOverlay, new FrameLayout.LayoutParams(-1, -1));
        setContentView(rootContainer);
        touchSlop = ViewConfiguration.get(this).getScaledTouchSlop();
        showMessage(text("loading"), true);
        if (!PSSDK.hasInitialized()) {
            finishWithError(text("sdkUnavailable"));
            return;
        }
        ShortPlay selectedDrama = IntentCompat.getParcelableExtra(
                getIntent(), EXTRA_SHORT_PLAY, ShortPlay.class);
        if (selectedDrama != null) {
            showDrama(selectedDrama, false);
            loadRandomDramaPool(false);
            return;
        }
        long selectedId = getIntent().getLongExtra(EXTRA_SHORT_PLAY_ID, -1L);
        if (feedMode || selectedId <= 0) {
            loadRandomDramaPool(true);
            return;
        }
        loadRequestedDrama(selectedId);
    }

    private void loadRequestedDrama(long selectedId) {
        PSSDK.QueryRequestParameters query = new PSSDK.QueryRequestParameters();
        query.setIndex(1);
        query.setCount(1);
        ArrayList<Long> ids = new ArrayList<>();
        ids.add(selectedId);
        query.setShortPlayIds(ids);
        PSSDK.requestFeedList(query, new PSSDK.FeedListResultListener() {
            @Override public void onFail(PSSDK.ErrorInfo errorInfo) {
                Log.e(TAG, "selected drama failed: " + errorInfo);
                finishWithError(text("feedFailed"));
            }

            @Override public void onSuccess(PSSDK.FeedListLoadResult<ShortPlay> result) {
                if (result == null || result.dataList == null || result.dataList.isEmpty()) {
                    finishWithError(text("noDrama"));
                    return;
                }
                showDrama(result.dataList.get(0), false);
                loadRandomDramaPool(false);
            }
        });
    }

    private void loadRandomDramaPool(boolean showAfterLoad) {
        if (randomPoolLoading) {
            switchWhenPoolLoads |= showAfterLoad;
            return;
        }
        randomPoolLoading = true;
        switchWhenPoolLoads |= showAfterLoad;
        PSSDK.QueryRequestParameters query = new PSSDK.QueryRequestParameters();
        query.setIndex(1);
        query.setCount(RANDOM_POOL_SIZE);
        PSSDK.requestPopularDrama(query, new PSSDK.FeedListResultListener() {
            @Override public void onFail(PSSDK.ErrorInfo errorInfo) {
                randomPoolLoading = false;
                Log.e(TAG, "random drama pool failed: " + errorInfo);
                if (currentDrama == null) finishWithError(text("feedFailed"));
            }

            @Override public void onSuccess(PSSDK.FeedListLoadResult<ShortPlay> result) {
                randomPoolLoading = false;
                randomDramaPool.clear();
                if (result != null && result.dataList != null) {
                    randomDramaPool.addAll(result.dataList);
                    Collections.shuffle(randomDramaPool, random);
                }
                if (randomDramaPool.isEmpty()) {
                    if (currentDrama == null) finishWithError(text("noDrama"));
                    return;
                }
                boolean shouldSwitch = switchWhenPoolLoads;
                switchWhenPoolLoads = false;
                int switchDirection = pendingSwitchDirection;
                pendingSwitchDirection = 0;
                if (shouldSwitch && feedMode && currentDrama == null) {
                    showFeedPager();
                } else if (shouldSwitch) {
                    switchToRandomDrama(switchDirection);
                }
            }
        });
    }

    private void showFeedPager() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            rootContainer.post(this::showFeedPager);
            return;
        }
        if (randomDramaPool.isEmpty() || feedPager != null || isFinishing()) return;
        feedDramas.clear();
        for (int repetition = 0; repetition < FEED_CACHE_REPETITIONS; repetition++) {
            feedDramas.addAll(randomDramaPool);
        }
        if (container != null) {
            rootContainer.removeView(container);
            container = null;
        }
        ViewPager2 pager = new ViewPager2(this);
        pager.setId(View.generateViewId());
        pager.setOrientation(ViewPager2.ORIENTATION_VERTICAL);
        pager.setOffscreenPageLimit(1);
        feedPager = pager;
        feedAdapter = new FeedPagerAdapter(this);
        pager.setAdapter(feedAdapter);
        pager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override public void onPageSelected(int position) {
                bindFeedPosition(position);
            }
        });
        rootContainer.addView(pager, 0, new FrameLayout.LayoutParams(-1, -1));
        int start = (FEED_CACHE_REPETITIONS / 2) * randomDramaPool.size();
        pager.setCurrentItem(start, false);
        bindFeedPosition(start);
    }

    private void bindFeedPosition(int position) {
        if (!feedMode || position < 0 || position >= feedDramas.size()) return;
        currentDrama = feedDramas.get(position);
        currentEpisode = 1;
        currentPositionSeconds = 0;
        ShortPlayFragment fragment = feedAdapter == null ? null : feedAdapter.fragmentAt(position);
        if (fragment == null) {
            if (feedPager != null) feedPager.post(() -> bindFeedPosition(position));
            return;
        }
        activePlayerFragment = fragment;
        fixedOverlay.bindPage(fragment, currentDrama, 1);
        fixedOverlay.setVisibility(View.VISIBLE);
        rootContainer.post(this::prepareDetailPreload);
    }

    private void switchToRandomDrama() {
        switchToRandomDrama(0);
    }

    private void switchToRandomDrama(int swipeDirection) {
        if (fragmentTransitionInProgress) return;
        if (randomDramaPool.isEmpty()) {
            switchWhenPoolLoads = true;
            pendingSwitchDirection = swipeDirection;
            loadRandomDramaPool(false);
            return;
        }
        ShortPlay next = pickRandomDrama();
        if (next == null) return;
        currentEpisode = 1;
        currentPositionSeconds = 0;
        pendingSwitchDirection = swipeDirection;
        showDrama(next, true);
    }

    @Nullable
    private ShortPlay pickRandomDrama() {
        if (randomDramaPool.isEmpty()) return null;
        if (randomDramaPool.size() == 1) return randomDramaPool.get(0);
        int start = random.nextInt(randomDramaPool.size());
        for (int offset = 0; offset < randomDramaPool.size(); offset++) {
            ShortPlay candidate = randomDramaPool.get((start + offset) % randomDramaPool.size());
            if (currentDrama == null || candidate.id != currentDrama.id) return candidate;
        }
        return randomDramaPool.get(start);
    }

    private void showDrama(ShortPlay shortPlay, boolean replacingDrama) {
        if (isFinishing() || isDestroyed()) return;
        ensureDetailContainer();
        fragmentTransitionInProgress = true;
        currentDrama = shortPlay;
        if (replacingDrama) liked = false;
        ShortPlayFragment fragment = createPlayerFragment(shortPlay, false, -1);
        activePlayerFragment = fragment;
        getSupportFragmentManager().beginTransaction()
                .replace(container.getId(), fragment)
                .runOnCommit(() -> {
                    fragmentTransitionInProgress = false;
                    fixedOverlay.bindPage(fragment, shortPlay, currentEpisode);
                    fixedOverlay.setVisibility(View.VISIBLE);
                    int incomingDirection = pendingSwitchDirection;
                    pendingSwitchDirection = 0;
                    if (replacingDrama && incomingDirection != 0) {
                        float height = Math.max(1, container.getHeight());
                        container.setTranslationY(-incomingDirection * height * 0.16f);
                        container.setAlpha(0.84f);
                        container.animate()
                                .translationY(0f)
                                .alpha(1f)
                                .setDuration(220)
                                .setInterpolator(new DecelerateInterpolator())
                                .start();
                    } else {
                        container.setTranslationY(0f);
                        container.setAlpha(1f);
                    }
                })
                .commit();
    }

    private ShortPlayFragment createPlayerFragment(
            ShortPlay shortPlay,
            boolean singleItem,
            int feedPosition
    ) {
        PSSDK.DetailPageConfig config = new PSSDK.DetailPageConfig.Builder()
                .startPlayIndex(singleItem ? 1 : currentEpisode)
                .playSingleItem(singleItem)
                .enableAutoPlayNext(!singleItem)
                .displayProgressBar(false)
                .displayBottomExtraView(false)
                .displayTextVisibility(PSSDK.DetailPageConfig.TEXT_POS_BOTTOM_TITLE, false)
                .displayTextVisibility(PSSDK.DetailPageConfig.TEXT_POS_BOTTOM_DESC, false)
                .hideLeftTopCloseAndTitle(true, () -> {
                    finish();
                    return true;
                })
                .build();
        final ShortPlayFragment[] holder = new ShortPlayFragment[1];
        ShortPlayFragment fragment = PSSDK.createDetailFragment(shortPlay, config,
                new PSSDK.ShortPlayDetailPageListener() {
                    @Override public void onOverScroll(int direction) {
                        // PSSDK reports over-scroll on the first move event, before a
                        // meaningful drag distance is reached. Activity-level gesture
                        // handling below supplies the threshold and follows the finger.
                    }
                    @Override public void onProgressChange(ShortPlay p, int i, int c, int d) {
                        if (!isActivePlayer(holder[0], feedPosition)) return;
                        currentEpisode = Math.max(1, i);
                        currentPositionSeconds = Math.max(0, c);
                        fixedOverlay.bindPage(holder[0], p, currentEpisode);
                    }
                    @Override public boolean onPlayFailed(PSSDK.ErrorInfo e) {
                        Log.e(TAG, "play failed: " + e);
                        if (isActivePlayer(holder[0], feedPosition)) {
                            showSdkError(text("playFailed"), e);
                        }
                        return true;
                    }
                    @Override public void onShortPlayPlayed(ShortPlay p, int i, EpisodeData e) {
                        if (!isActivePlayer(holder[0], feedPosition)) return;
                        currentEpisode = Math.max(1, i);
                        fixedOverlay.bindPage(holder[0], p, currentEpisode);
                    }
                    @Override public void onItemSelected(int p, ItemType t, int i) { }
                    @Override public void onVideoPlayStateChanged(ShortPlay p, int i, int s) { }
                    @Override public void onVideoPlayCompleted(ShortPlay p, int i) {
                        if (isActivePlayer(holder[0], feedPosition)) {
                            completedEpisodeKeys.add(p.id + ":" + Math.max(1, i));
                        }
                    }
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
        holder[0] = fragment;
        return fragment;
    }

    private boolean isActivePlayer(ShortPlayFragment fragment, int feedPosition) {
        if (fragment == null) return false;
        if (!feedMode) return fragment == activePlayerFragment;
        return feedPager != null
                && feedPager.getCurrentItem() == feedPosition
                && fragment == activePlayerFragment;
    }

    private void ensureDetailContainer() {
        if (container != null) return;
        container = new FrameLayout(this);
        container.setId(View.generateViewId());
        rootContainer.addView(container, 0, new FrameLayout.LayoutParams(-1, -1));
    }

    private boolean isAtSeriesBoundary(int direction, ShortPlay shortPlay) {
        // PSSDK names these constants after the content direction: DIRECTION_UP is
        // emitted when the finger moves down at the first item, and vice versa.
        return direction == PSSDK.DIRECTION_UP && currentEpisode <= 1
                || direction == PSSDK.DIRECTION_DOWN
                && currentEpisode >= Math.max(1, shortPlay.total);
    }

    private void enterCurrentDrama() {
        if (!feedMode || currentDrama == null || fragmentTransitionInProgress) return;
        if (preloadedDetailFragment == null || preloadedDetailContainer == null) {
            prepareDetailPreload();
            rootContainer.post(this::enterCurrentDrama);
            return;
        }
        animateIntoDetail();
    }

    private void prepareDetailPreload() {
        if (!feedMode || currentDrama == null || isFinishing() || isDestroyed()) return;
        if (rootContainer.getWidth() == 0) {
            rootContainer.post(this::prepareDetailPreload);
            return;
        }
        if (preloadedDetailDramaId == currentDrama.id
                && preloadedDetailFragment != null
                && preloadedDetailContainer != null) return;
        clearDetailPreload();
        FrameLayout detail = new FrameLayout(this);
        detail.setId(View.generateViewId());
        detail.setTranslationX(rootContainer.getWidth());
        int chromeIndex = Math.max(0, rootContainer.indexOfChild(fixedOverlay));
        rootContainer.addView(detail, chromeIndex, new FrameLayout.LayoutParams(-1, -1));
        ShortPlayFragment fragment = createPlayerFragment(currentDrama, false, -1);
        preloadedDetailContainer = detail;
        preloadedDetailFragment = fragment;
        preloadedDetailDramaId = currentDrama.id;
        getSupportFragmentManager().beginTransaction()
                .add(detail.getId(), fragment)
                .setMaxLifecycle(fragment, Lifecycle.State.STARTED)
                .commitNowAllowingStateLoss();
    }

    private void clearDetailPreload() {
        if (preloadedDetailFragment != null && preloadedDetailFragment.isAdded()) {
            getSupportFragmentManager().beginTransaction()
                    .remove(preloadedDetailFragment)
                    .commitNowAllowingStateLoss();
        }
        if (preloadedDetailContainer != null) {
            rootContainer.removeView(preloadedDetailContainer);
        }
        preloadedDetailFragment = null;
        preloadedDetailContainer = null;
        preloadedDetailDramaId = -1L;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        int action = event.getActionMasked();
        if (action == MotionEvent.ACTION_DOWN) {
            beginGesture(event);
        } else if (gestureVelocityTracker != null) {
            gestureVelocityTracker.addMovement(event);
        }

        if (action == MotionEvent.ACTION_MOVE) {
            float deltaX = event.getX() - gestureDownX;
            float deltaY = event.getY() - gestureDownY;
            if (!verticalDragActive
                    && !horizontalDragActive
                    && feedMode
                    && deltaX < 0f
                    && Math.abs(deltaX) > touchSlop
                    && Math.abs(deltaX) > Math.abs(deltaY) * 1.12f
                    && preloadedDetailContainer != null
                    && preloadedDetailFragment != null) {
                horizontalDragActive = true;
                cancelChildGesture(event);
            } else if (!verticalDragActive
                    && !horizontalDragActive
                    && !feedMode
                    && Math.abs(deltaY) > touchSlop
                    && Math.abs(deltaY) > Math.abs(deltaX) * 1.12f
                    && canSwitchDramaForDrag(deltaY)) {
                verticalDragActive = true;
                cancelChildGesture(event);
            }
            if (horizontalDragActive) {
                updateHorizontalDrag(deltaX);
                return true;
            }
            if (verticalDragActive) {
                updateVerticalDrag(deltaY);
                return true;
            }
        }

        if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL) {
            float deltaX = event.getX() - gestureDownX;
            float deltaY = event.getY() - gestureDownY;
            if (horizontalDragActive) {
                float velocityX = velocityX();
                boolean shouldEnter = action == MotionEvent.ACTION_UP
                        && (deltaX <= -dp(HORIZONTAL_SWIPE_THRESHOLD_DP)
                        || deltaX <= -dp(VERTICAL_FLING_MIN_DISTANCE_DP)
                        && velocityX <= -dp(VERTICAL_FLING_VELOCITY_DP));
                finishGestureTracking();
                if (shouldEnter) {
                    animateIntoDetail();
                } else {
                    resetHorizontalDrag();
                }
                return true;
            }
            if (verticalDragActive) {
                float velocityY = velocityY();
                boolean shouldSwitch = action == MotionEvent.ACTION_UP
                        && canSwitchDramaForDrag(deltaY)
                        && (Math.abs(deltaY) >= dp(VERTICAL_SWIPE_THRESHOLD_DP)
                        || Math.abs(deltaY) >= dp(VERTICAL_FLING_MIN_DISTANCE_DP)
                        && Math.abs(velocityY) >= dp(VERTICAL_FLING_VELOCITY_DP)
                        && Math.signum(velocityY) == Math.signum(deltaY));
                finishGestureTracking();
                if (shouldSwitch) {
                    animateToRandomDrama(deltaY);
                } else {
                    resetVerticalDrag();
                }
                return true;
            }
            finishGestureTracking();
        }
        return super.dispatchTouchEvent(event);
    }

    private void beginGesture(MotionEvent event) {
        if (container != null) container.animate().cancel();
        if (feedPager != null) feedPager.animate().cancel();
        if (preloadedDetailContainer != null) preloadedDetailContainer.animate().cancel();
        gestureDownX = event.getX();
        gestureDownY = event.getY();
        verticalDragActive = false;
        horizontalDragActive = false;
        if (gestureVelocityTracker != null) gestureVelocityTracker.recycle();
        gestureVelocityTracker = VelocityTracker.obtain();
        gestureVelocityTracker.addMovement(event);
    }

    private void cancelChildGesture(MotionEvent event) {
        MotionEvent cancel = MotionEvent.obtain(event);
        cancel.setAction(MotionEvent.ACTION_CANCEL);
        super.dispatchTouchEvent(cancel);
        cancel.recycle();
    }

    private boolean canSwitchDramaForDrag(float deltaY) {
        if (currentDrama == null || fragmentTransitionInProgress || deltaY == 0f) return false;
        if (feedMode) return true;
        int sdkDirection = deltaY > 0f ? PSSDK.DIRECTION_UP : PSSDK.DIRECTION_DOWN;
        return isAtSeriesBoundary(sdkDirection, currentDrama);
    }

    private void updateVerticalDrag(float deltaY) {
        if (container == null) return;
        float maxOffset = Math.max(dp(VERTICAL_SWIPE_THRESHOLD_DP), container.getHeight() * 0.62f);
        float offset = Math.max(-maxOffset, Math.min(maxOffset, deltaY));
        container.setTranslationY(offset);
        float progress = Math.min(1f, Math.abs(offset) / Math.max(1f, container.getHeight()));
        container.setAlpha(1f - progress * 0.12f);
    }

    private float velocityY() {
        if (gestureVelocityTracker == null) return 0f;
        gestureVelocityTracker.computeCurrentVelocity(1000);
        return gestureVelocityTracker.getYVelocity();
    }

    private float velocityX() {
        if (gestureVelocityTracker == null) return 0f;
        gestureVelocityTracker.computeCurrentVelocity(1000);
        return gestureVelocityTracker.getXVelocity();
    }

    private void finishGestureTracking() {
        verticalDragActive = false;
        horizontalDragActive = false;
        if (gestureVelocityTracker != null) {
            gestureVelocityTracker.recycle();
            gestureVelocityTracker = null;
        }
    }

    private void resetVerticalDrag() {
        if (container == null) return;
        container.animate()
                .translationY(0f)
                .alpha(1f)
                .setDuration(190)
                .setInterpolator(new DecelerateInterpolator())
                .start();
    }

    private void animateToRandomDrama(float deltaY) {
        if (container == null) return;
        int direction = deltaY < 0f ? -1 : 1;
        if (randomDramaPool.isEmpty()) {
            switchWhenPoolLoads = true;
            pendingSwitchDirection = direction;
            loadRandomDramaPool(false);
            resetVerticalDrag();
            return;
        }
        fragmentTransitionInProgress = true;
        float target = direction * Math.max(1, container.getHeight());
        container.animate()
                .translationY(target)
                .alpha(0.78f)
                .setDuration(170)
                .setInterpolator(new AccelerateInterpolator())
                .withEndAction(() -> {
                    fragmentTransitionInProgress = false;
                    container.setTranslationY(0f);
                    container.setAlpha(0f);
                    switchToRandomDrama(direction);
                })
                .start();
    }

    private void updateHorizontalDrag(float deltaX) {
        if (feedPager == null || preloadedDetailContainer == null) return;
        float width = Math.max(1, rootContainer.getWidth());
        float offset = Math.max(-width, Math.min(0f, deltaX));
        feedPager.setTranslationX(offset);
        preloadedDetailContainer.setTranslationX(width + offset);
        fixedOverlay.setAlpha(1f - Math.min(1f, Math.abs(offset) / width) * 0.45f);
    }

    private void resetHorizontalDrag() {
        if (feedPager == null || preloadedDetailContainer == null) return;
        float width = Math.max(1, rootContainer.getWidth());
        feedPager.animate()
                .translationX(0f)
                .setDuration(190)
                .setInterpolator(new DecelerateInterpolator())
                .start();
        preloadedDetailContainer.animate()
                .translationX(width)
                .setDuration(190)
                .setInterpolator(new DecelerateInterpolator())
                .start();
        fixedOverlay.animate().alpha(1f).setDuration(150).start();
    }

    private void animateIntoDetail() {
        if (!feedMode || feedPager == null || preloadedDetailContainer == null
                || preloadedDetailFragment == null || fragmentTransitionInProgress) return;
        fragmentTransitionInProgress = true;
        float width = Math.max(1, rootContainer.getWidth());
        feedPager.animate()
                .translationX(-width)
                .setDuration(220)
                .setInterpolator(new AccelerateInterpolator())
                .start();
        preloadedDetailContainer.animate()
                .translationX(0f)
                .setDuration(240)
                .setInterpolator(new DecelerateInterpolator())
                .withEndAction(this::finishEnteringDetail)
                .start();
        fixedOverlay.animate().alpha(1f).setDuration(180).start();
    }

    private void finishEnteringDetail() {
        if (preloadedDetailContainer == null || preloadedDetailFragment == null) return;
        feedMode = false;
        resultAction = "enter_detail";
        container = preloadedDetailContainer;
        activePlayerFragment = preloadedDetailFragment;
        ShortPlayFragment detailFragment = preloadedDetailFragment;
        preloadedDetailContainer = null;
        preloadedDetailFragment = null;
        preloadedDetailDramaId = -1L;
        if (feedPager != null) {
            feedPager.setAdapter(null);
            rootContainer.removeView(feedPager);
        }
        feedPager = null;
        feedAdapter = null;
        container.setTranslationX(0f);
        getSupportFragmentManager().beginTransaction()
                .setMaxLifecycle(detailFragment, Lifecycle.State.RESUMED)
                .runOnCommit(() -> fragmentTransitionInProgress = false)
                .commitAllowingStateLoss();
        fixedOverlay.bindPage(detailFragment, currentDrama, currentEpisode);
        rootContainer.bringChildToFront(fixedOverlay);
    }

    private List<View> createMixPlayerControls(ShortPlay shortPlay) {
        ArrayList<View> views = new ArrayList<>();

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

    private final class FeedPagerAdapter extends FragmentStateAdapter {
        private final SparseArray<ShortPlayFragment> fragments = new SparseArray<>();

        FeedPagerAdapter(FragmentActivity activity) {
            super(activity);
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            ShortPlayFragment fragment = createPlayerFragment(feedDramas.get(position), true, position);
            fragments.put(position, fragment);
            if (feedPager != null && feedPager.getCurrentItem() == position) {
                feedPager.post(() -> bindFeedPosition(position));
            }
            return fragment;
        }

        @Override
        public int getItemCount() {
            return feedDramas.size();
        }

        @Nullable
        ShortPlayFragment fragmentAt(int position) {
            return fragments.get(position);
        }
    }

    private static final class ShareControlView extends androidx.appcompat.widget.AppCompatImageView
            implements PSSDK.IControlView {
        ShareControlView(android.content.Context context) { super(context); }
        @Override public PSSDK.ControlViewType getControlViewType() { return PSSDK.ControlViewType.Share; }
        @Override public void bindItemData(ShortPlayFragment fragment, ShortPlay shortPlay, int index) { }
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
            normal = ContextCompat.getDrawable(context, collect ? R.drawable.collect : R.drawable.like);
            selected = ContextCompat.getDrawable(context, collect ? R.drawable.collected : R.drawable.liked);
            if (normal == null || selected == null) {
                throw new IllegalStateException("Missing player control drawable");
            }
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
            Drawable progressDrawable = ContextCompat.getDrawable(context, R.drawable.player_seek_progress);
            if (progressDrawable == null) {
                throw new IllegalStateException("Missing player progress drawable");
            }
            setProgressDrawable(progressDrawable);
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

    private final class MixOverlayView extends FrameLayout {
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
            select.setText(text("select") + " ›");
            findViewById(R.id.btn_player_back).setContentDescription(text("back"));
            findViewById(R.id.btn_player_back).setOnClickListener(v -> finish());
            findViewById(R.id.ll_choose_index).setOnClickListener(v -> {
                if (feedMode) {
                    enterCurrentDrama();
                } else {
                    showEpisodePicker();
                }
            });
        }
        void bindPage(ShortPlayFragment fragment, ShortPlay play, int index) {
            if (fragment == null || play == null) return;
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
            default: return key;
        }
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
        data.putExtra(RESULT_POSITION_MS, currentPositionSeconds * 1000);
        data.putExtra(RESULT_ACTION, resultAction);
        data.putExtra(RESULT_DRAMA_ID, currentDrama == null ? -1L : currentDrama.id);
        data.putStringArrayListExtra(
                RESULT_COMPLETED_EPISODES,
                new ArrayList<>(completedEpisodeKeys));
        setResult(Activity.RESULT_OK, data);
        super.finish();
    }

    private void finishWithError(String message) {
        Log.e(TAG, message);
        if (Looper.myLooper() != Looper.getMainLooper()) {
            rootContainer.post(() -> finishWithError(message));
            return;
        }
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
