# Vendored / patched packages

This directory holds local forks of pub.dev packages that are pulled in via
`dependency_overrides` in the root `pubspec.yaml`. They exist to carry fixes
that are not yet available in an upstream release.

> ⚠️ A `dependency_override` pins the package and **stops it from receiving
> upstream updates** (including security and bug fixes). Each override below
> must be re-evaluated on every dependency bump and removed once the fix lands
> upstream.

---

## liquid_glass_widgets 0.18.4 — привязанные workaround'ы (не форк)

Пакет не форкнут, но в коде есть два хака, завязанных на баги ровно этой
версии. Оба места помечены greppable-меткой — найти их:

```bash
grep -rn "liquid-glass-upgrade-check" lib/
```

1. **RTL-баг `GlassTabBar`** — индикатор/оверлей позиционируются сырым LTR
   `Alignment`, в арабской локали пилюля выбранной вкладки пустеет. Workaround:
   принудительный `Directionality.ltr` вокруг таб-бара
   (`home_screen.dart`, `_BottomTabBar`).
2. **Мёртвый `GlassTab.semanticLabel`** — поле не читается (Semantics строится
   из `tab.label`), VoiceOver/TalkBack озвучивают вкладки как безымянные "Tab".
   Лейблы уже проставлены и заработают сами после апстрим-фикса; из-за этого же
   таб-бар исключён из `test/widget/tap_target_labels_test.dart`.

**Чеклист при каждом бампе `liquid_glass_widgets`:**

- [ ] Проверить RTL таб-бара в арабской локали → если починено, снять
      `Directionality.ltr` и убрать метку №1.
- [ ] Проверить, что вкладки озвучиваются скринридером (или что
      `semanticLabel` читается в исходниках пакета) → если да, вернуть таб-бар
      в `tap_target_labels_test.dart` и убрать метку №2.
- [ ] Прогнать widget-тесты: `flutter test test/widget/`.

_Last reviewed: 2026-07-02 against upstream 0.18.4._
