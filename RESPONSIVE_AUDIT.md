# Аудит адаптивности umra_flutter

Дата: 2026-06-21 · Только анализ, правки не вносились.

> **Обновление 2026-07:** потолок textScaler поднят с 1.3 до **2.0**
> (`ResponsiveMetrics.maxTextScale`) — устойчивость layout при 1.5/2.0
> подтверждена автотестами `test/widget/text_scale_smoke_test.dart`
> (4 экрана × en/de/ar, viewport 390×844). Оценки textScale ниже по тексту
> сделаны для старого потолка 1.3 и в этой части устарели.

Базис: `lib/utils/responsive_metrics.dart`. Категории: `isCompactPhone` = `shortestSide < 380 || height < 700`; `isTablet` = `shortestSide >= 600`; всё остальное — Phone.

`textScaler` глобально ограничен в `main.dart:105‑108` (`clamp(1.0, 1.3)`) — это хорошо и снимает большую часть рисков масштабирования шрифта. Поэтому проблемы textScale ниже оцениваются с учётом потолка 1.3.

> Замечание по входным данным: для iPhone SE 3 gen логическая высота — **667**, а не 568 (568 — это SE 1‑го поколения). Поэтому часть опасений из ТЗ для SE не подтверждается (см. §6). Расчёты ниже сделаны для height = 667.

---

## Сводка по severity

| # | Файл:строка | Проблема | Устройство | Severity |
|---|---|---|---|---|
| 1 | dua_book_screen.dart:372‑388 | Арабское превью фикс. `width: 80`, `fontSize: 16` — мимо ResponsiveMetrics | планшеты | Warning |
| 2 | language_selection_screen.dart:92 / 114 | `languageListMaxHeight` < высоты 7 языков на ВСЕХ устройствах → 7‑й язык всегда за сгибом | все | Warning |
| 3 | language_selection_screen.dart:118‑189 | Единственный нескроллируемый экран (Column+Expanded) → риск overflow в landscape | compact landscape | Warning |
| 4 | везде, где `PlatformIcons.chevronRight`/`arrowBack` | Иконки-стрелки не зеркалируются в RTL (локаль `ar`) | арабская локаль | Warning |
| 5 | step_detail_screen.dart:101‑103 + arabic_text_widget.dart:23 | Двойной горизонтальный отступ: арабские карточки уже текста абзацев | телефоны | Warning |
| 6 | settings_screen.dart:360 | `settingsTrailingMaxWidth` = 135 на SE → длинные значения усекаются | SE / S24 | Note |
| 7 | home_screen.dart:19 | `_kBottomTabBarReservedSpace = 88.0` — захардкожено, запас ~7px | все | Note |
| 8 | многие | Десятки захардкоженных `fontSize` мимо ResponsiveMetrics | все | Note |
| 9 | prayer_time_screen.dart / др. | Ориентация (`width > height`) нигде не учитывается | планшеты landscape | Note |
| 10 | arabic_text_widget.dart:50 | `arabicFontSize` до 58 на планшете — теоретический горизонт. overflow на длинном токене | планшеты | Note |

Подтверждённых **Critical** (гарантированный краш/обрезка контента) статический анализ не выявил — почти все экраны обёрнуты в `SingleChildScrollView`, а ширины разруливаются через `Expanded`. Самые рискованные места — Warning'и №2–5.

---

## 1. HomeScreen (`lib/screens/home_screen.dart`)

**`bottomTabBarWidth`** (responsive_metrics.dart:37‑41) — проверено на всех 3 категориях, переполнения нет:

| Устройство | ширина бара | примечание |
|---|---|---|
| SE3 / S24 (compact) | 232 / 223 | clamp нижней границей 220 |
| iPhone 15 / ProMax | 242 / 267 | |
| iPad mini / Tab S9 | 268 / 300 | |
| iPad Pro 12.9 (port/land) | 340 / 340 | упор в max 340 |

Логика корректна. Бар центрирован (`Center`), `min(width-32, …)` защищает узкие экраны. **OK.**

