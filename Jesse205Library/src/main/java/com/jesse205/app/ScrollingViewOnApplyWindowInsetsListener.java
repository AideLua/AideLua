/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.jesse205.app;

import android.graphics.Rect;
import android.view.View;
import android.view.WindowInsets;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import me.zhanghai.android.fastscroll.FastScroller;

public class ScrollingViewOnApplyWindowInsetsListener implements View.OnApplyWindowInsetsListener {

    @NonNull
    private final Rect mPadding = new Rect();
    @Nullable
    private final FastScroller mFastScroller;

    public ScrollingViewOnApplyWindowInsetsListener(@Nullable View view,
                                                    @Nullable FastScroller fastScroller) {
        if (view != null) {
            mPadding.set(view.getPaddingLeft(), view.getPaddingTop(), view.getPaddingRight(),
                    view.getPaddingBottom());
        }
        mFastScroller = fastScroller;
    }

    public ScrollingViewOnApplyWindowInsetsListener() {
        this(null, null);
    }

    @NonNull
    @Override
    public WindowInsets onApplyWindowInsets(@NonNull View view, @NonNull WindowInsets insets) {
        view.setPadding(mPadding.left + insets.getSystemWindowInsetLeft(), mPadding.top,
                mPadding.right + insets.getSystemWindowInsetRight(),
                mPadding.bottom + insets.getSystemWindowInsetBottom());
        if (mFastScroller != null) {
            mFastScroller.setPadding(insets.getSystemWindowInsetLeft(), 0,
                    insets.getSystemWindowInsetRight(), insets.getSystemWindowInsetBottom());
        }
        return insets;
    }
}
