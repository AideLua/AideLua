package com.jesse205.widget;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.CardView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.graphics.drawable.BitmapDrawable;
import java.util.MissingResourceException;
import android.util.DisplayMetrics;
//感谢dingyi与狸猫
public class MyMagnifier {
    private Activity mContext;
    private CardView mCardView;
    private ImageView mImageView;
    private float verticalOffset;
    private float imageWidth;
    private float imageHeight;
    private float mZoom=1.25f;
    private View mView;
    private float lastSourceCenterX;
    private float lastSourceCenterY;
    private Bitmap mLastBitmap;
    FrameLayout mDecorView;

    public MyMagnifier(View view) {
        mView = view;
        mContext = (Activity) view.getContext();
        DisplayMetrics displayMetrics=mContext.getResources().getDisplayMetrics();
        mCardView = new CardView(mContext);
        mImageView = new ImageView(mContext);
        mCardView.addView(mImageView);
        mCardView.setVisibility(View.GONE);
        mCardView.setCardElevation(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 4, displayMetrics));
        mDecorView=(FrameLayout) mContext.getWindow().getDecorView();
        mDecorView.addView(mCardView);
        imageWidth = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 100, displayMetrics);
        imageHeight =  TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 48, displayMetrics);
        verticalOffset = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, -42, displayMetrics);
        LayoutParams lp=mCardView.getLayoutParams();
        lp.width =  (int) imageWidth;
        lp.height =  (int) imageHeight;
        mCardView.setLayoutParams(lp);
  }
    private Bitmap cropBitmap(Bitmap bitmap, int x, int y, int w, int h) {
        Matrix matrix=new Matrix();
        matrix.setScale(mZoom, mZoom);
        //防止溢出边界
        if (x < 0)
            x = 0;
        else if (x > bitmap.getWidth()-w)
            x = bitmap.getWidth()-w;
        if (y < 0)
            y = 0;
        else if (y > bitmap.getHeight()-h)
            y = bitmap.getHeight()-h;
        Bitmap newBitmap=Bitmap.createBitmap(bitmap, x, y, w, h, matrix, true);
        bitmap.recycle();
        return newBitmap;
    }
    public void update() {
        mView.setDrawingCacheEnabled(true);
        Bitmap oldBitmap=mView.getDrawingCache();
        Bitmap bitmap=oldBitmap.copy(Bitmap.Config.ARGB_4444, true);
        mView.setDrawingCacheEnabled(false);
        float width=imageWidth / mZoom;//实际的bitmap大小
        float height=imageHeight / mZoom;
        if (mLastBitmap != null)//上一个bitmap存在时销毁
            mLastBitmap.recycle();
        mLastBitmap = cropBitmap(bitmap, (int)(lastSourceCenterX - width / 2), (int) (lastSourceCenterY - height / 2), (int) width, (int) height);
        mImageView.setImageBitmap(mLastBitmap);
    }

    public void show(float sourceCenterX, float sourceCenterY, float magnifierCenterX, float magnifierCenterY) {
        //将当前来源中心坐标保存，供update读取
        lastSourceCenterX = sourceCenterX;
        lastSourceCenterY = sourceCenterY;
        //获取view坐标
        final int[] viewPosition = new int[2];
        mView.getLocationInWindow(viewPosition);
        int viewX=viewPosition[0];
        int viewY=viewPosition[1];
        //获取DecorView宽高
        int viewWidth=mDecorView.getMeasuredWidth();
        int viewHeight=mDecorView.getMeasuredHeight();
        
        //将中心的坐标转换为左上角坐标，需要减去高宽的一半，然后再转换为窗口坐标
        float magnifierX=viewX+magnifierCenterX-imageWidth/2.0F;
        float magnifierY=viewY+magnifierCenterY-imageHeight/2.0F;
        
        if (magnifierX < 0)
            mCardView.setX(0);
        else if (magnifierX > viewWidth-imageWidth)
            mCardView.setX(viewWidth-imageWidth);
        else
            mCardView.setX(magnifierX);

        if (magnifierY < 0)
            mCardView.setY(0);
        else if (magnifierY > viewHeight-imageHeight)
            mCardView.setY(viewHeight-imageHeight);
        else
            mCardView.setY(magnifierY);

        mCardView.setVisibility(View.VISIBLE);
        update();
    }
    public void show(float sourceCenterX, float sourceCenterY) {
        show(sourceCenterX, sourceCenterY, sourceCenterX, sourceCenterY + verticalOffset);
    }
    public void dismiss() {
        mCardView.setVisibility(View.GONE);
        if (mLastBitmap != null)
            mLastBitmap.recycle();
    }

    public void setZoom(float zoom) {
        mZoom = zoom;
    }

    public float getZoom(float zoom) {
        return mZoom;
    }

}