**`_StepBadge` / `_InfoBadge`** (50/56/60, строки 520‑591). Заголовок строки в `Expanded` с `maxLines: 2` + ellipsis (480‑489), бейдж и шеврон фиксированы — горизонтального overflow быть не может. Текст в бейдже отдельно ограничен `clamp(20, 26)` (548). **OK / низкий риск.**

**`largeTitleFontSize`** (34/40, строки 180/298). Это `Text` без `maxLines`, перенесётся; контент короткий («UMRA»/«HAJJ»). Отступ `fromLTRB(20,4,20,24)` захардкожен. Обрезки нет даже при ×1.3 (34→44). **Note** (хардкод-паддинг).

**`contentMaxWidth: 680`** на планшете — центрирование корректно (`Center` → `ConstrainedBox`, home_screen.dart:168‑170). На iPad mini/Pro/Tab карточка 680px по центру, по бокам поля. **OK.**

**`_kBottomTabBarReservedSpace = 88.0`** (home_screen.dart:19) — **Note**. Реальная высота бара ≈ `SafeArea(6+10)` + `minHeight 65` ≈ 81px; резерв 88 над `viewPadding.bottom` даёт запас лишь ~7px. На планшете бар той же высоты, так что 88 достаточно, но это «магическое» число, не зависящее от фактической высоты бара/textScale.

---

## 2. StepDetailScreen (`lib/screens/step_detail_screen.dart`)

**`stepDetailHPad`** (10 phone / 24 tablet, responsive_metrics.dart:106). На телефонах абзацы (`bodyFontSize`) прижимаются к краю на 10px. **Warning** — на compact это тесновато для длинного текста.

**PageView + `_PageIndicator`** (78‑122, 604‑640). Индикатор спозиционирован `bottom: viewPadding.bottom + 12`, а контент резервирует `viewPadding.bottom + 48` (строка 93). Перекрытия с home indicator нет, нижний контент не уходит под точки. **OK.**

**Двойной отступ `ConstrainedBox(maxWidth) + stepDetailHPad`** (96‑103) — **Warning**. Само по себе это «constrain, затем pad» — не баг. Но `ArabicTextWidget` добавляет ещё свои 16px (arabic_text_widget.dart:23), тогда как обычные абзацы — нет. Итог по горизонтали:

| | абзац текста | арабская карточка |
|---|---|---|
| phone (hPad 10) | 10px от края | 10 + 16 = 26px |
| tablet (hPad 24) | 24px | 24 + 16 = 40px |

Арабские карточки визуально уже блока текста — рассогласование выравнивания на всех устройствах.

---

## 3. ArabicTextWidget / StepArabicSection

**`arabicFontSize`** (`(width*0.095).clamp(min, 58/42)`, responsive_metrics.dart:43‑47). На планшете всегда упирается в 58. Внутренняя ширина карточки ≈ 600px, доступная под текст ≈ 544px (после паддингов). Текст центрирован, переносится (`height: 1.6`) — переполнения по высоте нет, карточка растёт. Горизонтальный overflow возможен лишь у единичного арабского токена шире 544px при 58px — на практике маловероятно. **Note.**

**`arabicCardRadius`** (20/24, строка 55). По приложению радиусы карточек рассогласованы: home 24, settings 18, prayer 20, InfoCard 20, counter 24/30, dua 24. Арабская 20/24 — в общем ряду, но единого токена радиуса нет. **Note** (визуальная согласованность).

**`arabicContentPadding`** (14/18/28). На compact 14px — текст центрирован, клиппинга нет. **OK.**

---

## 4. PrayerTimeScreen (`lib/screens/prayer_time_screen.dart`)

**`prayerCardMaxWidth: 520`** — центрируется корректно (`Center` → `ConstrainedBox`, 256‑260). **OK.**

**`prayerCardPadding`** (compact 18/24, tablet 28/40, phone 25/32). В landscape планшета вертикальный паддинг 40 «съедает» высоту, но экран скроллится (`SingleChildScrollView`) и карточка ограничена 520px — переполнения нет. **OK**, но см. §9 (ориентация не учитывается явно).

