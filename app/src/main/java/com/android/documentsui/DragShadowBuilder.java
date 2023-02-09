/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.documentsui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.jesse205.aidelua2.R;

public class DragShadowBuilder extends View.DragShadowBuilder {

    private final View mShadowView;
    private final TextView mTitle;
    private final ImageView mIcon;
    private final int mWidth;
    private final int mHeight;
    private final int mShadowRadius;
    private int mPadding;
    private Paint paint;

    public DragShadowBuilder(Context context) {
        mWidth = context.getResources().getDimensionPixelSize(R.dimen.drag_shadow_width);
        mHeight = context.getResources().getDimensionPixelSize(R.dimen.drag_shadow_height);
        mShadowRadius = context.getResources().getDimensionPixelSize(R.dimen.drag_shadow_radius);
        mPadding = context.getResources().getDimensionPixelSize(R.dimen.drag_shadow_padding);

        mShadowView = LayoutInflater.from(context).inflate(R.layout.drag_shadow_layout, null);
        mTitle = mShadowView.findViewById(android.R.id.title);
        mIcon = mShadowView.findViewById(android.R.id.icon);

        // Important for certain APIs
        mShadowView.setLayerType(View.LAYER_TYPE_SOFTWARE, paint);
        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    }

    @Override
    public void onProvideShadowMetrics(
        Point shadowSize, Point shadowTouchPoint) {
        shadowSize.set(mWidth, mHeight);
        shadowTouchPoint.set(mWidth - (int)(mPadding * 1.8125f), mHeight / 2);
    }

    @Override
    public void onDrawShadow(Canvas canvas) {
        Rect r = canvas.getClipBounds();
        // Calling measure is necessary in order for all child views to get correctly laid out.
        mShadowView.measure(
            View.MeasureSpec.makeMeasureSpec(r.right - r.left, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(r.bottom - r.top , View.MeasureSpec.EXACTLY));
        mShadowView.layout(r.left, r.top, r.right, r.bottom);

        // Since DragShadow is not an actual view drawn in hardware-accelerated window,
        // android:elevation does not work; we need to draw the shadow ourselves manually.
        paint.setColor(Color.TRANSPARENT);
        // Shadow 1
        int opacity = (int) (255 * 0.1);
        paint.setShadowLayer(mShadowRadius, 0, 0, Color.argb(opacity, 0, 0, 0));
        canvas.drawRect(r.left + mPadding, r.top + mPadding, r.right - mPadding,
                        r.bottom - mPadding, paint);
        // Shadow 2
        opacity = (int) (255 * 0.24);
        paint.setShadowLayer(mShadowRadius, 0, mShadowRadius, Color.argb(opacity, 0, 0, 0));
        canvas.drawRect(r.left + mPadding, r.top + mPadding, r.right - mPadding,
                        r.bottom - mPadding, paint);
        mShadowView.draw(canvas);
    }

    public void updateTitle(String title) {
        mTitle.setText(title);
    }

    public void updateIcon(Drawable icon) {
        mIcon.setImageDrawable(icon);
    }
}
