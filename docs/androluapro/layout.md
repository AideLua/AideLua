# 布局表字符串常量

## 布局表支持属性字符串常量

### android:drawingCacheQuality

* auto: `0`
* low: `1`
* high: `2`

### android:importantForAccessibility

* auto: `0`
* yes: `1`
* no: `2`

### android:layerType

* none: `0`
* software: `1`
* hardware: `2`

### android:layoutDirection
* ltr: `0`
* rtl: `1`
* inherit: `2`
* locale: `3`

### android:scrollbarStyle

* insideOverlay: `0x0`
* insideInset: `0x01000000`
* outsideOverlay: `0x02000000`
* outsideInset: `0x03000000`

### android:visibility
* visible: `0`
* invisible: `1`
* gone: `2`

### android:layout_height, android:layout_width

* wrap_content: `-2`
* fill_parent: `-1`
* match_parent: `-1`
* wrap: `-2`
* fill: `-1`
* match: `-1`

### android:orientation

* vertical: `1`
* horizontal: ` 0`

### android:gravity

* axis_clip : ` 8`
* axis_pull_after : ` 4`
* axis_pull_before : ` 2`
* axis_specified : ` 1`
* axis_x_shift : ` 0`
* axis_y_shift : ` 4`
* bottom : ` 80`
* center : ` 17`
* center_horizontal : ` 1`
* center_vertical : ` 16`
* clip_horizontal : ` 8`
* clip_vertical : ` 128`
* display_clip_horizontal : ` 16777216`
* display_clip_vertical : ` 268435456`
* --fill : ` 119`
* fill_horizontal : ` 7`
* fill_vertical : ` 112`
* horizontal_gravity_mask : ` 7`
* left : ` 3`
* no_gravity : ` 0`
* relative_horizontal_gravity_mask : ` 8388615`
* relative_layout_direction : ` 8388608`
* right : ` 5`
* start : ` 8388611`
* top : ` 48`
* vertical_gravity_mask : ` 112`
* end : ` 8388613`

### android:textAlignment

* inherit: `0`
* gravity: `1`
* textStart: `2`
* textEnd: `3`
* textCenter: `4`
* viewStart: `5`
* viewEnd: `6`

### android:inputType

* none: `0x00000000`
* text: `0x00000001`
* textCapCharacters: `0x00001001`
* textCapWords: `0x00002001`
* textCapSentences: `0x00004001`
* textAutoCorrect: `0x00008001`
* textAutoComplete: `0x00010001`
* textMultiLine: `0x00020001`
* textImeMultiLine: `0x00040001`
* textNoSuggestions: `0x00080001`
* textUri: `0x00000011`
* textEmailAddress: `0x00000021`
* textEmailSubject: `0x00000031`
* textShortMessage: `0x00000041`
* textLongMessage: `0x00000051`
* textPersonName: `0x00000061`
* textPostalAddress: `0x00000071`
* textPassword: `0x00000081`
* textVisiblePassword: `0x00000091`
* textWebEditText: `0x000000a1`
* textFilter: `0x000000b1`
* textPhonetic: `0x000000c1`
* textWebEmailAddress: `0x000000d1`
* textWebPassword: `0x000000e1`
* number: `0x00000002`
* numberSigned: `0x00001002`
* numberDecimal: `0x00002002`
* numberPassword: `0x00000012`
* phone: `0x00000003`
* datetime: `0x00000004`
* date: `0x00000014`
* time: `0x00000024`

### android:imeOptions

* normal: `0x00000000`
* actionUnspecified: `0x00000000`
* actionNone: `0x00000001`
* actionGo: `0x00000002`
* actionSearch: `0x00000003`
* actionSend: `0x00000004`
* actionNext: `0x00000005`
* actionDone: `0x00000006`
* actionPrevious: `0x00000007`
* flagNoFullscreen: `0x2000000`
* flagNavigatePrevious: `0x4000000`
* flagNavigateNext: `0x8000000`
* flagNoExtractUi: `0x10000000`
* flagNoAccessoryAction: `0x20000000`
* flagNoEnterAction: `0x40000000`
* flagForceAscii: `0x80000000`

### android:ellipsize

* end　　
* start 　　
* middle
* marquee

## 相对布局 rule

* layout_above: `2`
* layout_alignBaseline: `4`
* layout_alignBottom: `8`
* layout_alignEnd: `19`
* layout_alignLeft: `5`
* layout_alignParentBottom: `12`
* layout_alignParentEnd: `21`
* layout_alignParentLeft: `9`
* layout_alignParentRight: `11`
* layout_alignParentStart: `20`
* layout_alignParentTop: `10`
* layout_alignRight: `7`
* layout_alignStart: `18`
* layout_alignTop: `6`
* layout_alignWithParentIfMissing: `0`
* layout_below: `3`
* layout_centerHorizontal: `14`
* layout_centerInParent: `13`
* layout_centerVertical: `15`
* layout_toEndOf: `17`
* layout_toLeftOf: `0`
* layout_toRightOf: `1`
* layout_toStartOf: `16



## 尺寸单位

* px: `0`
* dp: `1`
* sp: `2`
* pt: `3`
* in: `4`
* mm: `5