**`prayerHorizontalInset`** (12/16, строка 76). На планшете карточка ограничена 520 → inset роли не играет; на телефоне 12 (compact) / 16 — достаточно. **OK.**

Доп. наблюдение: ширина списка намазов внутри карточки имеет ещё свой `horizontal: isCompactPhone ? 8 : 16` (309‑311) — отдельный захардкоженный путь, не через метрики. **Note.**

---

## 5. SettingsScreen (`lib/screens/settings_screen.dart`)

**`settingsTrailingMaxWidth = min(width*0.36, 170)`** (responsive_metrics.dart:77). На SE = 135px, на S24 = 130px. Значение языка «Bahasa Indonesia» при `captionFontSize` 15 ≈ 130px+ → ellipsis. **Note/Warning** — на узких телефонах длинные названия языка/темы усекаются (есть `overflow: ellipsis`, краша нет, но текст теряется).

**`_spacingBetweenBlocks = 16`** (settings_screen.dart:23) — захардкожено, но для compact пространства хватает (экран скроллится). **Note.**

Доп.: размеры контейнера иконки `38/46` и иконки `18/22` (326‑327) заданы напрямую через `isTablet`, минуя ResponsiveMetrics. **Note** (хардкод).

---

## 6. LanguageSelectionScreen (`lib/screens/language_selection_screen.dart`)

**`languageCardWidth`** = `(width*(tablet?0.46:0.72)).clamp(220, tablet?380:320)`. На SE (375px) = **270px** (а не 230 — опасение из ТЗ исходило из ширины 320). «Bahasa Indonesia» помещается. **OK.**

**`languageCardHeight`** = `(height*(compact?0.22:0.26)).clamp(130,260)`. На SE (height 667) = **147px** (а не 125 — height SE = 667, не 568), до 130 не зажимается. **OK.**

**`languageListMaxHeight`** = `height*(compact?0.36:0.30)` — **Warning**. Высота контента 7 языков ≈ 422px (7×~50 + 6×12). Расчёт по устройствам:

| Устройство | maxListH | вмещает 7? |
|---|---|---|
| SE3 | 240 | нет → скролл |
| iPhone 15 | 253 | нет |
| ProMax | 280 | нет |
| iPad mini | 340 | нет |
| iPad Pro 12.9 | 410 | нет |
| Galaxy S24 | 281 | нет |
| Galaxy Tab S9 | 363 | нет |

То есть **на всех целевых устройствах**, включая iPad Pro с огромным запасом высоты, список искусственно ограничен 30–36% высоты и всегда требует прокрутки — 7‑й язык (العربية) изначально за сгибом. Есть шеврон-подсказка (342‑353), но на планшетах это явно нерационально.

**Нескроллируемый экран в landscape** (118‑189) — **Warning**. Это единственный экран на `Column` с `Expanded` без внешнего скролла. В landscape compact (например 844×390) фиксированные дети: topPad(20)+заголовок(~46)+spacing(18)+cardH(130) ≈ 214px, на `Expanded` остаётся ~150px при `maxListH` ≈ 140 — впритык. При ×1.3 и нижних safe-area есть реальный риск `RenderFlex overflow`.

**`languageHorizontalPadding`** для width>500 (48px, responsive_metrics.dart:79‑83). Порядок веток: `isTablet`(72) → `width>500`(48) → телефон. Для landscape-телефонов (ширина 844/932) даёт 48 — адекватно. **OK.**

Доп.: заголовок `fontSize: 38` (233), кнопка языка `fontSize: 17` (395), радиус 22 и card radius 28 — захардкожены. **Note.**

---

## 7. DuaBookScreen / PlayerWidget

**`playerControlSize`** (58/64/70) и **`playerControlGap`** (12/16). Суммарная ширина 3 кнопок + 2 промежутка + контейнер 32:

| Устройство | сумма | экран | вывод |
|---|---|---|---|
| SE3 / S24 | 230 | 375 / 360 | ok |
| iPhone 15/ProMax | 256 | 390/430 | ok |
| планшеты | 274 | ≥744 | ok |

Переполнения нет; 58px на SE — не слишком мелкие (комфортный тап ≥44). **OK.**

**`duaBadgeSize`** (40/48) в `_CategoryRow` (dua_book_screen.dart:184‑219). Бейдж + заголовок (`Expanded`) + счётчик + шеврон — на планшете всё помещается. **OK.**

**`_DuaRow` арабское превью** (372‑388) — **Warning**. `SizedBox(width: 80)` и `fontSize: 16` захардкожены и НЕ зависят от устройства. На планшете 80px-превью и 16px шрифт выглядят непропорционально мелко рядом с остальным масштабированным контентом. Это место полностью минует ResponsiveMetrics.

---

## Сквозные находки

### Захардкоженные размеры мимо ResponsiveMetrics (Note)
Шрифты, заданные числом и масштабируемые только через `textScaler`, но не зависящие от размера устройства:
- home_screen.dart: stepLabel `11` (471), subtitle `13` (497), буква таба `14` (753), подпись таба `10` (769)
- prayer_time_screen.dart: заголовок `17` (174), исламская дата `22` (274), отсчёт `17` (376), строка намаза `17` (439/449), сегмент-контрол `15` (501/521)
- dua_book_screen.dart: счётчик категории `13` (234), заголовок дуа `15` (396), превью `16`/width `80` (374‑384), label `11` / body `15` (637/647)
- settings_screen.dart: контейнер/иконка `38/46`, `18/22` (326‑327), email в диалоге `16` (88)
- language_selection_screen.dart: `38` (233), `17` (395)
- counter_tap_widget.dart: серия `17/19/22/…` через `isTablet` (122/153/…), минуя метрики
Краша не дают (потолок ×1.3), но это «дыры» в системе адаптивности.

### Ориентация планшета (Note)
Нигде нет проверки `width > height` / `MediaQuery.orientation`. Планшет в landscape получает те же tablet-метрики, что и в portrait. Благодаря скроллу большинство экранов выживает, но раскладка не оптимизируется (напр., можно было бы делать 2 колонки на широком landscape). Единственное место с реальным риском в landscape — экран выбора языка (§6).

### RTL / арабская раскладка (Warning)
- `ArabicTextWidget` корректно изолирует направление (`textDirection: rtl`, `locale: ar`) — **OK**.
- Но иконки `PlatformIcons.chevronRight` и `PlatformIcons.arrowBack` (home, settings, dua, prayer) — обычные, не `Directional`. При локали `ar` Flutter зеркалит раскладку `Row`, но НЕ сам глиф стрелки → шевроны/«назад» указывают в неверную сторону. **Warning.**
- `prayer_time_screen.dart:272` принудительно `TextDirection.ltr` на исламской дате — намеренно ради цифр, но стоит держать в виду при ar. **Note.**
- `Row` с `MainAxisAlignment.spaceBetween` (намазы) и бейдж-слева/шеврон-справа авто-зеркалируются — **OK** по раскладке, проблема только в глифах (выше).

### textScaler > 1.3 (Note)
Глобальный потолок 1.3 (main.dart:105‑108) применён — это снимает большинство рисков. Остаточные тесные места при ровно ×1.3: нижний таб-бар (`minHeight 65` против контента ~55 — проходит), капсулы отсчёта/сегмент-контрола (без фиксированной высоты — растягиваются). Жёстко лимитированных по высоте контейнеров с текстом, которые ломались бы при 1.3, не обнаружено.

---

## Что проверить вручную (runtime), т.к. статикой не подтвердить
1. Экран языка в landscape на compact (SE/S24 повёрнутый) — есть/нет `RenderFlex overflow`.
2. Реальная отрисовка арабского при 58px на самой длинной дуа (Talbiyah, Rabbana) на iPad — нет ли обрезки по правому краю карточки.
3. Арабская локаль (`ar`): направление стрелок-шевронов и «назад».
4. Усечение значения языка/темы в настройках на SE при «Bahasa Indonesia».
